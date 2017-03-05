# Raspberry Pi Components

This Gem is a collection of ruby classes made to easily control common components on the Raspberry Pi.
Many examples on how to use them are available in the example directory.

Currently available components are :
 * Led & RGB Led
 * LCD with or without I2C interface
 * Push button
 * Rotary encoder
 * Shift register
 * BME280 & BMP280 (temperature, humidity and atmospheric pressure sensor)
 * HY-SRF05 & HY-SRF04 (Ultrasonic sensor)


### Some quick examples

Before using components, you should do :
```ruby
RpiComponents::setup
```

Make a Led blink or plusate asynchronously :
```ruby
led = RpiComponents::Led.new(11)
led.blink :fast
sleep 5 # Some processing there
led.pulse :slow
sleep 5 # Some processing there
led.off
```

Display a message on a Lcd using I2C bus :

```ruby
lcd = RpiComponents::LcdI2c.new(0x3f)
lcd.message 'Hello'
lcd.message 'World', 2
```

Display data from a BME280 sensor :

```ruby
bme280 = RpiComponents::Bme280.new(0x76)
puts "Temperature: #{'%.2f' % bme280.temp} °C"
puts "Humidity: #{'%.2f' % bme280.humidity} %"
puts "Temperature: #{'%.2f' % bme280.pressure} hPa"
```


### Dependencies

 * [rpi_gpio](https://github.com/ClockVapor/rpi_gpio) for manipulating Raspberry Pi gpios.
 * [i2c-devices](https://github.com/cho45/ruby-i2c-devices) for i2c bus interface.
