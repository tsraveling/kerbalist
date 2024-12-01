// KOSOS testing environment

function print_c {
    parameter txt.
    parameter y.

    print txt at (40 - txt:length / 2, y).
}

function print_r {
    parameter txt.
    parameter x.
    parameter y.

    print txt at (x - txt:length, y).
}

global btn_x_top to list(3, 14, 25, 36, 47, 57, 68).
global btn_x_btm to list(3, 15, 26, 37, 47).

function print_btn {
    parameter bi.
    parameter lab.

    local pci to {
        parameter x.
        parameter s.
        return x + 3 - (s:length / 2).
    }.

    if bi > 6 and bi <= 11 {
        print lab at (pci(btn_x_btm[bi - 7], lab), 18).
    } else if bi >= 0 {
        print lab at (pci(btn_x_top[bi], lab), 0).
    } else if bi = -1 {
        print_r(lab, 79, 9).
    } else if bi = -2 {
        print_r(lab, 79, 12).
    } else if bi = -3 {
        print_r(lab, 79, 2).
    } else if bi = -4 {
        print_r(lab, 79, 5).
    } else if bi = -5 {
        print lab at (1, 2).
    } else if bi = -6 {
        print lab at (1, 5).
    } 
}

global BTN_ENTER to -1.
global BTN_CANCEL to -2.
global BTN_UP to -3.
global BTN_DOWN to -4.
global BTN_LEFT to -5.
global BTN_RIGHT to -6.

global btn to -10.

function btn_reset {
    set btn to -10.
}

function get_btn {
    if btn > -10 {
        local ret to btn.
        set btn to -10.
        return ret.
    }
    return -10.
}

// Set up button bindings
global buttons to addons:kpm:buttons.
local monitors to addons:kpm:getmonitorcount().
global bh to {
    parameter i.
    set btn to i.
}.

FROM {local x is 0.} UNTIL x = monitors STEP {set x to x+1.} DO {
    set buttons:currentmonitor to x.
    FROM {local y is -6.} UNTIL y=12 STEP {set y to y+1.} DO {
        buttons:setdelegate(y,bh:BIND(y)).
    }
}

// MENU PICKING SYSTEM //

global pick_index to 0.
global pick_end to 0.
global picklist_x to 0.
global picklist_y to 0.

function init_picklist {
    parameter options.
    parameter x, y.
    set pick_index to 0.
    set picklist_x to x.
    set picklist_y to y.
    set pick_end to options:length - 1.

    local l to 0.
    for opt in options {
        print opt at (x+2, l+y).
        set l to l + 1.
    }

    // Print opening carat
    print "> " at (x, y).
}

function get_picklist {
    parameter button. // Pass this in from the loop to make the input work across the board
    local prev to pick_index.
    if button = BTN_UP {
        set pick_index to pick_index - 1.
    } else if button = BTN_DOWN {
        set pick_index to pick_index + 1.
    }
    if pick_index < 0 {
        set pick_index to pick_end.
    }
    if pick_index > pick_end {
        set pick_index to 0.
    }
    if prev <> pick_index {
        print "  " at (picklist_x, picklist_y + prev).
        print "> " at (picklist_x, picklist_y + pick_index).
    }
    if button = BTN_ENTER {
        return pick_index.
    }
    return -1.
}

//////////////
// BEGIN OS //
//////////////

clearScreen.

print_c("KOSOS 0.0.1", 2).
wait 0.5.

print_c(ship:name, 3).
print_c("STATUS: " + ship:status, 4).

// STUB: Get available scripts, filtered by status.
// TODO: add ability to extend scripts to load custom scripts for particular ships
// TODO: Add a general picker ability, e.g. for a list of waypoints or timers.

print_btn(BTN_ENTER, "ENTER").
print_btn(6, "EXIT").

init_picklist(list("First one", "Second one", "Third one"), 5, 5).

until AG9 {
    local b to get_btn().
    if b = BTN_ENTER {
        print_c("YOU HIT ENTER!", 6).
    }
    if b = BTN_CANCEL {
        print_c("YOU HIT CANCEL!", 6).
    }

    local lp to get_picklist(b).
    if lp >= 0 {
        print_c("YOU PICKED " + lp, 6).
    }
    wait 0.1.
}