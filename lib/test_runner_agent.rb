require_relative "./api_request"

class TestRunnerAgent
  def initialize(test_runner_id:, credential:)
    @test_runner_id = test_runner_id
    @credential = credential
  end

  def send_ready_signal
    send_event("ready_signal_received")
  end

  def listen_for_assignment(interval_in_seconds: 5, check_limit: nil)
    request = APIRequest.new(
      credential: @credential,
      endpoint: "test_runners/#{@test_runner_id}/test_runner_assignments",
      method: "GET"
    )

    check_count = 0

    loop do
      begin
        response = request.response
        assignments = JSON.parse(response.body)

        if assignments.any?
          send_event("assignment_acknowledged")
          return assignments.first
        end

        sleep interval_in_seconds
        check_count += 1
        return if check_limit && check_count >= check_limit
      rescue => e
        puts "Error checking for assignments: #{e.message}"
      end
    end
  end

  def execute(assignment)
    require_relative "../script"

    ENV["HOST"] = @credential.host
    ENV["RUN_ID"] = assignment["run_id"]
    ENV["RUN_ORDER_INDEX"] = assignment["run_order_index"].to_s
    ENV["PROJECT_NAME"] = assignment["project_name"]
    ENV["BRANCH_NAME"] = assignment["branch_name"]
    ENV["NUMBER_OF_CONCURRENT_RUNS"] = assignment["number_of_concurrent_runs"].to_s
    ENV["COMMIT_HASH"] = assignment["commit_hash"]
    ENV["RSPEC_SEED"] = assignment["rspec_seed"].to_s
    ENV["GITHUB_INSTALLATION_ID"] = assignment["github_installation_id"]
    ENV["GITHUB_REPO_FULL_NAME"] = assignment["github_repo_full_name"]

    ENV["DOCKER_REGISTRY_CACHE_USERNAME"] = assignment["docker_registry_cache_username"]
    ENV["DOCKER_REGISTRY_CACHE_PASSWORD"] = assignment["docker_registry_cache_password"]
    ENV["SATURNCI_ENV_FILE_PATH"] = assignment["saturnci_env_file_path"] || ".saturnci/.env"
    ENV["ARCH"] = assignment["arch"]
    ENV["NODE_ARCH"] = assignment["node_arch"]
    ENV["BUNDLE_GEMFILE"] = assignment["bundle_gemfile"]

    execute_script
  end

  private

  def send_event(type)
    request = APIRequest.new(
      credential: @credential,
      endpoint: "test_runners/#{@test_runner_id}/test_runner_events",
      method: "POST",
      body: { type: type }
    )

    request.response
  end
end
