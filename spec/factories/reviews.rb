# frozen_string_literal: true

FactoryBot.define do
  factory :review do
    association :user
    association :hotel
    rating { Faker::Number.between(from: 1, to: 5) }
    body { Faker::Lorem.paragraph(sentence_count: 2) }

    trait :with_booking do
      association :booking
    end

    trait :five_stars do
      rating { 5 }
    end

    trait :one_star do
      rating { 1 }
    end
  end
end
