# frozen_string_literal: true

FactoryBot.define do
  factory :review do
    association :user
    association :hotel
    rating { Faker::Number.between(from: 1, to: 5) }
    body { Faker::Lorem.paragraph(sentence_count: 2) }

    after(:build) do |review|
      if review.booking.nil?
        room = create(:room, hotel: review.hotel)
        booking = build(:booking, user: review.user, room: room, status: 'completed', check_in: 5.days.ago, check_out: 2.days.ago)
        booking.save!(validate: false)
        review.booking = booking
      end
    end

    trait :five_stars do
      rating { 5 }
    end

    trait :one_star do
      rating { 1 }
    end
  end
end
