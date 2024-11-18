function stage_if_empty {
    if maxThrust = 0 {
        print("Staging.").
        lock throttle to 0.
        stage.
        wait 0.5.
        lock throttle to 0.2.
        wait 0.5.
        lock throttle to 1.
    }
}

function ascend {
    parameter bearing is 90.
    parameter target_alt is 80.

    // TODO: make this smarter.
    print("Standard ascent stage beginning at " + altitude + "m.").
    lock throttle to 1.
    until apoapsis > target_alt + 200 {
        stage_if_empty().
        if altitude > 60 {
            print "Ascent angle: 25." at (0, 0).
            lock steering to heading(bearing, 25).
        } else if altitude > 50 {
            print "Ascent angle: 35." at (0, 0).
            lock steering to heading(bearing, 35).
        } else if altitude > 40 {
            print "Ascent angle: 45." at (0, 0).
            lock steering to heading(bearing, 45).
        } else if altitude > 30 {
            print "Ascent angle: 55." at (0, 0).
            lock steering to heading(bearing, 55).
        } else if altitude > 20 {
            print "Ascent angle: 65." at (0, 0).
            lock steering to heading(bearing, 65).
        } else if altitude > 60 {
            print "Ascent angle: 75." at (0, 0).
            lock steering to heading(bearing, 75).
        } else {
            print "Ascent angle: 85." at (0, 0).
            lock steering to heading(bearing, 85).
        }
    }

    print("Ascent stage ended; apoapsis now at " + ship:apoapsis).
}

function orbit {
    parameter bearing is 90.

    if (ship:apoapsis < 70) {
        // TODO: Handle this more gracefully if e.g. on the Mun.
        print("ERR: apoapsis is only " + ship:apoapsis + "m, orbit impossible! Returning.").
        return.
    }

    set target_periapsis to ship:apoapsis.

    add_alarm_if_needed("Apoapsis", eta:apoapsis - 25, ship:name + " nearing apoapsis!"). 
    wait until (eta:apoapsis < 20).
    
    lock steering to heading(bearing, 0).
    lock throttle to 1.

    until periapsis >= target_periapsis {
        stage_if_empty().
    }
}

function circularize_up {
    parameter tar_alt is 100.
    
    if ship:apoapsis > tar_alt and ship:periapsis > tar_alt {
        print("ERR: orbit is already above target of " + tar_alt + "m, returning.").
        return.
    }

    // Raise apoapsis if needed
    if ship:apoapsis < tar_alt {
        lock steering to prograde.
        lock throttle to 0.
        add_alarm_if_needed("Periapsis", eta:apoapsis - 25, ship:name + " nearing periapsis!"). 
        wait until eta:periapsis < 20.
        lock throttle to 1.
        until apoapsis >= tar_alt {
            stage_if_empty().
        }
    }

    // Raise periapsis if needed
    lock throttle to 0.
    add_alarm_if_needed("Apoapsis", eta:apoapsis - 25, ship:name + " nearing apoapsis!"). 
    wait until eta:apoapsis < 20.
    lock steering to prograde.
    until periapsis >= tar_alt {
        stage_if_empty().
    }
}

function ascend_solids {
    parameter bearing is 90.

    print("Beginning solid stage ascent.").

    lock steering to heading(bearing, 85). // Lean just a little bit
    
    // Make sure we don't torch the solid boosters on stage
    lock throttle to 0.
    set ship:control:pilotmainthrottle to 0.
    
    // Solid booster ascent
    stage.
    wait until maxThrust = 0.
    print("Solid boosters expended, staging.").
    
    // Release
    print("Releasing solid boosters.").
    stage.
    wait 1.
    print("Flying clear.").
    lock throttle to 0.2.
    wait 2.
    print("Solid ascent stage complete.").
}