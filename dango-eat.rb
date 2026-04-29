# Set up the LED matrix
require 'ws2812-plus'
led = WS2812.new(pin: Board43::GPIO_LEDOUT, num: 256)

w = 16
frame_interval = 100 # ms

def dango_alpha(x, y, cx, cy, r)
  d = Math::sqrt((x - cx)**2 + (y - cy)**2)
  if d < r
    return 1
  else
    return 0
  end
end

def stick_alpha(x, y, x1, y1, x2, y2, w)
  d = ((y2 - y1)*x - (x2 - x1)*y + x2*y1 - y2*x1)/Math::sqrt((y2-y1)**2 + (x2-x1)**2)
  d = -d if d < 0
  if d*2 < w
    return 1
  else
    return 0
  end
end

d_rgb = [0x80, 0xB0, 0x20]
s_rgb = [0x30, 0x10, 0x10]

w.times do |y|
  w.times do |x|
    rgb = [0, 0, 0]
    if dango_alpha(x, y, 7.5, 7.5, 3) > 0
      rgb = d_rgb
    elsif stick_alpha(x, y, 3, 3, w-4, w-4, 1.5) > 0
      rgb = s_rgb
    end
    led.set_rgb(y*w + x, *rgb)
  end
end
led.show

