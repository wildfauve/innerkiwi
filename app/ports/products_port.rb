class ProductsPort < Port
  
  attr_accessor :products, :buy, :origination
  
  class Error < StandardError ; end
  class Unavailable < Error ; end
  

  def get_products
    circuit(method: :get_products_interface)
    self
  end

  def get_products_interface
    conn = Faraday.new(url: Setting.services(:products, :index))
    self.send_to_port(pattern: :sync, connection: {object: conn, method: :get}, response_into: "@products")
  end


  def buy_product(origination_url: nil, origination: nil)
    circuit(method: :buy_product_port, origination_url: origination_url, origination: origination)
    self
  end

  def buy_product_port(origination_url: nil, origination: nil)
    conn = Faraday.new(url: origination_url)
    conn.params = origination
    self.send_to_port(pattern: :sync, connection: {object: conn, method: :post}, response_into: "@buy")    
  end

  
  def get_origination(origination_url: nil)
    circuit(method: :get_origination_interface, origination_url: origination_url)    
    self
  end  
    
    
  def get_origination_interface(origination_url: nil)
    conn = Faraday.new(url: origination_url)
    self.send_to_port(pattern: :sync, connection: {object: conn, method: :get}, response_into: "@origination")        
  end
  
  def reset_origination(link: nil)
    conn = Faraday.new(url: link)
    resp = conn.delete
    raise if resp.status >= 300
    @reset = JSON.parse(resp.body)
    @msg = @reset
    self    
  end  
    
end