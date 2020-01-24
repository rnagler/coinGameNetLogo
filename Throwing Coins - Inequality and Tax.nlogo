; Throwing Coins - Inequality and Tax.nlogo; Rupert Nagler Jan 2020

globals [
  gini-index-reserve ; actual Gini %
  lorenz-points ; list of Lorenz points
  coins ; number of thrown coins
  tails ; number of tails - results
]

turtles-own [
  wealth ; actual wealth of turtle
  tax ; actual amount of wealth tax turtle has payed
]

to setup
  clear-all
  ask patches [set pcolor 104]
  setup-turtles
  set coins 0
  set tails 0
  update-lorenz-and-gini
  reset-ticks
end

to setup-turtles
  create-turtles num-turtles [
    set heading 0
    set color yellow
    set shape "circle"
    ifelse random-init-wealth? [; random distributuion
      set wealth random-float init-wealth
    ][; equal distribution
      set wealth init-wealth
    ]
    set tax 0
    ; place turtle on plain according id(own) on x-axsis and wealth on y-axsis
    setxy (who / num-turtles * 100) wealth
  ]
end

to go
  playing
  taxing
  move-turtles
  if not any? turtles [stop]
  update-lorenz-and-gini
  tick
end

to playing ; each turtle throws coin
  ask turtles [ ; leverage is the fraction of wealth to bet
    set wealth win (wealth * leverage) + wealth * (1 - leverage); compute new wealth on thrown coin
  ]
end

to-report win [stake] ; function to compute new wealth according to coin throw with multiplicative and additive win
  let m mult-heads ; initialise with win factors
  let a add-heads
  set coins coins + 1
  if one-of list false true [ ; throw coin, in case loose change to loose factors
    set m mult-tails
    set a add-tails
    set tails tails + 1
  ]
  report (stake * m) + a
end

to taxing
  if tax-factor > 0 [ ; do we have to compute taxes?
    let notax-turtles [self] of no-turtles ; empty unsorted list of turtles
    let sumtax 0
    ask turtles [ ; pay wealth tax
      ifelse wealth > tax-limit [ ; is there a tax to pay?
          set tax wealth * tax-factor
          set wealth wealth - tax ; turtle pays tax
          set sumtax sumtax + tax ; add to total tax collected
        ] [
          set tax 0
          set notax-turtles lput self notax-turtles ; add to list of notax-turtles
        ]
    ]
    let count-notax-turtles length notax-turtles ; number of notax-turtles
    ifelse redist-all? or (count-notax-turtles <= 0) [ ; do we have to redistribute to all turtles?
      let mtax (sumtax / count turtles) ; divide total tax between all turtles
      ask turtles [ ; redistribute tax to all turtles
        set wealth wealth + mtax ; redistribute
      ]
    ] [; divide total tax between all no-tax-turtles
      let mtax (sumtax / count-notax-turtles)
      ask turtle-set notax-turtles [ ; changes list into agentset
        set wealth wealth + mtax ; redistribute
      ]
    ]
  ]
end

to move-turtles ; according to new wealth
  ask turtles [
    if turtles-die? [ ; should bancrupt turtles die?
      if wealth < 1.0E-10 [die]
    ]
    set ycor (wealth + min [wealth] of turtles) / max [wealth] of turtles * 100
  ]
end

to update-lorenz-and-gini
  ; recompute value of gini-index-reserve and the points in lorenz-points for the Lorenz and Gini-Index plots
  let sorted-wealths sort [wealth] of turtles
  let total-wealth sum sorted-wealths
  let wealth-sum-so-far 0
  let index 0
  let c-turtles count turtles
  set gini-index-reserve 0
  set lorenz-points []
  ; now actually plot the Lorenz curve -- along the way, we also calculate the Gini index
  repeat c-turtles [
    set wealth-sum-so-far (wealth-sum-so-far + item index sorted-wealths)
    set lorenz-points lput ((wealth-sum-so-far / total-wealth) * 100) lorenz-points
    set index (index + 1)
    set gini-index-reserve gini-index-reserve + (index / c-turtles) - (wealth-sum-so-far / total-wealth)
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
370
10
883
524
-1
-1
5.0
1
10
1
1
1
0
1
1
1
0
100
0
100
1
1
1
ticks
30.0

BUTTON
180
10
235
43
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
240
10
295
43
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
180
95
352
128
mult-heads
mult-heads
0.1
10.0
1.5
0.1
1
NIL
HORIZONTAL

SLIDER
0
95
172
128
mult-tails
mult-tails
0.1
10.0
0.6
0.1
1
NIL
HORIZONTAL

MONITOR
880
480
1075
525
min-wealth
min [wealth] of turtles
17
1
11

MONITOR
880
10
1080
55
max-wealth
max [wealth] of turtles
17
1
11

SLIDER
180
135
352
168
add-heads
add-heads
-1
1
0.0
0.1
1
NIL
HORIZONTAL

SLIDER
0
135
172
168
add-tails
add-tails
-1
1
0.0
0.1
1
NIL
HORIZONTAL

PLOT
0
275
370
570
Plot min max mean and median wealth
time
log 10 wealth 
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"min" 1.0 0 -13840069 true "" "let aw min [wealth] of turtles\nifelse (aw > 1.0E-12)\n [plot-pen-down plot log aw 10]\n [plot-pen-up plot 0]"
"max" 1.0 0 -2674135 true "" "let aw max [wealth] of turtles\nifelse (aw > 1.0E-12)\n [plot-pen-down plot log aw 10]\n [plot-pen-up plot 0]"
"mean" 1.0 0 -4079321 true "" "let aw mean [wealth] of turtles\nifelse (aw > 1.0E-12)\n [plot-pen-down plot log aw 10]\n [plot-pen-up plot 0]"
"med" 1.0 0 -11033397 true "" "let aw median [wealth] of turtles\nifelse (aw > 1.0E-12)\n [plot-pen-down plot log aw 10]\n [plot-pen-up plot 0]"

PLOT
1145
10
1495
570
Histogram wealth distribution
wealth per bin
# turtles in bin
0.0
100.0
0.0
1000.0
false
false
"set-plot-pen-mode 1\nset-plot-y-range 0 num-turtles\nset-histogram-num-bars 20\n" "set-plot-x-range (round (min [wealth] of turtles)) (round (max [wealth] of turtles + 1))\nset-plot-y-range 0 count turtles\nset-histogram-num-bars 20"
PENS
"live-turtles" 1.0 1 -16777216 true "" "histogram [wealth] of turtles"

MONITOR
0
225
170
270
mean-wealth
mean [wealth] of turtles
2
1
11

SLIDER
970
525
1142
558
tax-factor
tax-factor
0
1
0.0
0.1
1
NIL
HORIZONTAL

MONITOR
700
530
840
575
mean-tax
mean [tax] of turtles
3
1
11

SLIDER
970
560
1142
593
tax-limit
tax-limit
0
1000
500.0
100
1
NIL
HORIZONTAL

BUTTON
295
10
350
43
go 1
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
0
10
172
43
num-turtles
num-turtles
100
3000
1000.0
100
1
NIL
HORIZONTAL

MONITOR
595
530
685
575
turtles alive
count turtles
17
1
11

MONITOR
500
530
593
575
turtles dead
num-turtles - count turtles
17
1
11

SWITCH
375
530
498
563
turtles-die?
turtles-die?
0
1
-1000

MONITOR
0
175
75
220
# coins
coins
17
1
11

MONITOR
75
175
175
220
coins/tails
tails / coins
17
1
11

PLOT
890
60
1140
225
Lorenz Curve
% Population
% total Wealth
0.0
100.0
0.0
100.0
false
false
"" ""
PENS
"Lorenz" 1.0 0 -2674135 true "" "plot-pen-reset\nset-plot-pen-interval 100 / count turtles\nplot 0\nforeach lorenz-points plot"
"pen-1" 100.0 0 -7500403 true "plot 0 plot 100" ""

PLOT
890
235
1140
470
Gini-Index v. Time
Time
Gini
0.0
50.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -5298144 true "" "plot (gini-index-reserve / count turtles) / 0.5"

SWITCH
0
50
170
83
random-init-wealth?
random-init-wealth?
1
1
-1000

SLIDER
180
50
350
83
init-wealth
init-wealth
1
100
1.0
1
1
NIL
HORIZONTAL

SWITCH
845
530
962
563
redist-all?
redist-all?
0
1
-1000

SLIDER
180
180
352
213
leverage
leverage
0.1
5.0
1.0
0.1
1
NIL
HORIZONTAL

MONITOR
180
225
350
270
median wealth
median [wealth] of turtles
17
1
11

@#$#@#$#@
# Throwing Coins - Inequality and Tax.nlogo

Author: Rupert Nagler, Jan 2020, nagler@idi.co.at

## WHAT IS IT?

Simulation of a coin game based on multiplicative growth. 
Based on the paper "**Ergodicity Economics**", published 2018 by Ole Peters and Alexander Adamou @ London Mathematical Laboratory:
_"We toss a coin, and if it comes up heads we increase your monetary wealth by 50%; if it comes up tails we reduce your wealth by 40%. We’re not only doing this once, we will do it many times. Would you submit your wealth to the dynamic our game will impose on it?"_, see:
https://ergodicityeconomics.files.wordpress.com/2018/06/ergodicity_economics.pdf

Our turtles assume they will get rich playing this game. They are presented in their blue 2d-world as yellow circles. Their vertical position reflects their actual wealth, the horizontal position is their unique "who" number. 
You will experience their fate mislead by a **wrong ergodic hypothesis** for multiplicative growth - like most traditional economists. You can explore the intrinsic effects why **"the rich get richer"** and the benefits of **cooperation** induced by a form of wealth-tax.
Lorenz Curve, Gini Coefficient and a histogram show the current distribution of their wealth.

## HOW IT WORKS

All turtles play the coin game. Each of them throws a coin at each tick:
If heads are shown, individual wealth is multiplied by "mult-heads" and "add-heads" is added.
If tails are shown, individual wealth is multiplied by "mult-tails" and "add-tails" is added.
After all turtles have thrown their coins and their wealth was adopted, some redistribution in the form of a wealth-tax may be applied: If "tax-factor" is > 0 and wealth is > "tax-limit" a wealth tax (wealth * tax-factor) is subtracted. Then the collected wealth tax is redistributed evenly to all turtles or to the poor turtles below tax-limit, depending on the switch "redist-all?".
So you can simulate the effects of cooperation sharing the risk between players.

## HOW TO USE IT

* Use the sliders to control the number of turtles "num-turtles" and the initial wealth "init-wealth".
* If you switch "random-init-wealth?" to "off" each turtle receives the equal "init-wealth" wealth; if you switch "random-init-wealth?" to "on" each turtle receives a random wealth between 1 and  "init-wealth". 
* Set the fraction of actual wealth to bet by "leverage" (default: 1.0). 
* Set the multiplicative factors "mult-heads", "mult-tails" (defaults: 0.6, 1.5) with which your bet will be multiplied in case of win / loss.
* Set the additive values "add-heads", "add-tails" (defaults: 0.0, 0.0) which will be added to your bet in case of win / loss.
* Optional set "tax-factor", "tax-limit", and "redist-all?"
* If you want bancrupt turtles to die, set "turtles-die?" to on.
* To setup the simulation, press "setup".
* To play one round press "go-1", to play as long as you wish, press "go".

## THINGS TO NOTICE

* You see all turtles sitting on the blue world area. Each turtle will go up or down vertically dependent of its current wealth after each tick.
* In the wealth-plot you see min, max, mean and median of the turtles wealth on a log10 scale.
* In the wealth-distribution histogramm you see the number of turtles in different classes of wealth.
* In the Lorenz Plot you see the actual shape of the Lorenz Curve.
* In the Gini Plot you see the value of the Gini Coefficient over time.

## THINGS TO TRY

* Try different values for multiplicative growth ("heads-mult", "tails-mult") and additive growth ("add-heads", "add-tails"),
* Compare the wealth-distribution for no multiplicative growth (set both "heads-mult", "tails-mult" to 1.0) to other values of multiplicative growth (eg. 0.6, 1.5)
* Compare the wealth-distribution for no additive growth (set both "heads-add", "tails-add" to 0.0) to other values of additive growth (eg. -0.2, 0.3)
* Try different "tax-factor"s and "tax-limit"s, switch "redist-all?" on/off.
* What changes can you see in the histogram, Gini Plot and Lorenz Curve?

## EXTENDING THE MODEL

* better visualization ideas?
* turtles get children and die of age
* implement inheritance tax

## NETLOGO FEATURES

* plotting on a log scale, 
* using turtle world to show turtle ranking by position, 
* histogram on varying upper and lower bounds,

## RELATED MODELS

http://ccl.northwestern.edu/netlogo/models/WealthDistribution
http://ccl.northwestern.edu/netlogo/models/Sugarscape3WealthDistribution

## CREDITS & REFERENCES

credit: computation of lorenz curve and gini index copied from: 
NetLogo models WealthDistribution 

in-depth readings:

Wikipedia: Distribution of wealth, retrieved 12/2019
https://en.wikipedia.org/wiki/Distribution_of_wealth

Wikipedia: Lorenz Curve, retrieved 12/2019
https://en.wikipedia.org/wiki/Lorenz_curve

Wikipedia: Gini Coefficient, retrieved 12/2019
https://en.wikipedia.org/wiki/Gini_coefficient

Wikipedia: Ergodic process, retrieved 12/2019
https://en.wikipedia.org/wiki/Ergodic_process

Ergodicity Economics, Ole Peters and Alexander Adamou, 2018
https://ergodicityeconomics.files.wordpress.com/2018/06/ergodicity_economics.pdf

Entrepreneurs, Chance, and the Deterministic Concentration of Wealth, Joseph E. Fargione u.a., 2011
https://journals.plos.org/plosone/article/file?id=10.1371/journal.pone.0020728&type=printable

An evolutionary advantage of cooperation, Ole Peters and Alexander Adamou, 2018
https://arxiv.org/pdf/1506.03414.pdf

Capital and Ideology, Thomas Piketty, 2019
http://piketty.pse.ens.fr/files/Piketty2020SlidesLongVersion.pdf

Farmers Fable: Simulation benefits of cooperation, retrieved 12/2019
https://www.farmersfable.org/

Gier, Marc Elsberg, novel, blanvalet 2019
https://gier-das-buch.de/gier.php


## COPYRIGHT

Copyright 2020 Rupert Nagler. All rights reserved.
Permission to use, modify or redistribute this model is hereby granted, provided that both of the following requirements are followed: 
* this copyright notice is included. 
* this model will not be redistributed for profit without permission from Rupert Nagler. Contact the author for appropriate licenses for redistribution for profit.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
