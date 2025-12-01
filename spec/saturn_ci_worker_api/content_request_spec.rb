require_relative "../../lib/saturn_ci_worker_api/content_request"

require "webmock/rspec"
WebMock.disable_net_connect!(allow_localhost: true)

describe SaturnCIWorkerAPI::ContentRequest do
  let!(:host) { "https://app.saturnci.com" }

  before do
    allow(ENV).to receive(:[]).with("TEST_RUNNER_ID").and_return("test_runner_id")
    allow(ENV).to receive(:[]).with("TEST_RUNNER_ACCESS_TOKEN").and_return("test_token")
  end

  describe "POST request" do
    let!(:request) do
      SaturnCIWorkerAPI::ContentRequest.new(
        host: host,
        endpoint: "test_outputs",
        content_type: "text/plain",
        body: "test content"
      )
    end

    before do
      stub_request(:post, "https://app.saturnci.com/api/v1/worker_agents/test_outputs")
        .to_return(status: 200, body: "")
    end

    it "sends a POST request with the correct content type" do
      response = request.execute
      expect(response.code).to eq("200")
    end
  end
end
