class PortMonitor
  
  include Wisper::Publisher
  
  attr_accessor :failures
  
  def initialize
    @log = []
    @id = $request_id
  end
  
  def log(method: nil, type: nil, args: nil, state: nil)
    @log << {timestamp: time_now, method: method, type: type, app: Rails.application.class.parent_name, state: state, id: @id}
  end
  
  def api(url: nil, params: nil, type: nil, http_status: nil)
    @log << {timestamp: time_now, url: url, params: params, type: type, http_status: http_status}
  end
  
  def send
    publish(:port_complete_event, self)
  end
  
  def time_now
    Time.now.strftime('%F %R.%L %z')
  end
  
  def port_event
    {
      event: "port_event",
      log: @log
    }
  end
    
end