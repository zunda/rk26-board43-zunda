# Set up the LED matrix
require 'ws2812-plus'
led = WS2812.new(pin: Board43::GPIO_LEDOUT, num: 256)

w = 16
frame_interval = 100 # ms

def rgba(r, g, b, a)
  return [r*a, g*a, b*a].map{|x| x.round}
end

def dango_alpha(x, y, cx, cy, r)
  d = Math::sqrt((x - cx)**2 + (y - cy)**2)
  if d < r
    return 1.0
  else
    return 0.0
  end
end

loop do
  w.times do |y|
    w.times do |x|
      a = dango_alpha(x, y, 7.5, 7.5, 2.1)
      p a
      rgb = rgba(0x80, 0xB0, 0x20, a)
      led.set_rgb(y*w + x, *rgb)
    end
  end
  led.show

  sleep_ms frame_interval
end
