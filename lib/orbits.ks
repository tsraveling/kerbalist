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
    parameter target_alt is 80000.

    // TODO: make this smarter.
    print "Standard ascent stage beginning at " + altitude + "m.".
    lock throttle to 1.
    until apoapsis > target_alt + 200 {
        stage_if_empty().
        if altitude > 60000 {
            lock steering to heading(bearing, 25).
        } else if altitude > 50000 {
            lock steering to heading(bearing, 35).
        } else if altitude > 40000 {
            lock steering to heading(bearing, 45).
        } else if altitude > 30000 {
            lock steering to heading(bearing, 55).
        } else if altitude > 20000 {
            lock steering to heading(bearing, 65).
        } else if altitude > 10000 {
            lock steering to heading(bearing, 75).
        } else {
            lock steering to heading(bearing, 85).
        }
        wait 0.2.
    }

    print "Ascent stage ended; apoapsis now at " + ship:apoapsis.
    lock throttle to 0.0.
}

function complete_orbit {
    parameter bearing is 90.

    print "Preparing to complete orbit. Current altitude is " + ship:altitude + ", current apoapsis is " + ship:apoapsis.
    lock throttle to 0.

    if (ship:apoapsis < 70000) {
        // TODO: Handle this more gracefully if e.g. on the Mun.
        print "ERR: apoapsis is only " + ship:apoapsis + "m, orbit impossible! Returning.".
        return.
    }

    set target_periapsis to ship:apoapsis.

    print "Waiting " + (eta:apoapsis - 20) + "s until burn ...".
    wait until (eta:apoapsis < 20).
    
    lock steering to heading(bearing, 5).
    lock throttle to 1.

    until periapsis >= target_periapsis {
        stage_if_empty().
        // TODO: Check vertical speed etc. problem is the runaway
        // apoapsis. This becomes the periapsis and then we're 
        // stuck on an exit trajectory.
        if eta:apoapsis > 20 and eta:apoapsis < 40 {
            lock throttle to 0.
            wait until eta:apoapsis < 15.
            lock throttle to 1.
        }
        wait 0.2.
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
        print("Waiting " + (eta:periapsis - 20) + "s until burn ...").
        wait until eta:periapsis < 20.
        lock throttle to 1.
        until apoapsis >= tar_alt {
            stage_if_empty().
        }
    }

    // Raise periapsis if needed
    lock throttle to 0.
    print "Apoapsis in " + eta:apoapsis + "s, will burn at A-20.".
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
    print("Waiting 10 to cool down ...").
    wait 10.
    print("Decoupling solid boosters.").
    stage.
    wait 2.
    print("Flying clear.").
    lock throttle to 0.2.
    wait 2.
    print("Solid ascent stage complete.").
    return 1.
}