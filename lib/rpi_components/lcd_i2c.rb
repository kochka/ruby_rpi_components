module RpiComponents

  class LcdI2c < I2CDevice
    LINES   = { 1 => 0x80, 2 => 0xC0, 3 => 0x94, 4 => 0xD4 }
    ENABLE  = 0x04 # Enable bit
    E_DELAY = 100e-6
    
    def initialize(i2c_address)
      super address: i2c_address
      @on = true
      @backlight = 0x8

      # Initialise display
      command 0x33 # 110011 Initialize
      command 0x32 # 110010 Initialize
      command 0x06 # 000110 Cursor direction
      command 0x0C # 001100 Display On, Cursor Off, Blink Off
      command 0x28 # 101000 Data length, number of lines, font size
      clear
    end

    def command(val)
      write 0, val
    end

    def clear
      command 0x01 # 000001 Clear display
    end

    def char(char)
      write 1, char.ord
    end

    def message(message, line=1)
      command LINES[line]
      message.ljust(16).each_char {|c| char c }
    end

    def toggle
      @on ^= true
      if on?
        @backlight = 0x8
        command 0xC
      else
        @backlight = 0
        command 0x8
      end
    end

    def on
      toggle unless on?
    end

    def off
      toggle if on?
    end

    def on?
      @on
    end

    def create_char(location, charmap)
      raise ArgumentError unless charmap.count == 8
      location &= 0x7 # Limited to 8 locations 0-7
      command(0x40 | (location << 3))
      charmap.each {|c| char c }
    end

    private

    def write(mode, val)
      # Write high bits then low bits
      2.times do |n|
        bits = mode | ((val<<(n*4)) & 0xF0) | @backlight
        i2cset bits

        sleep E_DELAY
        i2cset bits | ENABLE
        sleep E_DELAY
        i2cset bits & ~ENABLE
        sleep E_DELAY
      end
    end
  end

end
