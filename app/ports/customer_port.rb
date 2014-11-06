class CustomerPort
  
  attr_accessor :party
  
  def create_new_customer(kiwi)
    conn = Faraday.new(url: Setting.services(:customers, :create))
    conn.params = create_customer_req(kiwi)
    resp = conn.post
    raise if resp.status >= 300
    @party = JSON.parse(resp.body)
  end
  
  def create_customer_req(kiwi)
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
  
    
end