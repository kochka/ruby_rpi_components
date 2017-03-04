module RpiComponents

  class Lcd
    LINE_1  = 0x80
    LINE_2  = 0xC0
    E_DELAY = 100e-6

    # Optionnal A pin to control backlight
    def initialize(gpio_rs, gpio_e, gpio_d4, gpio_d5, gpio_d6, gpio_d7, gpio_a = nil)
      @gpios = { rs: gpio_rs, e: gpio_e, d4: gpio_d4, d5: gpio_d5, d6: gpio_d6, d7: gpio_d7, a: gpio_a }
      @dx    = [ @gpios[:d7], @gpios[:d6], @gpios[:d5], @gpios[:d4] ]
      @gpios.each_value{|gpio| RPi::GPIO.setup(gpio, as: :output) if gpio }
      ObjectSpace.define_finalizer self, self.class.finalize(@gpios)

      # Initialise display
      command 0x33 # 110011 Initialize
      command 0x32 # 110010 Initialize
      command 0x06 # 000110 Cursor direction
      command 0x0C # 001100 Display On, Cursor Off, Blink Off
      command 0x28 # 101000 Data length, number of lines, font size
      clear
    end

    def self.finalize(gpios)
      proc { gpios.each_value{|gpio| RPi::GPIO.clean_up(gpio) if gpio } } 
    end

    def command(val)
      RPi::GPIO.set_low @gpios[:rs]
      write val
    end

    def clear
      command 0x01 # 000001 Clear display
    end

    def char(char)
      RPi::GPIO.set_high @gpios[:rs]
      write char.ord
    end

    def message(message, line=1)
      command(line == 1 ? LINE_1 : LINE_2)
      message.ljust(16).each_char {|c| char c }
    end

    def toggle(state)
      command(state ? 0xC : 0x8)
      RPi::GPIO.send(state ? :set_high : :set_low, @gpios[:a]) if @gpios[:a]
    end

    def on
      toggle true
    end

    def off
      toggle false
    end

    def create_char(location, charmap)
      raise ArgumentError unless charmap.count == 8
      location &= 0x7 # Limited to 8 locations 0-7
      command(0x40 | (location << 3))
      charmap.each {|c| char c }
    end

    private

    def write(val)
      # Write high bits then low bits
      8.times do |shift|
        mask = 0x80 >> shift
        RPi::GPIO.send (val & mask == mask ? :set_high : :set_low), @dx[shift % 4]

        # Pulse enable
        if shift % 4 == 3
          sleep E_DELAY
          RPi::GPIO.set_high @gpios[:e]
          sleep E_DELAY
          RPi::GPIO.set_low @gpios[:e]
          sleep E_DELAY
        end
      end
    end
    
  end

end
