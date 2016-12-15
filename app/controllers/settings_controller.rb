class SettingsController < ApplicationController
  
  def index
    @kiwi = @current_user_proxy.kiwi
  end
  
  def personal
    @kiwi = @current_user_proxy.kiwi
    
  end

  def social
    @kiwi = @current_user_proxy.kiwi    
  end
  
  def profile
    profiler_service = ProfilerAdapter.new.profiler_url(host: request.host_with_port, user_proxy: @current_user_proxy)
    redirect_to profiler_service
  end

  
end