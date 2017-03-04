#!/usr/bin/env ruby

# Raspberry Pi - LCD screen using i2c bus
# Components : 1 LCD1602 + i2c controller, 1 rotary encoder

require 'bundler'
Bundler.setup
Bundler.require

require 'i2c'

# Gpio board ids
RE_CLK = 12
RE_DT  = 11
RE_MS  = 40

puts '-= Raspberry Pi - LCD using i2c bus =-'.colorize(:cyan).bold

RpiComponents::setup
lcd    = RpiComponents::LcdI2c.new(0x3f)
rotary = RpiComponents::RotaryEncoder.new(RE_DT, RE_CLK, RE_MS)
lcd.on

lcd.create_char 0, [ 0x8, 0x14, 0x8, 0x3, 0x4, 0x4, 0x3, 0x0 ] # °C icon
lcd.create_char 1, [ 0x0, 0x4, 0xe, 0x1f, 0xa, 0xe, 0xe, 0x0 ] # Home icon

trap 'SIGINT' do
  lcd.off
  puts "\nBye bye ;)".colorize(:green)
  exit
end

mode = 0
counter = 20
lcd.message "Temperature \1"
lcd.message "- #{counter}\0 -", 2

rotary.rotate do |state|
  lcd.message "- #{counter = counter + state}\0 -", 2
end

rotary.wait_press { lcd.toggle }
