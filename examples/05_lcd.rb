#!/usr/bin/env ruby

# Raspberry Pi - LCD screen 1602 experiment
# Components : 1 LCD1602, 1 resistor (2000Ω) on V0 to lower contrast

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

puts '-= Raspberry Pi - LCD 1602 =-'.colorize(:cyan).bold

RpiComponents::setup
lcd = RpiComponents::Lcd.new(LCD_RS, LCD_E, LCD_D4, LCD_D5, LCD_D6, LCD_D7, LCD_A)
lcd.on
lcd.create_char 0, [ 0x0, 0x0, 0xa, 0x1f, 0x1f, 0xe, 0x4, 0x0 ]

trap 'SIGINT' do
  lcd.off
  puts "\nBye bye ;)".colorize(:green)
  exit
end

loop do
  lcd.message "Hello world !"
  lcd.message "Raspi LCD", 2
  sleep(3)
  lcd.message "It can display"
  lcd.message "\0 custom chars \0", 2
  sleep(3)
end
