# Show dango being eaten and URL. Push SW3 to quicker switch between them.

# bitmap for URL
font = Hash.new
font_h = 5

font["h"] = <<_
+..
+..
+++
+.+
+.+
_

font["t"] = <<_
.+.
+++
.+.
.+.
.++
_

font["p"] = <<_
...
+++
+.+
+++
+..
_

font["s"] = <<_
...
+++
++.
..+
+++
_

font[":"] = <<_
.
+
.
+
.
_

font["/"] = <<_
...
..+
.+.
+..
...
_

font["z"] = <<_
...
+++
.+.
+..
+++
_

font["u"] = <<_
...
+.+
+.+
+.+
.++
_

font["n"] = <<_
...
+++
+.+
+.+
+.+
_

font["d"] = <<_
..+
..+
+++
+.+
+++
_

font["a"] = <<_
...
.+.
+.+
+++
+.+
_

font["i"] = <<_
+
.
+
+
+
_

font["."] = <<_
.
.
.
.
+
_

font["j"] = <<_
.+
..
.+
.+
++
_

font[" "] = <<_
.
.
.
.
.
_

# Array#transpose and Array#flatten are not on PicoRuby
t =  "ht t p s : // z u n d a . n i n j a".chars.
  map{|c| font[c].split("\n").map{|l| l.chars.map{|p| p == "+" ? true : false}}}
bitmap_w = 0
t.map{|c| c.first}.each do |l|
  bitmap_w += l.size
end
bitmap_h = font_h
bitmap = Array.new(bitmap_h)
bitmap_h.times do |y|
  u = Array.new
  t.map{|c| c[y]}.each do |a|
    a.each do |v|
      u << v
    end
  end
  bitmap[y] = Array.new
  bitmap_w.times do |x|
    bitmap[y][x] = u[x]
  end
end

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
u_rgb = [0xD0, 0xF0, 0x30]
pause = 500 # ms
sy = -8
gravity = [0, 1]

# LED
require 'ws2812-plus'
led = WS2812.new(pin: Board43::GPIO_LEDOUT, num: 256)
w = 16

# Accelerometer
require 'i2c'
require 'lsm6ds3'
i2c = I2C.new(unit: :RP2040_I2C0, sda_pin: Board43::GPIO_IMU_SDA, scl_pin: Board43::GPIO_IMU_SCL, frequency: 400_000)
imu = LSM6DS3.new(i2c)
th = 0.5

# Button
require 'irq'

button = {
  pushed: false
}
GPIO.new(Board43::GPIO_SW3, GPIO::IN | GPIO::PULL_UP).
irq(GPIO::EDGE_FALL, debounce: 500, capture: button) do |gpio, event, cap|
  cap[:pushed] = true
end

# main loop
loop do

  # eat dango
  6.times do
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
      IRQ.process
      break if button[:pushed]
      case f
      when 2
        sleep_ms pause
      when 7
        10.times do
          sleep_ms pause
          IRQ.process
          break if button[:pushed]
        end
      end
    end
    break if button[:pushed]
  end
  button[:pushed] = false

  # URL
  3.times do
    (-w..(bitmap_w + 1)).each do |sx|
      acc = imu.read_acceleration
      if acc[0]*acc[0] > acc[1]*acc[1]
        if acc[0] < -th
          gravity = [0, -1]
        elsif th < acc[0]
          gravity = [0, 1]
        end
      else
        if acc[1] < -th
          gravity = [-1, 0]
        elsif th < acc[1]
          gravity = [1, 0]
        end
      end
      w.times do |y|
        by = sy + y
        w.times do |x|
          rgb = [0, 0, 0]
          bx = sx + x
          if 0 <= bx and bx < bitmap_w and 0 <= by and by < bitmap_h
            rgb = u_rgb if bitmap[by][bx]
          end
          case gravity[1]
          when -1
            dx = w - 1 - x
            dy = w - 1 - y
          when 1
            dx = x
            dy = y
          else
            case gravity[0]
            when -1
              dy = x
              dx = w - 1 - y
            when 1
              dy = w - 1 - x
              dx = y
            else
              dx = x
              dy = y
            end
          end
          led.set_rgb(dy*w + dx, *rgb)
        end
      end
      led.show
      IRQ.process
      break if button[:pushed]
    end
    break if button[:pushed]
  end
  button[:pushed] = false
end
