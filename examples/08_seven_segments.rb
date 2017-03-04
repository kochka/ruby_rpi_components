#!/usr/bin/env ruby

# Raspberry Pi - Seven segments displays
# Components : 2 x 7-segments displays, 2 x 220KΩ resistors, 2 x shift registers (74HC595)

require 'bundler'
Bundler.setup
Bundler.require

# Gpio board ids
SR_DS = 31
SR_SH = 33
SR_ST = 32

puts '-= Raspberry Pi -Seven segments displays =-'.colorize(:cyan).bold

RpiComponents::setup
NUMBERS = [0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f, 0x6f]

trap 'SIGINT' do
  puts "\nBye bye ;)".colorize(:green)
  exit
end

shift_register = RpiComponents::ShiftRegister.new(SR_DS, SR_SH, SR_ST)
shift_register.reset 2

100.times do |x|
  shift_register.set NUMBERS[x/10], NUMBERS[x%10]
  sleep 100e-3
end

5.times do
  shift_register.set NUMBERS[0], NUMBERS[0]
  sleep 300e-3
  shift_register.reset 2
  sleep 300e-3
end
