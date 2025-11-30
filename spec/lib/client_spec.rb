require_relative "../../lib/client"

require "webmock/rspec"
WebMock.disable_net_connect!(allow_localhost: true)

describe SaturnCIRunnerAPI::Client do
  let(:host) { "https://app.saturnci.com" }
  let(:client) { SaturnCIRunnerAPI::Client.new(host) }

  before do
    ENV["TEST_RUNNER_ID"] = "test_runner_id"
    ENV["TEST_RUNNER_ACCESS_TOKEN"] = "test_token"
  end

  describe "#get" do
    before do
      stub_request(:get, "https://app.saturnci.com/api/v1/worker_agents/test_runners/123/assignments")
        .to_return(status: 200, body: [{ run_id: "abc" }].to_json)
    end

    it "makes a GET request and returns the response" do
      response = client.get("test_runners/123/assignments")
      expect(response.code).to eq("200")
      expect(JSON.parse(response.body)).to eq([{ "run_id" => "abc" }])
    end
  end
end
