# Checqin Booking

Сервис бронирования отелей и аренды жилья (апартаментов, коттеджей) на Ruby on Rails.

## Основной функционал

- Поиск и фильтрация жилья по городам, датам заезда/выезда, гостям, ценам и типу размещения
- Две модели размещения: отели (с номерами) и апартаменты (сдаются целиком)
- Роли пользователей (user, supervisor, admin) на базе Pundit
- Двухэтапная публикация: новые объекты отправляются на модерацию администратору
- Асинхронные уведомления на Sidekiq + Redis при создании или изменении статуса бронирования
- Избранное и отзывы после проживания

## Стек технологий

- Ruby 3.3.5 / Rails 7.1
- PostgreSQL
- Redis / Sidekiq
- Devise / Pundit
- RSpec / FactoryBot

## Запуск проекта

### Через Docker

Запуск контейнеров:
```bash
docker-compose up --build
```

подготовка базы и сидов:
```bash
docker-compose exec web rails db:prepare db:seed
```

### Локальный запуск

установка зависимостей:
```bash
bundle install
```

инициализация базы:
```bash
bin/rails db:create db:migrate db:seed
```

запуск фоновых задач:
```bash
bundle exec sidekiq
```

запуск сервера:
```bash
bin/rails server
```

## Тестовые учетные записи

Пароль для всех аккаунтов: `password123`

- Администратор: `admin@checqin.ru` (модерация объектов в `/admin`)
- Менеджеры:
  - `manager1@checqin.ru` (Москва)
  - `manager2@checqin.ru` (Санкт-Петербург)
  - `manager3@checqin.ru` (Сочи)
- Клиенты:
  - `user1@mail.ru`
  - `user2@mail.ru`
  - `user3@mail.ru`
  - `user4@mail.ru`
  - `user5@gmail.com`

## Запуск тестов

```bash
bundle exec rspec
```
