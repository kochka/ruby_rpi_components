#!/usr/bin/env ruby

# Raspberry Pi - BME280 temperature & pressure sensor
# Components : 1 BME280, 1 LCD1602 + i2c controller

require 'bundler'
Bundler.setup
Bundler.require

puts '-= Raspberry Pi - BMP280 Sensor =-'.colorize(:cyan).bold

RpiComponents::setup
bme280 = RpiComponents::Bme280.new(0x76)
lcd    = RpiComponents::LcdI2c.new(0x3f)
sleep 10e-3 # Avoid some initialize issues TODO: check all timmings
lcd.on

trap 'SIGINT' do
  lcd.off
  puts "\nBye bye ;)".colorize(:green)
  exit
end

lcd.create_char 0, [ 0x8, 0x14, 0x8, 0x3, 0x4, 0x4, 0x3, 0x0 ] # °C icon
lcd.create_char 1, [ 0x0, 0x4, 0xe, 0x1f, 0xa, 0xe, 0xe, 0x0 ] # Home icon

loop do
  bme280.update
  lcd.message "\1 #{'%.2f' % bmp280.temp}\0  #{'%.2f' % bmp280.humidity}%"
  lcd.message "  #{'%.2f' % bmp280.pressure} hPa", 2
  sleep 1
end
