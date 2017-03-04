#!/usr/bin/env ruby

# Raspberry Pi - Rotary Encoder experiment
# Components : 1 rotary encoder

require 'bundler'
Bundler.setup
Bundler.require

# Gpio board ids
RE_DT  = 11
RE_CLK = 12
RE_MS  = 40

puts '-= Raspberry Pi - Rotary Encoder =-'.colorize(:cyan).bold

trap 'SIGINT' do
  puts "\nBye bye ;)".colorize(:green)
  exit
end

STDOUT.sync = true
RpiComponents::setup
rotary = RpiComponents::RotaryEncoder.new(RE_DT, RE_CLK, RE_MS)
counter = 0

rotary.rotate do |state|
  print "Counter : #{counter = counter + state}      \r"
  STDOUT.flush
end

rotary.wait_press do
  puts "PRESSED"
end
