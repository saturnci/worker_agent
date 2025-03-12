require_relative "../lib/test_runner_agent"
require_relative "../lib/credential"

require "webmock/rspec"
WebMock.disable_net_connect!(allow_localhost: true)

describe TestRunnerAgent do
  let!(:test_runner_id) { "674f498b-0669-4581-a0cf-1be4f2cf5a98" }

  let!(:credential) do
    Credential.new(
      host: "https://app.saturnci.com",
      user_id: "test_user_id",
      api_token: "test_api_token"
    )
  end

  let!(:test_runner_agent) do
    TestRunnerAgent.new(test_runner_id:, credential:)
  end

  before do
    stub_request(:post, "https://app.saturnci.com/api/v1/test_runners/#{test_runner_id}/test_runner_events").
      to_return(status: 200, body: "", headers: {})
  end

  describe "#send_ready_signal" do
    it "works" do
      response = test_runner_agent.send_ready_signal
      expect(response.code).to eq("200")
    end
  end
end
