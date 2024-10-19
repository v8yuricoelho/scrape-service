# frozen_string_literal: true

FactoryBot.define do
  factory :scraped_data do
    task_id { Faker::Number.number(digits: 5) }
    brand { 'Honda' }
    model { Faker::Vehicle.model(make_of_model: 'Honda') }
    year { Faker::Vehicle.year }
    price { Faker::Commerce.price(range: 10_000..100_000) }
    url { Faker::Internet.url }
  end
end
