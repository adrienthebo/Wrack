
class Wrack::IRC::Receiver
  include Wrack::IRC::Commands

  def initialize(connection, &block)
    @restrictions = []
    @matches      = []
    @connection   = connection
    instance_eval &block
  end

  def receive(&block)
    receiver = Wrack::IRC::Receiver.new(@connection, &block)
    @matches << receiver
  end

  # Add restrictions to this receiver. Accepts an optional hash of options
  # with the key being the method to call on the received message, and the
  # value being the desired value. If given a block, should return true if
  # the message passes validation, else false
  def restrict(options = {}, &block)

    # For each option given as a :key => :val pair, generate a block to
    # check the message to ensure it has the params we want and that they match
    options.each_pair do |method, should|
      restrictor = lambda do |msg|
        begin
          if msg.respond_to?(method) # See if this message has an attr_reader
            # if so, retrieve the value of that field and see if it matches
            value = msg.send(method).to_s.match(should.to_s)
            value
          end
        rescue => e
          $stderr.puts "Aborted while attempting restriction!"
          $stderr.puts e
          $stderr.puts e.backtrace
          nil
        end
      end

      # Store the lambda for testing on a notification
      @restrictions << restrictor
    end

    # if we've been given a block, add that lambda as well
    @restrictions << block if block_given?
  end

  def match(&block)
    @matches << block
  end

  def notify(msg)
    if @restrictions.all? {|restriction| restriction.call(msg) }
      @matches.each do |match|
        begin
          if match.is_a? Wrack::IRC::Receiver
            match.notify msg
          else
            match.call(msg)
          end
        rescue => e
          $stderr.puts "Aborted while calling match!"
          $stderr.puts e
          $stderr.puts e.backtrace
        end
      end
    end
  end
end
