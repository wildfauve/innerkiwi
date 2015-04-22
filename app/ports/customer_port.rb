class CustomerPort < Port
  
  class Error < StandardError ; end
  class Unavailable < Error ; end
  
  attr_accessor :party, :status

  def create_new_customer(customer: nil)
    circuit(method: :create_new_customer_port, customer: customer)
    self
  end

  def create_new_customer_port(customer: nil)
    conn = Faraday.new(url: Setting.services(:customers, :create))
    conn.params = customer_msg(customer)
    self.send_to_port(pattern: :sync, connection: {object: conn, method: :post}, response_into: "@party")    
  end
  
  def update_customer(customer: nil, party_url: nil)
    circuit(method: :update_customer_port, customer: customer, party_url: party_url)
    self
  end
  

  def update_customer_port(customer: nil, party_url: nil)
    conn = Faraday.new(url: party_url)
    conn.params = customer_msg(customer)
    self.send_to_port(pattern: :sync, connection: {object: conn, method: :put}, response_into: "@party")
  end
  
  def customer_msg(customer)
    {
      kind: "party",
      name: customer[:name],
      age: customer[:age]
    }
  end
  
  def get_customer(party_url: nil)
    begin
      circuit(method: :get_customer_port, party_url: party_url)    
      self  
    rescue Port::Unavailable => e
      self.status = :unavailable
      self
    end
  end  
  
  def get_customer_port(party_url: nil)
    conn = Faraday.new(url: party_url)
    self.send_to_port(pattern: :sync, connection: {object: conn, method: :get}, response_into: "@party")
  end
  
  def buy_customer_product(product_url)
    conn = Faraday.new(url: "")
  end

  
    
end