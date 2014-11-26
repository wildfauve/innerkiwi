class CustomerPort < Port
  
  attr_accessor :party, :status
  
  def create_new_customer(kiwi)
    conn = Faraday.new(url: Setting.services(:customers, :create))
    conn.params = customer_msg(kiwi)
    status_and_parse(resp: conn.post, parse_in_to: "@party")
  end

  def update_customer(kiwi)
    conn = Faraday.new(url: kiwi.party_url)
    conn.params = customer_msg(kiwi)
    status_and_parse(resp: conn.put, parse_in_to: "@party")
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
    status_and_parse(resp: conn.get, parse_in_to: "@party")
    self
  end
  
  def buy_customer_product(product_url)
    conn = Faraday.new(url: "")
  end

  
    
end