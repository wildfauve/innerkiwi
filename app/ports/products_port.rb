class ProductsPort < Port
  
  attr_accessor :products, :buy
  
  
  def get_products
    conn = Faraday.new(url: Setting.services(:products, :index))
    resp = conn.get
    raise if resp.status >= 300
    @products = JSON.parse(resp.body)
  end
  
  def buy_product(origination_url: nil, origination: nil)
    conn = Faraday.new(url: origination_url)
    conn.params = origination
    resp = conn.post
    raise if resp.status >= 300
    @buy = JSON.parse(resp.body)
    @msg = @buy
    self
  end
  
  def reset_purchases(link: nil)
    conn = Faraday.new(url: link)
    conn.params = {reset: true}
    resp = conn.put
    raise if resp.status >= 300
    @reset = JSON.parse(resp.body)
    @msg = @reset
    self    
  end
  
    
end