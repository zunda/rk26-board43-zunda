bitmap = Hash.new

bitmap["h"] = <<_
+..
+..
+++
+.+
+.+
_

bitmap["t"] = <<_
.+.
+++
.+.
.+.
.++
_

bitmap["p"] = <<_
...
+++
+.+
+++
+..
_

bitmap["s"] = <<_
...
+++
++.
..+
+++
_

bitmap[":"] = <<_
.
+
.
+
.
_

bitmap["/"] = <<_
...
..+
.+.
+..
...
_

bitmap["z"] = <<_
...
+++
.+.
+..
+++
_

bitmap["u"] = <<_
...
+.+
+.+
+.+
.++
_

bitmap["n"] = <<_
...
+++
+.+
+.+
+.+
_

bitmap["d"] = <<_
..+
..+
+++
+.+
+++
_

bitmap["a"] = <<_
...
.+.
+.+
+++
+.+
_

bitmap["i"] = <<_
+
.
+
+
+
_

bitmap["."] = <<_
.
.
.
.
+
_

bitmap["j"] = <<_
.+
..
.+
.+
++
_

bitmap[" "] = <<_
.
.
.
.
.
_

b =  "ht t p s : // z u n d a . n i n j a".chars.
  map{|c| bitmap[c].split(/\n/)}.
  transpose.
  map{|l| l.join("")}.
  map{|l| l.chars.map{|c| c == "+" ? "##" : "  "}.join}
puts b
