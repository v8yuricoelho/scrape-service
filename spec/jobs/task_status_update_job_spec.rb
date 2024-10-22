# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe TaskScraperWorker, type: :worker do
  let(:task_data) do
    {
      'task_id' => 1,
      'url' => 'https://www.example.com'
    }
  end

  let(:scraped_data) { build(:scraped_data, task_id: task_data['task_id'], url: task_data['url']) }

  let(:html_response) do
    <<-HTML
      <html>
        <body>
          <a class="check-here-fipe">
            <strong>#{scraped_data.brand} #{scraped_data.model}</strong>
          </a>
          <strong id="VehiclePrincipalInformationYear">#{scraped_data.year}</strong>
          <strong id="vehicleSendProposalPrice">R$ #{scraped_data.price}</strong>
        </body>
      </html>
    HTML
  end

  before do
    allow_any_instance_of(TaskScraperWorker).to receive(:download_html).and_return(html_response)
    allow(Nokogiri::HTML).to receive(:parse).and_return(Nokogiri::HTML(html_response))
    allow(ScrapedData).to receive(:create!)
    allow(TaskStatusUpdateJob).to receive(:perform_async)
  end

  describe '#perform' do
    it 'scrapes the website and stores the data correctly' do
      subject.perform(nil, task_data.to_json)

      expect(ScrapedData).to have_received(:create!).with(
        task_id: scraped_data.task_id,
        brand: scraped_data.brand,
        model: scraped_data.model,
        year: scraped_data.year,
        price: "R$ #{scraped_data.price}",
        url: scraped_data.url
      )
    end
  end
end
# rubocop:enable Metrics/BlockLength
