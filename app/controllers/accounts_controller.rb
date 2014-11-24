class AccountsController < ApplicationController
  
  def index
    @accounts = @kiwi.purchases.completed
  end 
  
  
end