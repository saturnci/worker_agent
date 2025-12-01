require_relative "../../lib/saturn_ci_worker_api/request"

require "webmock/rspec"
WebMock.disable_net_connect!(allow_localhost: true)

describe SaturnCIWorkerAPI::Request do
  let!(:host) { "https://app.saturnci.com" }

  before do
    allow(ENV).to receive(:[]).with("TEST_RUNNER_ID").and_return("test_runner_id")
    allow(ENV).to receive(:[]).with("TEST_RUNNER_ACCESS_TOKEN").and_return("test_token")
  end

  describe "GET request" do
    let!(:request) do
      SaturnCIWorkerAPI::Request.new(host: host, method: :get, endpoint: "test_runners/123")
    end

    before do
      stub_request(:get, "https://app.saturnci.com/api/v1/worker_agents/test_runners/123")
        .to_return(status: 200, body: { "id" => "123" }.to_json)
    end

    it "parses the response body as JSON" do
      response = request.execute
      expect(JSON.parse(response.body)).to eq({ "id" => "123" })
    end
  end
end
