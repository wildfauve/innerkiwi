class ProductsManager
  
  include Wisper::Publisher
  
  def self.all
    @pp = ProductsPort.new.get_products
  end
  
  def initialize(product_origination_url: nil, kiwi: nil)
    @p_o_url = product_origination_url
    @kiwi = kiwi
  end
  
  def buy
    buy = ProductsPort.new.buy_product(origination_url: @p_o_url, origination: origination_msg())
    @kiwi.add_purchase(buy: buy)
    publish(:successful_purchase_event, self)
  end
  
  def reset(params)
    buys = @kiwi.purchases.collect {|p| ProductsPort.new.reset_origination(link: p.origination_link)} unless params[:local].present?
    @kiwi.purchases.delete_all
    publish(:reset_complete)
  end
  
  def origination_msg
    {
      kind: "product_originations",
      id_token: @kiwi.user_proxy.access_token[:id_token],
      customer: {
        _links: {
          self: {
            href:  @kiwi.party_url
          }
        }
      }
    }
    
  end

  
end