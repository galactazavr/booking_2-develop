# frozen_string_literal: true

FactoryBot.define do
  factory :hotel do
    name { Faker::Company.name }
    hotel_type { 'Отель' }
    city { 'Москва' }
    address { Faker::Address.street_address }
    phone { '+7 495 123-45-67' }
    email { Faker::Internet.email }
    description { Faker::Lorem.paragraph(sentence_count: 3) }
    status { 'review' }
    base_price_per_night { 3500.0 }
    available_from { Date.today }
    available_to { 3.months.from_now.to_date }

    trait :with_supervisor do
      association :user, factory: [:user, :supervisor]
    end

    trait :active do
      status { 'active' }
    end

    trait :rejected do
      status { 'rejected' }
    end

    trait :with_rooms do
      after(:create) do |hotel|
        create_list(:room, 3, hotel: hotel)
      end
    end
  end
end
