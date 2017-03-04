# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rpi_components/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'rpi_components'
  gem.version       = RpiComponents::VERSION
  gem.summary       = 'Objects to control components on the Raspberry Pi'
  gem.description   = 'Objects to control components easily on the Raspberry Pi (sensors, displays, leds, buttons, ...)'
  gem.homepage      = ''

  gem.authors       = ['Sébastien Vrillaud']
  gem.email         = ['kochka@gmail.com']

  gem.license       = 'MIT'

  gem.files         = `git ls-files | grep -Ev '^(examples)'`.split("\n")
  gem.test_files    = []
  gem.require_paths = ['lib']
  

  gem.add_dependency 'rpi_gpio', '~> 0.3.2'
  gem.add_dependency 'i2c-devices', '~> 0.0.6'
end
