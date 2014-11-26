class Port

  def link_for(rel: nil)
    @msg["_links"][rel.to_s]["href"]
  end
  
  def status_and_parse(resp: nil, parse_in_to: nil)
    @http_status = resp.status
    if @http_status >= 300
      @status = JSON.parse(resp.body)["status"].to_sym
    else
      @status = :ok
      @msg = JSON.parse(resp.body)
      instance_variable_set(parse_in_to, @msg)
    end    
  end
  
  
end
