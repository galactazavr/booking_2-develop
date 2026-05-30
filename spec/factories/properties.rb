# frozen_string_literal: true

FactoryBot.define do
  factory :property do
    association :user, factory: [:user, :supervisor]
    name { "#{Faker::Address.community} Апартаменты" }
    property_type { 'Квартира' }
    city { 'Санкт-Петербург' }
    address { Faker::Address.street_address }
    rooms_count { 2 }
    area { 55.0 }
    guests_capacity { 4 }
    description { Faker::Lorem.paragraph(sentence_count: 2) }
    status { 'review' }
    base_price_per_night { 2500.0 }
    available_from { Date.today }
    available_to { 3.months.from_now.to_date }

    trait :active do
      status { 'active' }
    end

    trait :rejected do
      status { 'rejected' }
    end
  end
end
