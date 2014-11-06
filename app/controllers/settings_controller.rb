class SettingsController < ApplicationController
  
  def index
    @kiwi = @current_user_proxy.kiwi
  end
  
end