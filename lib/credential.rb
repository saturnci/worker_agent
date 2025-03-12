class Credential
  attr_reader :host, :user_id, :api_token

  def initialize(host:, user_id:, api_token:)
    @host = host
    @user_id = user_id
    @api_token = api_token
  end
end
