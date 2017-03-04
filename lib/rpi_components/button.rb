module RpiComponents

  class Button
    def initialize(gpio)
      @gpio   = gpio
      @thread = nil
      RPi::GPIO.setup @gpio, as: :input, pull: :up
      ObjectSpace.define_finalizer self, self.class.finalize(@gpio)
    end

    def self.finalize(gpio)
      proc { RPi::GPIO.clean_up gpio }
    end

    def press(&block)
      if @thread
        @thread.exit
        @thread = nil
      end

      @thread = Thread.new do
        loop do
          if RPi::GPIO.low?(@gpio)
            yield
            sleep 200e-3
          end
          sleep 50e-3
        end
      end
    end

    def wait_press(&block)
      press &block
      @thread.join
    end
  end

end
