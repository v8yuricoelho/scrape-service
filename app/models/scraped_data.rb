# frozen_string_literal: true

class ScrapedData < ApplicationRecord
  validates :task_id, presence: true
  validates :brand, presence: true
  validates :model, presence: true
  validates :year, presence: true
  validates :price, presence: true
  validates :url, presence: true
end
