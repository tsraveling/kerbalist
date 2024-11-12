print "5!". wait 1.
print "4!". wait 1.
print "3!". wait 1.
print "2!". wait 1.
print "1!". wait 1.

// Go straight up for a bit
stage.
LOCK steering to heading(90, 90).
lock throttle to 1.0.
print "LAUNCH!".

wait until alt:radar > 300.
lock throttle to 0.5.
lock steering to heading(90,45).
print "Tilting to 45".

wait until alt:radar > 2000.
lock steering to heading(90,15).
print("beginning the skip.").
until maxThrust = 0 {
    if alt:radar > 3000 {
        lock throttle to 0.0.
    } else {
        lock throttle to 0.4.
        wait 10.
    }
    wait 0.5.
}

print("fuel out, prepare for splashdown").