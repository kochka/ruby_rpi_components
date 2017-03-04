#!/usr/bin/env ruby

# Raspberry Pi - LCD screen + Rotary Encoder experiment
# Components : 1 LCD1602, 2x1KΩ resistor in serie on V0 to lower contrast, 1 rotary encoder

require 'bundler'
Bundler.setup
Bundler.require

# Gpio board ids
LCD_RS  = 32
LCD_E   = 36
LCD_D4  = 31
LCD_D5  = 33
LCD_D6  = 35
LCD_D7  = 37
LCD_A   = 29

RE_DT  = 11
RE_CLK = 12
RE_MS  = 40

puts '-= Raspberry Pi - LCD + Rotary =-'.colorize(:cyan).bold

RpiComponents::setup
lcd    = RpiComponents::Lcd.new(LCD_RS, LCD_E, LCD_D4, LCD_D5, LCD_D6, LCD_D7, LCD_A)
rotary = RpiComponents::RotaryEncoder.new(RE_DT, RE_CLK, RE_MS)
lcd.on
lcd_on = true
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

rotary.wait_press do
  if lcd_on == true
    lcd.off
    lcd_on = false
  else
    lcd.on
    lcd_on = true
  end
end
