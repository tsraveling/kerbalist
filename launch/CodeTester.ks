log_win("Begin!").

local btn_test to {
    parameter index.
    print "Test " + index.
}.
bind_buttons(btn_test).

until AG9 {}