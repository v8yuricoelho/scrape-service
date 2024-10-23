
# Scrape Service

## Description

The **Scrape Service** is responsible for performing web scraping in the Task Manager system. It collects data (brand, model, price) from a given URL and communicates the results to the Task Manager and Notification services.

## Features

- Perform web scraping on a specified URL.
- Collect vehicle data: brand, model, and price.
- Send results to the Task Manager.

## Technologies Used

- Ruby on Rails
- Nokogiri and Selenium for web scraping
- PostgreSQL
- Shoryuken with AWS SQS for message processing

## Requirements

- **Ruby** 3.1.0 or higher
- **Rails** 7.0.0 or higher
- **PostgreSQL** 12 or higher
- **AWS SQS** configured for Shoryuken

## Environment Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/v8yuricoelho/scrape-service.git
   cd scrape-service
   ```

2. Install the dependencies:

   ```bash
   bundle install
   ```

3. Setup the database:

   ```bash
   rails db:create
   rails db:migrate
   ```

4. Set environment variables:

   Create a `.env` file in the project root with the following variables:

   ```bash
   AWS_ACCESS_KEY_ID=<your_aws_key>
   AWS_SECRET_ACCESS_KEY=<your_aws_secret>
   AWS_REGION=<your_aws_region>
   TASKS_QUEUE_URL=<your_aws_queue_url>
   STATUS_UPDATES_QUEUE_URL=<your_aws_queue_url>
   TASK_MANAGER_URL=http://localhost:3000
   ```

5. Start the server and workers::

   ```bash
   rails server -p 3002
   ```

   Start Shoryuken to process AWS queues:

   ```bash
   bundle exec shoryuken -R -C config/shoryuken.yml -r ./app/workers -q <your_aws_queue_name>
   ```

## Testing

To run tests, use the command:

```bash
rspec
```

## Related Services

- [Task Manager](https://github.com/v8yuricoelho/task-manager)
- [Auth Service](https://github.com/v8yuricoelho/auth-service)
- [Notification Service](https://github.com/v8yuricoelho/notification-service)