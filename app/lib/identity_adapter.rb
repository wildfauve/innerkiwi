class IdentityAdapter

  include Wisper::Publisher

  SCOPES = ["urn:id:scope:farm_perf"]

  attr_accessor :access_token, :id_token, :id_token_encoded, :user_proxy

  include UrlHelpers

    def authorise_url(host: )
    q = {}
    q[:response_type] = "code"
    q[:redirect_uri] = url_helpers.authorisation_identities_url host: host
    q[:scope] = serialise_scopes(SCOPES)
    q[:client_id] = Setting.oauth["client_id"]
    # q[:client_secret] = Setting.oauth["client_secret"]
    # q[:code_challenge] = code_challenge

    # puts "====> Code Challenge: #{code_challenge}"

    # q[:code_challenge_method] = "S256"
    "#{Setting.oauth(:id_service_url)}?#{q.to_query}"
  end

  def logout(user_proxy:, host:)
    IdPort.new.logout(logout_url: logout_url(user_proxy: user_proxy, host: nil ))
  end

  def logout_url(user_proxy: nil, host: nil)
    # q = {post_logout_redirect_uri: url_helpers.root_url(host: host)}
    # q[:id_token_hint] = user_proxy.access_token["id_token"]
    q = {id_token: user_proxy.access_token["id_token"]}
    "#{Setting.oauth(:id_logout_service_url)}?#{q.to_query}"
  end

  def code_challenge
    # "XohImNooBHFR0OVvjcYpJ3NgPQ1qq73WKhHvch0VQtg"
    verifier = code_verifier
    puts "====> Code Verifier: #{verifier}"
    @code ||= Base64.urlsafe_encode64(Digest::SHA256.digest(verifier)).chomp("=")
    # In ID this generates a code of: "juFOkC2gD7ZAKL2XIQowj_My6D7NcwNGvh0ACgRxLJ7nTpZxy6m9f4rLqw0WDXuglIDqwGli_UclgK9mDVJlew=="
  end

  def code_verifier
    @verifier ||= Challenge.make(verifier: SecureRandom.hex).verifier
  end

  def serialise_scopes(scopes)
    scopes.inject("") {|str, scope| str << (scope + ",")}.chop
  end

  #POST /token HTTP/1.1
  #   Host: server.example.com
  #   Authorization: Basic czZCaGRSa3F0MzpnWDFmQmF0M2JW
  #   Content-Type: application/x-www-form-urlencoded
  #
  #   grant_type=authorization_code&code=SplxlOBeZQQYbYS6WxSbIA
  #   &redirect_uri=https%3A%2F%2Fclient%2Eexample%2Ecom%2Fcb

  def get_access(params: nil, host: nil)
    if params[:error]
      publish(:login_error)
    else
      # token = IdPort.new.get_access_token(auth_code: params[:code], code_verifier: Challenge.code_verifier, host: host)
      token = IdPort.new.get_access_token(auth_code: params[:code], host: host)
      @access_token = token.access_token
      validate_id_token()
      @user_proxy = UserProxy.set_up_user(access_token: @access_token, id_token: @id_token)
      if @user_proxy.requires_a_kiwi?
        publish(:create_a_kiwi, @user_proxy)
      else
        @user_proxy.kiwi.check_party
        publish(:valid_authorisation, @user_proxy)
      end
    end
  end

  def validate_id_token
    begin
      key = PKI::PKI.new
      @id_token_encoded = @access_token["id_token"]
      @id_token = JSON::JWT.decode(@id_token_encoded, key.key.public_key)
      #@id_token = JWT.decode(@id_token_encoded, Setting.oauth["id_token_secret"]).inject(&:merge)
    rescue JSON::JWT::Exception => e
      raise
    end
  end

  def id_token_provided?
    @id_token ? true : false
  end

  def get_claim(type: nil, key: nil)
    @id_token[type].first {|c| c["ref"] == "party"}
  end


end
