module RpiComponents

  class Led
    
    def initialize(gpio)
      @gpio   = gpio
      @state  = false
      @thread = nil
      @pwm    = nil
      RPi::GPIO.setup @gpio, as: :output, initialize: :low
      ObjectSpace.define_finalizer self, self.class.finalize(@gpio)
    end

    def self.finalize(gpio)
      proc { RPi::GPIO.clean_up gpio }
    end

    # Optionnal state
    def toggle(state = nil)
      @state = state.nil? ? !@state : state
      RPi::GPIO.send (@state ? :set_high : :set_low), @gpio
    end

    def on
      stop_running_animation
      toggle true
    end

    def off
      stop_running_animation
      toggle false
    end

    def on?
      @state
    end

    def blink(speed = :slow)
      t = self.class.blinking_speeds[speed]
      stop_running_animation
      @thread = Thread.new { loop { toggle; sleep t } }
    end

    def self.blinking_speeds
      { slow: 600e-3, moderate: 400e-3, fast: 200e-3 }
    end

    def pulse(speed = :slow)
      t = self.class.pulsing_speeds[speed]
      stop_running_animation
      @pwm     ||= RPi::GPIO::PWM.new(@gpio, 1000)
      enumerator = 0.step(100, 4)
      backward   = false
      @pwm.start 0
      @state = true
      @thread = Thread.new do
        loop do
          enumerator.send (backward ? :reverse_each : :each) do |dc|
            @pwm.duty_cycle = dc
            sleep t
          end
          backward ^= true
        end
      end
    end

    def self.pulsing_speeds
      { slow: 40e-3, moderate: 30e-3, fast: 20e-3 }
    end

    def animated?
      !@thread.nil?
    end

    private

    def stop_running_animation
      if animated?
        if @pwm && @pwm.running?
          @pwm.stop
          sleep 50e-3 # Prevent crashing if another pwm animation start right after
        end
        @thread.exit
        @thread = nil
        true
      else
        false
      end
    end
  end

end
