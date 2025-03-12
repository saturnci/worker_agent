require_relative "./api_request"

class TestRunnerAgent
  def initialize(test_runner_id:, credential:)
    @test_runner_id = test_runner_id
    @credential = credential
  end

  def send_ready_signal
    request = APIRequest.new(
      credential: @credential,
      endpoint: "test_runners/#{@test_runner_id}/test_runner_events",
      method: "POST",
      body: { type: "ready_signal_received" }
    )

    request.response
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
end
