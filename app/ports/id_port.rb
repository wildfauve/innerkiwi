class IdPort < Port

  attr_accessor :access_token

  include UrlHelpers

  class Error < StandardError ; end
  class Unavailable < Error ; end


  def get_access_token(auth_code: nil, code_verifier: nil, host: nil)
    circuit(method: :get_access_token_interface, auth_code: auth_code, code_verifier: code_verifier, host: host)
    self
  end

  def logout(logout_url:)
    circuit(method: :logout_interface, host: logout_url)
  end

  def get_access_token_interface(auth_code: , host: ) #code_verifier:
    Faraday.new do |c|
      c.use Faraday::Request::BasicAuthentication
    end
    conn = Faraday.new(url: Setting.oauth["id_token_service_url"])
    # conn.params = get_token_form(auth_code: auth_code, code_verifier: code_verifier, host: host)
    conn.params = get_token_form(auth_code: auth_code, host: host)
    conn.basic_auth Setting.oauth["client_id"], Setting.oauth["client_secret"]
    self.send_to_port(pattern: :sync, connection: {object: conn, method: :post}, response_into: "@access_token")
  end

  def logout_interface(host: )
    conn = Faraday.new(url: host)
    self.send_to_port(pattern: :sync, connection: {object: conn, method: :post}, response_into: "@result")
  end

  def get_token_form(auth_code: , code_verifier:, host: )
    form = {
      grant_type: "authorization_code",
      code: auth_code,
      code_verifier: code_verifier,
      redirect_uri: url_helpers.authorisation_identities_url(host: host),
      # client_id: Setting.oauth["client_id"]
    }
  end

end
