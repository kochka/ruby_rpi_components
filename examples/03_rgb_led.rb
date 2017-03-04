#!/usr/bin/env ruby

# Raspberry Pi - RGB LED experiment
# Components : 1 RGB LED, 3 resistor (220Ω), 1 button

require 'bundler'
Bundler.setup
Bundler.require

# Gpio board ids
LED_R = 40
LED_G = 12
LED_B = 32
BTN   = 11

puts '-= Raspberry Pi - RGB LED =-'.colorize(:cyan).bold

trap 'SIGINT' do
  puts "\nBye bye ;)".colorize(:green)
  exit
end

mode = 0
thread = nil
RpiComponents::setup
led = RpiComponents::RgbLed.new(LED_R, LED_G, LED_B)

RpiComponents::Button.new(BTN).wait_press do
  thread.exit if thread && thread.alive?
  led.on
  mode = (mode + 1) % 6
  case mode
    when 1
      puts 'LED is red'.colorize(:red)
      led.set_color 0xFF0000
    when 2
      puts 'LED is green'.colorize(:green)
      led.set_color  0x00FF00
    when 3
      puts 'LED is blue'.colorize(:blue)
      led.set_color 0x0000FF
    when 4
      puts 'Rainbow mode'
      thread = Thread.new do
        loop do
          [0xFF0000, 0xFF7F00, 0xFFFF00, 0x00FF00, 0x00FFFF, 0x0000FF, 0x8B00FF].each do |color|
            led.set_color color
            sleep 0.5
          end
        end
      end
    when 5
      puts 'Fading mode'
      thread = Thread.new do
        loop { [0xFF0000, 0x00FF00, 0x0000FF].each{|color| led.set_color color, fade: true } }
      end
    else 
      puts 'LED off'.colorize(:red)
      led.off
  end
end
