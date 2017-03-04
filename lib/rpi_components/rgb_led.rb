module RpiComponents

  class RgbLed
    
    def initialize(gpio_r, gpio_g, gpio_b)
      @gpios  = { r: gpio_r, g: gpio_g, b: gpio_b }
      @pwms   = { r: nil, g: nil, b: nil }
      @color  = 0xFF0000
      @gpios.each do |type, gpio|
        RPi::GPIO.setup gpio, as: :output, initialize: :low
        @pwms[type] = RPi::GPIO::PWM.new(gpio, (type == :b ? 5000 : 2000))
      end
      ObjectSpace.define_finalizer self, self.class.finalize(@gpios)
    end

    def self.finalize(gpios)
      proc { gpios.each_value{|gpio| RPi::GPIO.clean_up gpio } } 
    end

    def on(color=nil)
      @gpios.each_key do |type|
        @pwms[type].start 0
      end
      set_color(color) if color
    end

    def set_color(color, options={})
      fading_threads = []

      { r: (color & 0xFF0000) >> 16, g: (color & 0x00FF00) >> 8, b: color & 0x0000FF }.each do |type, color|
        new_dc = color * 100 / 255

        if options[:fade]
          fading_threads << Thread.new do
            @pwms[type].duty_cycle.send (@pwms[type].duty_cycle < new_dc ? :upto : :downto), new_dc do |dc| 
              next unless dc % 4 == 0 || dc == new_dc
              @pwms[type].duty_cycle = dc
              sleep 80e-3
            end
          end
        else
          @pwms[type].duty_cycle = new_dc
        end
      end

      fading_threads.each(&:join) unless fading_threads.empty?
    end

    def off
      @gpios.each do |type, gpio|
        @pwms[type].stop
        RPi::GPIO.set_low gpio
      end
    end
  end

end
