class IdPort < Port

  attr_accessor :access_token

  include UrlHelpers
  
  class Error < StandardError ; end
  class Unavailable < Error ; end


  def get_access_token(auth_code: nil, host: nil)
    circuit(method: :get_access_token_interface, auth_code: auth_code, host: host)
    self
  end
  
  def get_access_token_interface(auth_code: nil, host: nil)
    Faraday.new do |c|
      c.use Faraday::Request::BasicAuthentication
    end
    conn = Faraday.new(url: Setting.oauth["id_token_service_url"])
    conn.params = get_token_form(auth_code: auth_code, host: host)
    conn.basic_auth Setting.oauth["client_id"], Setting.oauth["client_secret"]
    self.send_to_port(pattern: :sync, connection: {object: conn, method: :post}, response_into: "@access_token")
  end

  def get_token_form(auth_code: nil, host: nil)
    form = { 
      grant_type: "authorization",
      code: auth_code,
      redirect_uri: url_helpers.authorisation_identities_url(host: host)
    }
  end

end