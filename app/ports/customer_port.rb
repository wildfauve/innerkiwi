class CustomerPort < Port
  
  attr_accessor :party, :status
  
  def create_new_customer(kiwi)
    conn = Faraday.new(url: Setting.services(:customers, :create))
    conn.params = customer_msg(kiwi)
    resp = conn.post
    raise if resp.status >= 400
    if resp.status >= 300
      @error = JSON.parse(resp.body)["status"]
    else
      @party = JSON.parse(resp.body)
    end
  end

  def update_customer(kiwi)
    conn = Faraday.new(url: kiwi.party_url)
    conn.params = customer_msg(kiwi)
    resp = conn.put
    raise if resp.status >= 300
    @party = JSON.parse(resp.body)
  end
  
  def customer_msg(kiwi)
    {
      kind: "party",
      name: kiwi[:name],
      age: kiwi[:age]
    }
  end
  

  
  def get_customer(url: nil)
    conn = Faraday.new(url: url)
    resp = conn.get
    @http_status = resp.status
    if @http_status >= 300
      @status = JSON.parse(resp.body)["status"].to_sym
    else
      @status = :ok
      @party = JSON.parse(resp.body)
    end
    self
  end
  
  def buy_customer_product(product_url)
    conn = Faraday.new(url: "")
  end


  
    
end