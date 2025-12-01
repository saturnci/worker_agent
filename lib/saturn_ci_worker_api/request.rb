require "net/http"
require "uri"
require_relative "api_config"

module SaturnCIWorkerAPI
  class Request
    include APIConfig
    def initialize(host:, endpoint:, method:, body: nil, content_type: "application/json")
      @host = host
      @endpoint = endpoint
      @method = method
      @body = body
      @content_type = content_type
    end

    def execute
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true if url.scheme == "https"
      http.request(request)
    end

    def request
      case @method
      when :get
        r = Net::HTTP::Get.new(url)
      when :post
        r = Net::HTTP::Post.new(url)
      when :delete
        r = Net::HTTP::Delete.new(url)
      when :patch
        r = Net::HTTP::Patch.new(url)
      end

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
