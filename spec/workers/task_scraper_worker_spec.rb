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

  let(:scraped_data) do
    {
      brand: 'Mitsubishi',
      model: 'Outlander',
      year: '2017/2018',
      price: 'R$ 150.000'
    }
  end

  let(:html_response) do
    <<-HTML
      <html>
        <body>
          <a class="check-here-fipe">
            <strong>Mitsubishi Outlander</strong>
          </a>
          <strong id="VehiclePrincipalInformationYear">2017/2018</strong>
          <strong id="vehicleSendProposalPrice">R$ 150.000</strong>
        </body>
      </html>
    HTML
  end

  before do
    allow_any_instance_of(TaskScraperWorker).to receive(:download_html).and_return(html_response)
    allow(Nokogiri::HTML).to receive(:parse).and_return(Nokogiri::HTML(html_response))
    allow_any_instance_of(TaskScraperWorker).to receive(:scrape_website).and_return(scraped_data)
    allow(ScrapedData).to receive(:create!)
    allow(TaskStatusUpdateJob).to receive(:perform_async)
  end

  describe '#perform' do
    it 'updates the task status to "in progress"' do
      subject.perform(nil, task_data.to_json)

      expect(TaskStatusUpdateJob).to have_received(:perform_async).with(task_id: task_data['task_id'], status: 1)
    end

    it 'scrapes the website and stores the data correctly' do
      subject.perform(nil, task_data.to_json)

      expect(ScrapedData).to have_received(:create!).with(
        task_id: task_data['task_id'],
        brand: scraped_data[:brand],
        model: scraped_data[:model],
        year: scraped_data[:year],
        price: scraped_data[:price],
        url: task_data['url']
      )
    end

    it 'updates the task status to "completed"' do
      subject.perform(nil, task_data.to_json)

      expect(TaskStatusUpdateJob).to have_received(:perform_async).with(task_id: task_data['task_id'], status: 2)
    end

    context 'when an error occurs during processing' do
      it 'updates the task status to "failed"' do
        allow_any_instance_of(TaskScraperWorker).to receive(:scrape_website).and_raise(StandardError)

        subject.perform(nil, task_data.to_json)

        expect(TaskStatusUpdateJob).to have_received(:perform_async).with(task_id: task_data['task_id'], status: 3)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
