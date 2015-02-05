class ProductsController < ApplicationController
  
  def index
    @products = ProductsManager.all.products
  end
  
  def buy
    prod = ProductsManager.new(product_origination_url: params[:prod_origination_url], kiwi: @current_user_proxy.kiwi)
    prod.subscribe(self)
    prod.buy
  end
  
  def successful_purchase_event(product)
    redirect_to products_path
  end
  
  def reset
    prod = ProductsManager.new(kiwi: @current_user_proxy.kiwi)
    prod.subscribe(self)
    prod.reset(params)
  end
  
  def reset_complete
    redirect_to products_path
  end
  
end