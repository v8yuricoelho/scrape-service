# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TaskStatusUpdateJob, type: :worker do
  let(:sqs_client) { instance_double(Aws::SQS::Client) }
  let(:task_id) { 1 }
  let(:user_id) { 100 }
  let(:status) { 2 }
  let(:queue_url) { 'https://sqs.us-east-1.amazonaws.com/123456789012/status_updates_queue' }

  before do
    allow(Aws::SQS::Client).to receive(:new).and_return(sqs_client)
    allow(sqs_client).to receive(:send_message)
    ENV['STATUS_UPDATES_QUEUE_URL'] = queue_url
  end

  describe '#perform' do
    it 'sends a message to the SQS queue with the correct task data' do
      expected_message_body = { task_id: task_id, user_id: user_id, status: status }.to_json

      subject.perform(task_id, user_id, status)

      expect(sqs_client).to have_received(:send_message).with(
        queue_url: queue_url,
        message_body: expected_message_body
      )
    end
  end
end
