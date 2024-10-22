# frozen_string_literal: true

class TaskStatusUpdateJob
  include Shoryuken::Worker

  shoryuken_options queue: 'status_updates_queue', auto_delete: true

  def perform(task_id, status)
    sqs_client = Aws::SQS::Client.new(region: ENV['AWS_REGION'])
    message_body = { task_id: task_id, status: status }.to_json

    sqs_client.send_message({
                              queue_url: ENV['STATUS_UPDATES_QUEUE_URL'],
                              message_body: message_body
                            })
  end
end
