class AccountsController < ApplicationController
  
  def index
    @accounts = @kiwi.purchases
  end 
  
  
end