require 'ws2812-plus'
panel = WS2812.new(pin: Board43::GPIO_LEDOUT, num: 256)
panel.clear

led = GPIO.new(25, GPIO::OUT)
led.write(1)
