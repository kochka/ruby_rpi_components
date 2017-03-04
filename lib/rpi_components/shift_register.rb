module RpiComponents

  class ShiftRegister

    def initialize(gpio_ds, gpio_sh, gpio_st)
      @gpios = { ds: gpio_ds, sh: gpio_sh,  st: gpio_st }

      @gpios.each_value{|gpio| RPi::GPIO.setup gpio, as: :output, initialize: :low }
      ObjectSpace.define_finalizer self, self.class.finalize(@gpios)
    end

    def self.finalize(gpios)
      proc { gpios.each_value{|gpio| RPi::GPIO.clean_up(gpio) } } 
    end

    # Set one or an array of dasy chained regs
    def set(*regs)
      regs.reverse.each do |reg|
        8.times do |shift|
          RPi::GPIO.send (reg << shift & 0x80 == 0 ? :set_low : :set_high), @gpios[:ds]
          pulse :sh
        end
      end
      
      pulse :st
    end

    def reset(reg_n=1)
      set *Array.new(reg_n, 0)
    end

    private

    def pulse(gpio)
      RPi::GPIO.set_high @gpios[gpio]
      sleep 1e-3
      RPi::GPIO.set_low  @gpios[gpio]
    end
  end

end
