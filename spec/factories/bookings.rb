# frozen_string_literal: true

FactoryBot.define do
  factory :booking do
    association :user
    association :room
    check_in { Date.tomorrow }
    check_out { 5.days.from_now.to_date }
    guests_count { 2 }
    total_price { 15_000.0 }
    status { 'pending' }
    guest_name { "Иван Тестовый" }
    guest_phone { "+79991112233" }
    guest_passport { "1234 567890" }

    trait :confirmed do
      status { 'confirmed' }
    end

    trait :cancelled do
      status { 'cancelled' }
    end

    trait :completed do
      status { 'completed' }
    end

    trait :past do
      check_in { 2.weeks.ago.to_date }
      check_out { 1.week.ago.to_date }
      status { 'completed' }
    end
  end
end
