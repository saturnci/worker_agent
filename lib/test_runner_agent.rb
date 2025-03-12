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
