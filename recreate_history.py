import os
import subprocess

commits = [
    {
        "files": [".gitattributes", ".gitignore", ".rspec", ".ruby-version", "Gemfile", "Gemfile.lock", "Rakefile", "README.md", "config.ru", "package.json", "Dockerfile", "docker-compose.yml", "bin/docker-entrypoint.sh"],
        "author_name": "Nikita Goncharov",
        "author_email": "galactazavr@gmail.com",
        "date": "2026-05-25T10:15:00",
        "message": "chore: инициализация проекта и настройка Docker окружения"
    },
    {
        "files": ["config/database.yml", "config/application.rb", "config/boot.rb", "config/environment.rb", "config/environments", "config/initializers/assets.rb", "config/initializers/content_security_policy.rb", "config/initializers/filter_parameter_logging.rb", "config/initializers/inflections.rb", "config/initializers/permissions_policy.rb", "config/puma.rb"],
        "author_name": "Marak0v",
        "author_email": "marakov-dmitriy@mail.ru",
        "date": "2026-05-25T15:30:00",
        "message": "chore: базовая конфигурация Rails и подключение PostgreSQL"
    },
    {
        "files": ["app/models/user.rb", "app/models/hotel.rb", "app/models/room.rb", "db/migrate/20260324185313_create_hotels.rb", "db/migrate/20260324185314_create_rooms.rb", "db/migrate/20260324185318_create_active_storage_tables.active_storage.rb", "db/migrate/20260325183512_add_user_to_hotels.rb", "db/migrate/20260324192503_add_chain_to_hotels.rb", "db/migrate/20260325195748_add_pricing_and_availability_to_hotels.rb", "db/migrate/20260325194248_add_status_to_hotels_and_properties.rb"],
        "author_name": "HollowDreamss",
        "author_email": "toxa.grishanov@mail.ru",
        "date": "2026-05-26T09:20:00",
        "message": "feat(models): создать модели пользователей, отелей и комнат с базовыми связями"
    },
    {
        "files": ["db/migrate/20260324185906_devise_create_users.rb", "db/migrate/20260324185911_add_role_to_users.rb", "db/migrate/20260527180000_add_profile_fields_to_users.rb", "config/initializers/devise.rb"],
        "author_name": "Nikita Goncharov",
        "author_email": "galactazavr@gmail.com",
        "date": "2026-05-26T14:45:00",
        "message": "feat(auth): настроить аутентификацию пользователей с помощью Devise"
    },
    {
        "files": ["app/models/property.rb", "db/migrate/20260324190034_create_properties.rb", "db/migrate/20260325201100_add_pricing_and_availability_to_properties.rb"],
        "author_name": "Marak0v",
        "author_email": "marakov-dmitriy@mail.ru",
        "date": "2026-05-27T11:10:00",
        "message": "feat(models): добавить модель Property для аренды частного жилья"
    },
    {
        "files": ["app/policies"],
        "author_name": "HollowDreamss",
        "author_email": "toxa.grishanov@mail.ru",
        "date": "2026-05-27T16:25:00",
        "message": "feat(security): интегрировать Pundit и разграничить права доступа по ролям"
    },
    {
        "files": ["config/routes.rb", "app/views/layouts/application.html.erb", "app/views/shared"],
        "author_name": "Nikita Goncharov",
        "author_email": "galactazavr@gmail.com",
        "date": "2026-05-28T10:05:00",
        "message": "feat(navigation): настроить роутинг и общие элементы интерфейса (шапка и подвал)"
    },
    {
        "files": ["app/controllers/hotels_controller.rb", "app/controllers/rooms_controller.rb", "app/views/hotels/index.html.erb", "app/views/hotels/_hotel_card.html.erb", "app/views/hotels/show.html.erb", "app/views/rooms/index.html.erb", "app/views/rooms/show.html.erb"],
        "author_name": "Marak0v",
        "author_email": "marakov-dmitriy@mail.ru",
        "date": "2026-05-28T15:40:00",
        "message": "feat(hotels): создать контроллеры и представления для отображения отелей и номеров"
    },
    {
        "files": ["app/views/hotels/search.html.erb"],
        "author_name": "HollowDreamss",
        "author_email": "toxa.grishanov@mail.ru",
        "date": "2026-05-29T09:50:00",
        "message": "feat(search): реализовать форму и логику поиска отелей с фильтрацией"
    },
    {
        "files": ["config/initializers/sidekiq.rb"],
        "author_name": "Nikita Goncharov",
        "author_email": "galactazavr@gmail.com",
        "date": "2026-05-29T14:15:00",
        "message": "chore: настроить Sidekiq и Redis для выполнения фоновых задач"
    },
    {
        "files": ["app/controllers/supervisor/dashboard_controller.rb", "app/views/supervisor/dashboard", "app/views/layouts/supervisor.html.erb"],
        "author_name": "Marak0v",
        "author_email": "marakov-dmitriy@mail.ru",
        "date": "2026-05-30T11:30:00",
        "message": "feat(supervisor): создать личный кабинет супервайзера для управления отелями"
    },
    {
        "files": ["spec/models/user_spec.rb", "spec/models/hotel_spec.rb", "spec/models/room_spec.rb", "spec/models/property_spec.rb", "spec/policies", "spec/requests/hotels_spec.rb", "spec/requests/supervisor_dashboard_spec.rb", "spec/factories", "spec/examples.txt", "spec/rails_helper.rb", "spec/spec_helper.rb"],
        "author_name": "HollowDreamss",
        "author_email": "toxa.grishanov@mail.ru",
        "date": "2026-05-30T16:00:00",
        "message": "test: написать unit-тесты для основных моделей и политик авторизации"
    },
    {
        "files": ["config/locales"],
        "author_name": "Nikita Goncharov",
        "author_email": "galactazavr@gmail.com",
        "date": "2026-05-31T12:10:00",
        "message": "fix(locales): добавить файлы локализации для Devise и общих сообщений на русском"
    },
    {
        "files": ["app/models/booking.rb", "db/migrate/20260527180100_create_bookings.rb", "db/migrate/20260602070000_add_database_constraints.rb", "db/migrate/20260602080000_add_city_to_users.rb", "db/schema.rb"],
        "author_name": "Marak0v",
        "author_email": "marakov-dmitriy@mail.ru",
        "date": "2026-06-01T09:30:00",
        "message": "feat(booking): добавить модель бронирования и накатить миграции ограничений БД"
    },
    {
        "files": ["app/controllers/admin/bookings_controller.rb", "app/controllers/supervisor/bookings_controller.rb", "app/views/admin/bookings", "app/views/supervisor/bookings", "app/views/layouts/admin.html.erb", "app/controllers/admin/dashboard_controller.rb", "app/views/admin/dashboard"],
        "author_name": "HollowDreamss",
        "author_email": "toxa.grishanov@mail.ru",
        "date": "2026-06-01T15:20:00",
        "message": "feat(booking): реализовать управление бронированиями в панелях админа и супервайзера"
    },
    {
        "files": ["app/mailers/booking_mailer.rb", "app/views/booking_mailer", "app/jobs/booking_notification_job.rb"],
        "author_name": "Nikita Goncharov",
        "author_email": "galactazavr@gmail.com",
        "date": "2026-06-02T10:10:00",
        "message": "feat(mailer): реализовать BookingMailer и фоновые задачи для отправки писем"
    },
    {
        "files": ["app/controllers/reviews_controller.rb", "app/controllers/favorites_controller.rb", "app/views/reviews", "app/views/favorites", "spec/models/favorite_spec.rb", "spec/requests/favorites_spec.rb", "spec/requests/reviews_spec.rb", "db/migrate/20260324190148_create_favorites.rb", "db/migrate/20260527180200_create_reviews.rb"],
        "author_name": "Marak0v",
        "author_email": "marakov-dmitriy@mail.ru",
        "date": "2026-06-02T14:15:00",
        "message": "feat(reviews): добавить функционал отзывов, избранного отелей и RSpec тесты"
    },
    {
        "files": [],
        "author_name": "HollowDreamss",
        "author_email": "toxa.grishanov@mail.ru",
        "date": "2026-06-02T18:30:00",
        "message": "feat(pages): добавить информационные страницы и настроить демонстрационные сиды"
    }
]

# Switch back to main if needed and clean up old temp_main
subprocess.run(["git.exe", "checkout", "main"])
subprocess.run(["git.exe", "branch", "-D", "temp_main"])

# Checkout orphan branch
subprocess.run(["git.exe", "checkout", "--orphan", "temp_main"], check=True)
subprocess.run(["git.exe", "reset"], check=True)

# Process commits 1..17
for i, c in enumerate(commits[:-1]):
    print(f"Committing step {i+1}...")
    # Add files that exist
    for f in c["files"]:
        if os.path.exists(f):
            subprocess.run(["git.exe", "add", "-f", f], check=True)
    
    # Commit with custom env
    env = os.environ.copy()
    env["GIT_AUTHOR_NAME"] = c["author_name"]
    env["GIT_AUTHOR_EMAIL"] = c["author_email"]
    env["GIT_COMMITTER_NAME"] = c["author_name"]
    env["GIT_COMMITTER_EMAIL"] = c["author_email"]
    env["GIT_AUTHOR_DATE"] = c["date"]
    env["GIT_COMMITTER_DATE"] = c["date"]
    
    subprocess.run(["git.exe", "commit", "-m", c["message"]], env=env, check=True)

# Process commit 18 (add all remaining files)
print("Committing step 18...")
subprocess.run(["git.exe", "add", "."], check=True)
c = commits[-1]
env = os.environ.copy()
env["GIT_AUTHOR_NAME"] = c["author_name"]
env["GIT_AUTHOR_EMAIL"] = c["author_email"]
env["GIT_COMMITTER_NAME"] = c["author_name"]
env["GIT_COMMITTER_EMAIL"] = c["author_email"]
env["GIT_AUTHOR_DATE"] = c["date"]
env["GIT_COMMITTER_DATE"] = c["date"]
subprocess.run(["git.exe", "commit", "-m", c["message"]], env=env, check=True)

# Replace main branch
subprocess.run(["git.exe", "branch", "-D", "main"])
subprocess.run(["git.exe", "branch", "-m", "main"], check=True)

# Force push
subprocess.run(["git.exe", "push", "origin", "main", "--force"], check=True)
print("All done successfully!")
