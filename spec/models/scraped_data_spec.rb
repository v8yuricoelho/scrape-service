# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ScrapedData, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:task_id) }
    it { should validate_presence_of(:brand) }
    it { should validate_presence_of(:model) }
    it { should validate_presence_of(:year) }
    it { should validate_presence_of(:price) }
    it { should validate_presence_of(:url) }
  end
end
