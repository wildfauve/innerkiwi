class Api::V1::KiwisController < Api::ApplicationController
  
  def index
    @kiwis = Kiwi.all
  end
  
  def show
    @kiwi = Kiwi.find(params[:id])
  end
  
end