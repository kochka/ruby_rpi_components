require 'rpi_gpio'
require 'i2c'

%w(
  bme280
  button
  hysrf05
  lcd_i2c
  lcd
  led
  rgb_led
  rotary_encoder
  shift_register
  version
).each {|l| require "rpi_components/#{l}"}

module RpiComponents

  def self.setup(options={})
    options = { numbering: :board, thread_abort_on_exception: true }.merge(options)
    RPi::GPIO.set_numbering options[:numbering]
    Thread.abort_on_exception = options[:thread_abort_on_exception]
  end

end
