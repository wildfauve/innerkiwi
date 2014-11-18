class Purchase
  include Mongoid::Document
  include Mongoid::Timestamps  
  
  field :name, type: String 
  field :origination_link, type: String 
  field :product_link, type: String
  field :account_link, type: String
  
  embedded_in :kiwi
  
  # {"kind"=>"product_origination", "state"=>"purchased", "_links"=>{"self"=>{"href"=>"http://localhost:3022/api/v1/sales_products/5460143c4d61745ef6010000/originations/5463ebb74d617452d4060000"}, "product"=>{"href"=>"http://localhost:3022/api/v1/sales_products/5460143c4d61745ef6010000"}}}
  
  def self.create_me(buy: nil)
    pur = self.new
    pur.update_it(buy: buy)
    pur
  end
  
  def update_it(buy: nil)
    self.name = buy.buy["name"]
    self.origination_link = buy.link_for(rel: :self)
    self.product_link = buy.link_for(rel: :product)
    self.account_link = buy.link_for(rel: :account)
    self 
  end
  
  def generate_account_link(options: nil)
    options.merge!({id_token: self.kiwi.user_proxy.access_token[:id_token]})
    "#{self.account_link}?#{options.to_query}"    
  end
    
end
