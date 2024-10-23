# frozen_string_literal: true

class TaskScraperWorker
  include Shoryuken::Worker

  shoryuken_options queue: 'tasks_queue', auto_delete: true

  def perform(_sqs_msg, body)
    task_data = JSON.parse(body)
    url = task_data['url']

    process_task(task_data, url)
  end

  private

  def process_task(task_data, url)
    update_task_status(task_data['task_id'], task_data['user_id'], 1)

    scraped_data = scrape_website(url)
    store_scraped_data(task_data, scraped_data)

    update_task_status(task_data['task_id'], task_data['user_id'], 2)
  rescue StandardError => e
    Shoryuken.logger.error "Error processing task #{task_data['task_id']}: #{e.message}"
    update_task_status(task_data['task_id'], task_data['user_id'], 3)
  end

  def update_task_status(task_id, user_id, status)
    TaskStatusUpdateJob.perform_async({ task_id: task_id, user_id: user_id, status: status })
  end

  def scrape_website(url)
    html = Nokogiri::HTML(download_html(url))

    {
      brand: html.css('a.check-here-fipe strong').text.split(' ')[0],
      model: html.css('a.check-here-fipe strong').text.split(' ')[1],
      year: html.css('strong#VehiclePrincipalInformationYear').text,
      price: html.css('strong#vehicleSendProposalPrice').text
    }
  end

  def store_scraped_data(task_data, scraped_data)
    ScrapedData.create!(
      task_id: task_data['task_id'],
      brand: scraped_data[:brand],
      model: scraped_data[:model],
      year: scraped_data[:year],
      price: scraped_data[:price],
      url: task_data['url']
    )
  rescue ActiveRecord::RecordInvalid
    raise "Error saving data for task #{task_data['task_id']}"
  end

  def download_html(url)
    driver = Selenium::WebDriver.for :chrome

    driver.get(url)

    wait = Selenium::WebDriver::Wait.new(timeout: 40)

    wait.until { driver.find_element(css: 'a.check-here-fipe strong') }
    wait.until { driver.find_element(css: 'strong#VehiclePrincipalInformationYear') }
    wait.until { driver.find_element(css: 'strong#vehicleSendProposalPrice') }

    html = driver.page_source

    driver.quit

    html
  end
end
