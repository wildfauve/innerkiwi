class KiwisController < ApplicationController

  def index
  end

  def show
  end

  def new
    @kiwi = Kiwi.new
  end

  def create
    kiwi = Kiwi.new
    kiwi.subscribe(self)
    kiwi.create_me(cust: params[:kiwi], current_user_proxy: @current_user_proxy)
  end

  def update
    kiwi = Kiwi.find(params[:id])
    kiwi.subscribe(self)
    kiwi.update_me(cust: params[:kiwi], current_user_proxy: @current_user_proxy)
  end

  def health
  end

  def successful_save_event(kiwi)
    redirect_to home_path
  end
end
