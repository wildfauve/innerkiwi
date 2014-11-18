class CustomerPort < Port
  
  attr_accessor :party
  
  def create_new_customer(kiwi)
    conn = Faraday.new(url: Setting.services(:customers, :create))
    conn.params = customer_msg(kiwi)
    resp = conn.post
    raise if resp.status >= 300
    @party = JSON.parse(resp.body)
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
    raise if resp.status >= 300
    @party = JSON.parse(resp.body)
  end
  
  def buy_customer_product(product_url)
    conn = Faraday.new(url: "")
  end


  
    
end