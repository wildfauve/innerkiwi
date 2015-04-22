class ProfilesController < ApplicationController
  
  def index
    profiler_service = ProfilerAdapter.new.profiler_url(host: request.host_with_port)
    redirect_to profiler_service
  end
  
end