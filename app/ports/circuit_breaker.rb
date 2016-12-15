class CircuitBreaker

  attr_accessor :invocation_timeout, :failure_threshold, :monitor

  class Error < StandardError ; end
  class Open < Error ; end
  class ConnectionFailure < Error ; end
  class ConnectionTimeout < Error ; end

  def initialize(availability: nil, method: nil, monitor: nil, &block)
    @availability = availability
    @circuit = block
    @method = method
    # @invocation_timeout = 0.5
    @failure_threshold = 3
    @monitor = monitor
    # @reset_timeout = 0.01
    reset
  end

  def call(args)
    case state
    when :closed, :half_open
      begin
        result = do_call args
        record_call args
        result
      rescue Faraday::ConnectionFailed #, Rack::Timeout::RequestTimeoutError
        record_failure
        if state == :open
          raise CircuitBreaker::Open, "System connection timed out"
        else
          retry
        end
      ensure # regardless the monitor record is published
        # TODO: This probably sends on retry (which means n events)
        @monitor.send
      end
    when :open
      raise CircuitBreaker::Open
    else
      raise "Unreachable"
    end
  end

  def do_call(args)
    #result = Timeout::timeout(@invocation_timeout) do
      result = @circuit.call args
      #end
    reset
    return result
  end

  def record_failure
    @failure_count += 1
    @monitor.log(method: @method, type: :circuit_timeout_failure, state: state)
    @last_failure_time = Time.now
  end

  def record_call(args)
    @monitor.log(method: @method, type: :circuit_success, args: args)
  end

  def reset
    @failure_count = 0
    @last_failure_time = nil
    #@monitor.log(method: @method, type: :reset, state: state)
  end

  def state
    case
    when (@failure_count >= @failure_threshold) && (Time.now - @last_failure_time) > @reset_timeout
      :half_open
    when (@failure_count >= @failure_threshold)
      :open
    else
      :closed
    end
  end

end
