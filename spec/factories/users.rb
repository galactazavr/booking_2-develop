# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { 'password123' }
    password_confirmation { 'password123' }
    role { 'user' }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }

    trait :supervisor do
      role { 'supervisor' }
    end

    trait :admin do
      role { 'admin' }
    end

    trait :with_phone do
      phone { '+7 999 123-45-67' }
    end
  end
end
