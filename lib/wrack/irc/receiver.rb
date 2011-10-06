
class Wrack::IRC::Receiver

  def initialize
    @restrictions = []
    @matchers = []
  end

  def receive(&block)
    @matchers << block
  end

  def restrict(options = {}, &block)

    # For each option given as a :key => :val pair, generate a block to 
    # check the message to ensure it has the params we want and that they match
    options.each_pair do |k, v|
      restrictor = lambda do |msg|
        begin
          if msg.respond_to?(method) # See if this message has an attr_reader
            # if so, retrieve the value of that field and see if it matches
            value = msg.send(method).match(should)
          end
        rescue => e
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
      @matches.each { |match| match.call(msg) }
    else
      $stderr.puts "receiver notified, but did not apply"
    end
  end
end
