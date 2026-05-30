# frozen_string_literal: true

FactoryBot.define do
  factory :room do
    association :hotel
    name { "Номер #{Faker::Number.between(from: 100, to: 999)}" }
    room_type { 'Стандарт' }
    capacity { 2 }
    area { 25.0 }
    price_per_night { 3000.0 }
    description { Faker::Lorem.sentence }
    available { true }

    trait :luxe do
      room_type { 'Люкс' }
      capacity { 2 }
      area { 45.0 }
      price_per_night { 8000.0 }
    end

    trait :family do
      room_type { 'Семейный' }
      capacity { 4 }
      area { 40.0 }
      price_per_night { 5500.0 }
    end

    trait :unavailable do
      available { false }
    end
  end
end
