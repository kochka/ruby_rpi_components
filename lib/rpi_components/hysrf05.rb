module RpiComponents

  class Hysrf05

    def initialize(gpio_trigger, gpio_echo)
      @gpios = { trigger: gpio_trigger, echo: gpio_echo }
      @lock  = false

      RPi::GPIO.setup @gpios[:trigger], as: :output, initialize: :low
      RPi::GPIO.setup @gpios[:echo], as: :input 
      ObjectSpace.define_finalizer self, self.class.finalize(@gpios)
    end

    def self.finalize(gpios)
      proc { gpios.each_value{|gpio| RPi::GPIO.clean_up(gpio) } } 
    end

    def measure
      return nil if @lock
      @lock = true

      Timeout::timeout(1) do
        RPi::GPIO.set_high @gpios[:trigger]
        sleep 10e-6
        RPi::GPIO.set_low @gpios[:trigger]

        {} while RPi::GPIO.low?(@gpios[:echo])
        start = Time.now
        {} while RPi::GPIO.high?(@gpios[:echo])
        stop  = Time.now

        (stop - start) * 34039 / 2
      end
    rescue
      nil
    ensure
      @lock = false
    end

    # Take 7 measures, remove 2 max and min, and return the average of the 3 remaining measures
    def accurate_measure
      Array.new(7){ sleep(50e-3); self.measure }.sort.slice(2..4).reduce(:+) / 3
    end

  end

end
