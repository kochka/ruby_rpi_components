#!/usr/bin/env ruby

# Raspberry Pi - HY-SRF05 ultrasonic distance sensor
# Components : 1 HY-SRF05 sensor, 1 LCD + i2c controller, 2 resistors (330Ω + 470Ω)

require 'bundler'
Bundler.setup
Bundler.require

# Gpio board ids
HY_TRIGGER = 29
HY_ECHO    = 31

puts '-= Raspberry Pi - HY-SRF05 ultrasonic distance sensor =-'.colorize(:cyan).bold

RpiComponents::setup
distance_sensor = RpiComponents::Hysrf05.new(HY_TRIGGER, HY_ECHO)
lcd             = RpiComponents::LcdI2c.new(0x3f)
sleep 10e-3 # Avoid some initialize issues TODO: check all timmings
lcd.on

trap 'SIGINT' do
  lcd.off
  puts "\nBye bye ;)".colorize(:green)
  exit
end

lcd.message 'Distance :'

loop do
  measure = distance_sensor.measure
  next if measure.nil?
  lcd.message "#{'%.2f' % distance_sensor.measure} cm", 2
  sleep 1
end
