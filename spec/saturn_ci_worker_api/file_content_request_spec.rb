require "tempfile"
require_relative "../../lib/saturn_ci_worker_api/file_content_request"

require "webmock/rspec"
WebMock.disable_net_connect!(allow_localhost: true)

describe SaturnCIWorkerAPI::FileContentRequest do
  let(:host) { "https://app.saturnci.com" }
  let(:api_path) { "runs/abc123/json_output" }
  let(:content_type) { "application/json" }
  let(:file_content) { '{"test": "data"}' }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("WORKER_ID").and_return("test_runner_id")
    allow(ENV).to receive(:[]).with("WORKER_ACCESS_TOKEN").and_return("test_token")
  end

  it "sends file content with X-Filename header" do
    Tempfile.create(["test", ".json"]) do |file|
      file.write(file_content)
      file.rewind

      stub = stub_request(:post, "https://app.saturnci.com/api/v1/worker_agents/runs/abc123/json_output")
        .with(
          body: file_content,
          headers: {
            "Content-Type" => content_type,
            "X-Filename" => File.basename(file.path)
          }
        )
        .to_return(status: 200, body: "ok")

      request = SaturnCIWorkerAPI::FileContentRequest.new(
        host: host,
        api_path: api_path,
        content_type: content_type,
        file_path: file.path
      )

      response = request.execute

      expect(stub).to have_been_requested
      expect(response.body).to eq("ok")
    end
  end
end
