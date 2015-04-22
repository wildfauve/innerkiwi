class ProfilerAdapter
  
  include UrlHelpers
  
  def profiler_url(host: nil, user_proxy: nil)
    q = {}
    q[:redirect_uri] = url_helpers.settings_url host: host
    q[:id_token] = user_proxy.id_token_encoded
    "#{Setting.services(:profiler, :index)}?#{q.to_query}"    
  end
  
end