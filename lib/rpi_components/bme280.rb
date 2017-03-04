module RpiComponents

  class Bme280 < I2CDevice
    
    attr_reader :temp, :pressure, :humidity

    def initialize(i2c_address)
      super address: i2c_address

      @mode                = 1      
      @oversample_pressure = 2
      @oversample_temp     = 2
      @oversample_humidity = 2

      load_calibration
      update
    end

    def chip_info
      chip_id, chip_version = i2cget(0xd0, 2).unpack('C*')
      { chip_id: chip_id, chip_version: chip_version }
    end

    def update
      i2cset 0xf2, @oversample_humidity
      i2cset 0xf4, (@oversample_temp << 5 | @oversample_pressure << 2 | @mode)

      d = i2cget(0xf7, 8).unpack('C*')
      @raw_pressure = (d[0] << 12) | (d[1] << 4) | (d[2] >> 4)
      @raw_temp     = (d[3] << 12) | (d[4] << 4) | (d[5] >> 4)
      @raw_humidity = (d[6] << 8) | d[7]
    
      # Temp
      v1 = (((@raw_temp >> 3) - (@cal[:T1] << 1)) * @cal[:T2]) >> 11
      v2 = (((((@raw_temp >> 4) - @cal[:T1]) * ((@raw_temp >> 4) - @cal[:T1])) >> 12) * @cal[:T3]) >> 14
      t_fine = v1 + v2
      @temp = ((t_fine * 5 + 128) >> 8) / 100.0
    
      # Pressure
      v1 = t_fine / 2.0 - 64000.0
      v2 = v1 * v1 * @cal[:P6] / 32768.0
      v2 = v2 + v1 * @cal[:P5] * 2.0
      v2 = v2 / 4.0 + @cal[:P4] * 65536.0
      v1 = (@cal[:P3] * v1 * v1 / 524288.0 + @cal[:P2] * v1) / 524288.0
      v1 = (1.0 + v1 / 32768.0) * @cal[:P1]

      if v1.zero?
        @pressure = 0.0
      else
        pressure = 1048576.0 - @raw_pressure
        pressure = ((pressure - v2 / 4096.0) * 6250.0) / v1
        v1 = @cal[:P9] * pressure * pressure / 2147483648.0
        v2 = pressure * @cal[:P8] / 32768.0
        pressure = pressure + (v1 + v2 + @cal[:P7]) / 16.0
        @pressure = pressure / 100.0
      end

      # Humidity
      humidity = t_fine - 76800.0
      humidity = (@raw_humidity - (@cal[:H4] * 64.0 + @cal[:H5] / 16384.0 * humidity)) * (@cal[:H2] / 65536.0 * (1.0 + @cal[:H6] / 67108864.0 * humidity * (1.0 + @cal[:H3] / 67108864.0 * humidity)))
      @humidity = humidity * (1.0 - @cal[:H1] * humidity / 524288.0)
      if humidity > 100
        @humidity = 100
      elsif humidity < 0
        @humidity = 0
      end

      self
    end

    private

    def load_calibration
      @cal = {}
      
      i2cget(0x88, 24).unpack('SssSssssssss').each_with_index do |v, i|
        @cal[(i < 3 ? "T#{i+1}" : "P#{i-2}").to_sym] = v
      end

      @cal[:H1] = i2cget(0xa1, 1).unpack('C').first
      
      ct = i2cget(0xe1, 7).unpack('sCcccCc')
      @cal[:H2] = ct[0]
      @cal[:H3] = ct[1]

      @cal[:H4] = (ct[2] << 24) >> 20
      @cal[:H4] |= ct[3] & 0x0F

      @cal[:H5] = (ct[4] << 24) >> 20
      @cal[:H5] |= ct[3] >> 4 & 0x0F
      
      @cal[:H6] = ct[5]
      
      @cal
    end
  end

end
