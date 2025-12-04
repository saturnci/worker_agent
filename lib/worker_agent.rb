# frozen_string_literal: true

class WorkerAgent
  CONSECUTIVE_ERROR_THRESHOLD = 5

  def initialize(worker_id:, client:)
    @worker_id = worker_id
    @client = client
  end

  def send_ready_signal
    send_event('ready_signal_received')
  end

  def listen_for_assignment(interval_in_seconds: 5, check_limit: nil)
    check_count = 0
    consecutive_error_count = 0

    loop do
      response = @client.get("workers/#{@worker_id}/worker_assignments")

      if response.code == '200'
        consecutive_error_count = 0
        assignments = JSON.parse(response.body)

        if assignments.any?
          send_event('assignment_acknowledged')
          return assignments.first
        end
      else
        puts "Error checking for assignments: #{response.body}"
        consecutive_error_count += 1

        if consecutive_error_count >= CONSECUTIVE_ERROR_THRESHOLD
          send_event('error')
          return
        end
      end

      sleep interval_in_seconds
      check_count += 1
      puts "check_limit: #{check_limit}"
      puts "check_count: #{check_count}"
      return if check_limit && check_count >= check_limit
    rescue StandardError => e
      puts "Error checking for assignments: #{e.message}"
    end
  end

  def execute(assignment)
    require_relative 'script'

    ENV['TEST_SUITE_RUN_ID'] = assignment['test_suite_run_id']
    ENV['RUN_ID'] = assignment['run_id']
    ENV['TASK_ID'] = assignment['task_id']
    ENV['RUN_ORDER_INDEX'] = assignment['run_order_index'].to_s
    ENV['PROJECT_NAME'] = assignment['project_name']
    ENV['BRANCH_NAME'] = assignment['branch_name']
    ENV['NUMBER_OF_CONCURRENT_RUNS'] = assignment['number_of_concurrent_runs'].to_s
    ENV['COMMIT_HASH'] = assignment['commit_hash']
    ENV['RSPEC_SEED'] = assignment['rspec_seed'].to_s
    ENV['GITHUB_INSTALLATION_ID'] = assignment['github_installation_id']
    ENV['GITHUB_REPO_FULL_NAME'] = assignment['github_repo_full_name']

    ENV['SOURCE_ENV_FILE_PATH'] = '/tmp/.env'
    puts "Writing env vars to #{ENV.fetch('SOURCE_ENV_FILE_PATH', nil)}"
    File.open(ENV.fetch('SOURCE_ENV_FILE_PATH', nil), 'w') do |file|
      assignment['env_vars'].each do |key, value|
        ENV[key] = value
        file.puts "#{key}=#{value}"
      end
    end

    if File.exist?(ENV['SOURCE_ENV_FILE_PATH'])
      puts "Successfully wrote env vars to #{ENV['SOURCE_ENV_FILE_PATH']}"
    else
      puts "Failed: File #{ENV['SOURCE_ENV_FILE_PATH']} does not exist"
    end

    execute_script
  end

  private

  def send_event(type)
    puts "Sending event: #{type}"
    @client.post("workers/#{@worker_id}/worker_events", type: type)
  end
end
