require 'ws2812-plus'
led = WS2812.new(pin: Board43::GPIO_LEDOUT, num: 256)

w = 16
pause = 500 # ms

# one where dango is
def dango(x, y, cx, cy, r)
  if Math::sqrt((x - cx)**2 + (y - cy)**2) < r
    return 1
  else
    return 0
  end
end

# zero where dango is eaten
def eat(x, y, cx, cy, r)
  return 1 - dango(x, y, cx, cy, r)
end

# oen where stick is
def stick(x, y, x1, y1, x2, y2, w)
  d = ((y2 - y1)*x - (x2 - x1)*y + x2*y1 - y2*x1)/Math::sqrt((y2-y1)**2 + (x2-x1)**2)
  d = -d if d < 0
  if d*2 < w
    return 1
  else
    return 0
  end
end

# colors and geometries
d_rgb = [0x80, 0xB0, 0x20]
d_radius = 3.5
s_rgb = [0x30, 0x10, 0x10]
s_width = 1.5

# main loop
loop do
  10.times do |f|
    # shift of positions of dangos
    shift = 0
    case f
    when 3..6
      shift = f - 7
    end

    w.times do |y|
      w.times do |x|
        rgb = [0, 0, 0]

        top = dango(x, y, 12 + shift, 12 + shift, d_radius)
        case f
        when 1
          top *= eat(x, y, 14, 15, d_radius)
        when 2
          top *= eat(x, y, 12, 12, d_radius)
        end

        if top > 0
          rgb = d_rgb
        elsif dango(x, y, 8 + shift, 8 + shift, d_radius) > 0
          rgb = d_rgb
        elsif dango(x, y, 4 + shift, 4 + shift, d_radius) > 0
          rgb = d_rgb
        elsif stick(x, y, 3, 3, w - 4, w - 4, s_width) > 0
          rgb = s_rgb
        end
        led.set_rgb(y*w + x, *rgb)
      end
    end
    led.show
    case f
    when 2
      sleep_ms pause
    when 7
      sleep_ms pause*10
    end
  end
end
