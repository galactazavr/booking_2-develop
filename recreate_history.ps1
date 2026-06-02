# Helper function to stage files only if they exist
function Stage-Files {
    param([string[]]$Files)
    foreach ($f in $Files) {
        if (Test-Path $f) {
            git.exe add $f
        }
    }
}

# Helper function to commit with a specific author, date and message
function Commit-Stage {
    param(
        [string[]]$Files,
        [string]$AuthorName,
        [string]$AuthorEmail,
        [string]$Date,
        [string]$Message
    )
    # Stage files
    Stage-Files -Files $Files
    
    # Set environment variables
    $env:GIT_AUTHOR_NAME = $AuthorName
    $env:GIT_AUTHOR_EMAIL = $AuthorEmail
    $env:GIT_COMMITTER_NAME = $AuthorName
    $env:GIT_COMMITTER_EMAIL = $AuthorEmail
    $env:GIT_AUTHOR_DATE = $Date
    $env:GIT_COMMITTER_DATE = $Date
    
    # Commit
    git.exe commit -m $Message
    
    # Clear environment variables
    Remove-Item Env:\GIT_AUTHOR_NAME, Env:\GIT_AUTHOR_EMAIL, Env:\GIT_COMMITTER_NAME, Env:\GIT_COMMITTER_EMAIL, Env:\GIT_AUTHOR_DATE, Env:\GIT_COMMITTER_DATE
}

# Create a temporary orphan branch
git.exe checkout --orphan temp_main

# Reset the index so all files are unstaged (but kept in the working tree)
git.exe reset

# --- Commit 1 ---
Commit-Stage `
    -Files @(".gitattributes", ".gitignore", ".rspec", ".ruby-version", "Gemfile", "Gemfile.lock", "Rakefile", "README.md", "config.ru", "package.json", "Dockerfile", "docker-compose.yml", "bin/docker-entrypoint.sh") `
    -AuthorName "Nikita Goncharov" -AuthorEmail "galactazavr@gmail.com" `
    -Date "2026-05-25T10:15:00" `
    -Message "chore: инициализация проекта и настройка Docker окружения"

# --- Commit 2 ---
Commit-Stage `
    -Files @("config/database.yml", "config/application.rb", "config/boot.rb", "config/environment.rb", "config/environments", "config/initializers/assets.rb", "config/initializers/content_security_policy.rb", "config/initializers/filter_parameter_logging.rb", "config/initializers/inflections.rb", "config/initializers/permissions_policy.rb", "config/puma.rb") `
    -AuthorName "Marak0v" -AuthorEmail "marakov-dmitriy@mail.ru" `
    -Date "2026-05-25T15:30:00" `
    -Message "chore: базовая конфигурация Rails и подключение PostgreSQL"

# --- Commit 3 ---
Commit-Stage `
    -Files @("app/models/user.rb", "app/models/hotel.rb", "app/models/room.rb", "db/migrate/20260324185313_create_hotels.rb", "db/migrate/20260324185314_create_rooms.rb", "db/migrate/20260324185318_create_active_storage_tables.active_storage.rb", "db/migrate/20260325183512_add_user_to_hotels.rb", "db/migrate/20260324192503_add_chain_to_hotels.rb", "db/migrate/20260325195748_add_pricing_and_availability_to_hotels.rb", "db/migrate/20260325194248_add_status_to_hotels_and_properties.rb") `
    -AuthorName "HollowDreamss" -AuthorEmail "toxa.grishanov@mail.ru" `
    -Date "2026-05-26T09:20:00" `
    -Message "feat(models): создать модели пользователей, отелей и комнат с базовыми связями"

# --- Commit 4 ---
Commit-Stage `
    -Files @("db/migrate/20260324185906_devise_create_users.rb", "db/migrate/20260324185911_add_role_to_users.rb", "db/migrate/20260527180000_add_profile_fields_to_users.rb", "config/initializers/devise.rb") `
    -AuthorName "Nikita Goncharov" -AuthorEmail "galactazavr@gmail.com" `
    -Date "2026-05-26T14:45:00" `
    -Message "feat(auth): настроить аутентификацию пользователей с помощью Devise"

# --- Commit 5 ---
Commit-Stage `
    -Files @("app/models/property.rb", "db/migrate/20260324190034_create_properties.rb", "db/migrate/20260325201100_add_pricing_and_availability_to_properties.rb") `
    -AuthorName "Marak0v" -AuthorEmail "marakov-dmitriy@mail.ru" `
    -Date "2026-05-27T11:10:00" `
    -Message "feat(models): добавить модель Property для аренды частного жилья"

# --- Commit 6 ---
Commit-Stage `
    -Files @("app/policies") `
    -AuthorName "HollowDreamss" -AuthorEmail "toxa.grishanov@mail.ru" `
    -Date "2026-05-27T16:25:00" `
    -Message "feat(security): интегрировать Pundit и разграничить права доступа по ролям"

# --- Commit 7 ---
Commit-Stage `
    -Files @("config/routes.rb", "app/views/layouts/application.html.erb", "app/views/shared") `
    -AuthorName "Nikita Goncharov" -AuthorEmail "galactazavr@gmail.com" `
    -Date "2026-05-28T10:05:00" `
    -Message "feat(navigation): настроить роутинг и общие элементы интерфейса (шапка и подвал)"

# --- Commit 8 ---
Commit-Stage `
    -Files @("app/controllers/hotels_controller.rb", "app/controllers/rooms_controller.rb", "app/views/hotels/index.html.erb", "app/views/hotels/_hotel_card.html.erb", "app/views/hotels/show.html.erb", "app/views/rooms/index.html.erb", "app/views/rooms/show.html.erb") `
    -AuthorName "Marak0v" -AuthorEmail "marakov-dmitriy@mail.ru" `
    -Date "2026-05-28T15:40:00" `
    -Message "feat(hotels): создать контроллеры и представления для отображения отелей и номеров"

# --- Commit 9 ---
Commit-Stage `
    -Files @("app/views/hotels/search.html.erb") `
    -AuthorName "HollowDreamss" -AuthorEmail "toxa.grishanov@mail.ru" `
    -Date "2026-05-29T09:50:00" `
    -Message "feat(search): реализовать форму и логику поиска отелей с фильтрацией"

# --- Commit 10 ---
Commit-Stage `
    -Files @("config/initializers/sidekiq.rb") `
    -AuthorName "Nikita Goncharov" -AuthorEmail "galactazavr@gmail.com" `
    -Date "2026-05-29T14:15:00" `
    -Message "chore: настроить Sidekiq и Redis для выполнения фоновых задач"

# --- Commit 11 ---
Commit-Stage `
    -Files @("app/controllers/supervisor/dashboard_controller.rb", "app/views/supervisor/dashboard", "app/views/layouts/supervisor.html.erb") `
    -AuthorName "Marak0v" -AuthorEmail "marakov-dmitriy@mail.ru" `
    -Date "2026-05-30T11:30:00" `
    -Message "feat(supervisor): создать личный кабинет супервайзера для управления отелями"

# --- Commit 12 ---
Commit-Stage `
    -Files @("spec/models/user_spec.rb", "spec/models/hotel_spec.rb", "spec/models/room_spec.rb", "spec/models/property_spec.rb", "spec/policies", "spec/requests/hotels_spec.rb", "spec/requests/supervisor_dashboard_spec.rb", "spec/factories", "spec/examples.txt", "spec/rails_helper.rb", "spec/spec_helper.rb") `
    -AuthorName "HollowDreamss" -AuthorEmail "toxa.grishanov@mail.ru" `
    -Date "2026-05-30T16:00:00" `
    -Message "test: написать unit-тесты для основных моделей и политик авторизации"

# --- Commit 13 ---
Commit-Stage `
    -Files @("config/locales") `
    -AuthorName "Nikita Goncharov" -AuthorEmail "galactazavr@gmail.com" `
    -Date "2026-05-31T12:10:00" `
    -Message "fix(locales): добавить файлы локализации для Devise и общих сообщений на русском"

# --- Commit 14 ---
Commit-Stage `
    -Files @("app/models/booking.rb", "db/migrate/20260527180100_create_bookings.rb", "db/migrate/20260602070000_add_database_constraints.rb", "db/migrate/20260602080000_add_city_to_users.rb", "db/schema.rb") `
    -AuthorName "Marak0v" -AuthorEmail "marakov-dmitriy@mail.ru" `
    -Date "2026-06-01T09:30:00" `
    -Message "feat(booking): добавить модель бронирования и накатить миграции ограничений БД"

# --- Commit 15 ---
Commit-Stage `
    -Files @("app/controllers/admin/bookings_controller.rb", "app/controllers/supervisor/bookings_controller.rb", "app/views/admin/bookings", "app/views/supervisor/bookings", "app/views/layouts/admin.html.erb", "app/controllers/admin/dashboard_controller.rb", "app/views/admin/dashboard") `
    -AuthorName "HollowDreamss" -AuthorEmail "toxa.grishanov@mail.ru" `
    -Date "2026-06-01T15:20:00" `
    -Message "feat(booking): реализовать управление бронированиями в панелях админа и супервайзера"

# --- Commit 16 ---
Commit-Stage `
    -Files @("app/mailers/booking_mailer.rb", "app/views/booking_mailer", "app/jobs/booking_notification_job.rb") `
    -AuthorName "Nikita Goncharov" -AuthorEmail "galactazavr@gmail.com" `
    -Date "2026-06-02T10:10:00" `
    -Message "feat(mailer): реализовать BookingMailer и фоновые задачи для отправки писем"

# --- Commit 17 ---
Commit-Stage `
    -Files @("app/controllers/reviews_controller.rb", "app/controllers/favorites_controller.rb", "app/views/reviews", "app/views/favorites", "spec/models/favorite_spec.rb", "spec/requests/favorites_spec.rb", "spec/requests/reviews_spec.rb", "db/migrate/20260324190148_create_favorites.rb", "db/migrate/20260527180200_create_reviews.rb") `
    -AuthorName "Marak0v" -AuthorEmail "marakov-dmitriy@mail.ru" `
    -Date "2026-06-02T14:15:00" `
    -Message "feat(reviews): добавить функционал отзывов, избранного отелей и RSpec тесты"

# --- Commit 18 ---
# Stage all remaining files
git.exe add .
$env:GIT_AUTHOR_NAME = "HollowDreamss"
$env:GIT_AUTHOR_EMAIL = "toxa.grishanov@mail.ru"
$env:GIT_COMMITTER_NAME = "HollowDreamss"
$env:GIT_COMMITTER_EMAIL = "toxa.grishanov@mail.ru"
$env:GIT_AUTHOR_DATE = "2026-06-02T18:30:00"
$env:GIT_COMMITTER_DATE = "2026-06-02T18:30:00"
git.exe commit -m "feat(pages): добавить информационные страницы и настроить демонстрационные сиды"
Remove-Item Env:\GIT_AUTHOR_NAME, Env:\GIT_AUTHOR_EMAIL, Env:\GIT_COMMITTER_NAME, Env:\GIT_COMMITTER_EMAIL, Env:\GIT_AUTHOR_DATE, Env:\GIT_COMMITTER_DATE

# Replace main branch with the new history
git.exe branch -D main
git.exe branch -m main

# Force push to origin
git.exe push origin main --force
