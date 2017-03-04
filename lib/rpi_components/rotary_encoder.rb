module RpiComponents

  class RotaryEncoder
    
    def initialize(gpio_clk, gpio_dt, gpio_ms)
      @gpios = { clk: gpio_clk, dt: gpio_dt,  ms: gpio_ms }
      @rotate_thread = nil
      @press_thread  = nil
      [gpio_clk, gpio_dt].each{|gpio| RPi::GPIO.setup gpio, as: :input }
      RPi::GPIO.setup gpio_ms,  as: :input, pull: :up
      ObjectSpace.define_finalizer self, self.class.finalize(@gpios)
    end

    def self.finalize(gpios)
      proc { gpios.each_value{|gpio| RPi::GPIO.clean_up(gpio) } } 
    end

    def rotate(&block)
      if @press_thread
        @rotate_thread.exit
        @rotate_thread = nil
      end

      @rotate_thread = Thread.new do
        loop do
          state  = nil
          change = false
          while RPi::GPIO.low?(@gpios[:clk])
            state  = RPi::GPIO.high?(@gpios[:dt])
            change = true
            sleep 100e-6
          end

          if change
            yield state ? 1 : -1
            change = false
          end
          sleep 10e-3
        end
      end
    end

    def press(&block)
      if @press_thread
        @press_thread.exit
        @press_thread = nil
      end

      @press_thread = Thread.new do
        loop do
          if RPi::GPIO.low?(@gpios[:ms])
            yield
            sleep 200e-3
          end
          sleep 50e-3
        end
      end
    end

    def wait_press(&block)
      press &block
      @press_thread.join
    end
  end

end
