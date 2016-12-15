class Api::V1::KiwisController < Api::V1::BaseController

  def index
    expires_in(1.hour, public: true, must_revalidate: true)
    puts "HEADERS====>  #{@_headers.inspect}"
    @kiwis = Kiwi.all
  end

  def show
    @kiwi = Kiwi.find(params[:id])
  end

end
