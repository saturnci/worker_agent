require "net/http"
require "uri"
require_relative "api_config"

module SaturnCIWorkerAPI
  class ContentRequest
    include APIConfig
    def initialize(host:, endpoint:, content_type:, body:)
      @host = host
      @endpoint = endpoint
      @content_type = content_type
      @body = body
    end

    def execute
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true if url.scheme == "https"
      http.request(request)
    end

    def request
      r = Net::HTTP::Post.new(url)
      r.basic_auth(ENV["TEST_RUNNER_ID"], ENV["TEST_RUNNER_ACCESS_TOKEN"])
      r["Content-Type"] = @content_type
      r.body = @body
      r
    end

    private

    def url
      URI("#{@host}#{API_BASE_PATH}/#{@endpoint}")
    end
  end
end
