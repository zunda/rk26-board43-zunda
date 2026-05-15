# qrencode ZUNDA.NINJA -M --foreground=ffffff --background=000000 -o mqr.png
bitmap =  <<_.split("\n").map{|l| l.chars.map{|c| c == "+" ? true : false}}
+++++++.+.+.+.+.
+.....+.........
+.+++.+..++..+..
+.+++.+....+++..
+.+++.+.+++.+++.
+.....+.+...+...
+++++++.+++.+...
........+.....+.
++++.++..++++++.
.+++.+..+..+..+.
+.++ +....+..++.
.+.+.+.+.+.+.++.
++.+.....+++....
.++.....+++...+.
+++.+..++..++.+.
................
_

require 'ws2812-plus'
panel = WS2812.new(pin: Board43::GPIO_LEDOUT, num: 256)

w = 16
white = [255, 255, 255]
black = [0, 0, 0]

w.times do |y|
  w.times do |x|
    panel.set_rgb(y*w + x, *(bitmap[y][x] ? white : black))
  end
end
panel.show
