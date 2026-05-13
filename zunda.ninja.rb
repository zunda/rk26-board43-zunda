font = Hash.new
font_h = 7

font["h"] = <<_
+...
+...
+++.
+..+
+..+
+..+
....
_

font["t"] = <<_
.+.
.+.
+++
.+.
.+.
.++
...
_

font["p"] = <<_
...
...
+++
+.+
+.+
+++
+..
_

font["s"] = <<_
....
....
++++
.+..
..+.
++++
....
_

font[":"] = <<_
.
.
+
.
+
.
.
_

font["/"] = <<_
...
...
..+
.+.
+..
...
...
_

font["z"] = <<_
....
....
++++
..+.
.+..
++++
....
_

font["u"] = <<_
....
....
+..+
+..+
+..+
.+++
....
_

font["n"] = <<_
....
....
+++.
+..+
+..+
+..+
....
_

font["d"] = <<_
...+
...+
.+++
+..+
+..+
++++
....
_

font["a"] = <<_
....
....
.+++
+..+
+..+
++++
....
_

font["i"] = <<_
+
.
+
+
+
+
.
_

font["."] = <<_
.
.
.
.
.
+
.
_

font["j"] = <<_
..+
...
..+
..+
..+
..+
++.
_

font[" "] = <<_
.
.
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

require 'ws2812-plus'
led = WS2812.new(pin: Board43::GPIO_LEDOUT, num: 256)

require 'i2c'
require 'lsm6ds3'
i2c = I2C.new(unit: :RP2040_I2C0, sda_pin: Board43::GPIO_IMU_SDA, scl_pin: Board43::GPIO_IMU_SCL, frequency: 400_000)
imu = LSM6DS3.new(i2c)
th = 0.5

w = 16

# colors and geometries
u_rgb = [0xD0, 0xF0, 0x30]

# main loop
sy = -5
gravity = [0, 1]
loop do
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
  end
end
