# frozen_string_literal: true

class CreateScrapedData < ActiveRecord::Migration[7.0]
  def change
    create_table :scraped_data do |t|
      t.integer :task_id, null: false
      t.string :brand, null: false, index: true
      t.string :model, null: false, index: true
      t.string :year, null: false, index: true
      t.string :price, null: false
      t.string :url, null: false

      t.timestamps
    end
  end
end
