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

require 'ws2812-plus'
led = WS2812.new(pin: Board43::GPIO_LEDOUT, num: 256)

w = 16

# colors and geometries
u_rgb = [0xD8, 0xE0, 0xA0]

# main loop
sy = -8
loop do
  (-w..(bitmap_w + 1)).each do |sx|
    w.times do |y|
      by = sy + y
      w.times do |x|
        rgb = [0, 0, 0]
        bx = sx + x
        if 0 <= bx and bx < bitmap_w and 0 <= by and by < bitmap_h
          rgb = u_rgb if bitmap[by][bx]
        end
        led.set_rgb(y*w + x, *rgb)
      end
    end
    led.show
  end
end
