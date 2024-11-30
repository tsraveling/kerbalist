clearScreen.
print "screen width" + terminal:width.

local x to 0.
until x > 80 {
    set x to x + 1.
    if mod(x, 10) = 0 {
        print x at (x, 2).
    } else if mod(x, 5) = 0 {
        print "|" at (x, 2).
    }
}