function stage_if_empty {
    if maxThrust = 0 {
        log_event("STAGING.").
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
    parameter start_alt is 5000.
    parameter aggression is 1.

    // Either start the turn at the given start altitude, or else the current alt if higher than that.
    local base to max(ship:altitude, start_alt).
    local diff to target_alt - start_alt.
    local ascent_angle to 90.

    clearScreen.
    print "ASCENT STAGE" at (0, 1).
    print "------------" at (0, 2).
    
    lock steering to heading(bearing, ascent_angle).
    lock throttle to 1.
    until apoapsis > target_alt + 200 {

        stage_if_empty().

        print "PARAMS:          " + base + "m TO " + target_alt + "m, AGGR: " + aggression at (0, 4).
        
        print "STAGE:           " + stage:number at (0,6).
        print "STAGE DELTA-V:   " + stage:deltav at (0,7).
        print "MAX THRUST:      " + ship:maxthrust at (0,8).
        print "ALT:             " + ship:altitude at (0,9).
        print "APOAPSIS:        " + ship:apoapsis at (0,10).
        print "ASCENT ANGLE:    " + ascent_angle at (0,11).

        print "ETA TO APOAPSIS: " + eta:apoapsis at (0,13).

        // 1. Get height above the base / start altitude.
        // 2. Divide that by the difference between base and target to get the percentage of
        //    our progress to the target altitude.
        // 3. Use that to calculate our current angle as a linear progression from 0 to 90 based on alt.
        // 4. Modify with aggression: > 1 = more horizontal, < 1 = more vertical.
        set ascent_angle to min(90 - ((((ship:altitude - base) / diff) * 90) * aggression), 0).

        wait 0.1.
    }

    clearScreen.
    print("Ascent stage ended; apoapsis now at " + ship:apoapsis).
}

function orbit {
    parameter bearing is 90.

    if (ship:apoapsis < 70) {
        // TODO: Handle this more gracefully if e.g. on the Mun.
        print("ERR: apoapsis is only " + ship:apoapsis + "m, orbit impossible! Returning.").
        return.
    }

    clearScreen.
    print "ORBIT STAGE" at (0, 1).
    print "------------" at (0, 2).

    when not bodyAtmosphere:exists OR eta:apoapsis < 40 OR ship:altitude >= bodyAtmosphere:height then {
        log_event("Aligning to horizon for burn prep.", "AUTOPILOT").
        lock steering to heading(bearing, 0).
    }

    local tar_throttle to 0.0.
    lock throttle to tar_throttle.
    
    until ship:status = "ORBIT" {

        if eta:apoapsis < 20 OR verticalSpeed < 0 {
            set tar_throttle to 1.0.
        } else {
            set tar_throttle to 0.0.
        }
        stage_if_empty().

        print "PARAMS:          BEARING is " + bearing at (0, 4).
        
        if tar_throttle > 0 {
            print "=> BURNING:         " + tar_throttle at (0,6).
        } else {
            print "---------------------->" at (0,6).
        }
        print "STAGE:           " + stage:number at (0,7).
        print "STAGE DELTA-V:   " + stage:deltav at (0,8).
        print "ALT:             " + ship:altitude at (0,9).
        print "APOAPSIS:        " + ship:apoapsis at (0,10).
        print "ETA TO APOAPSIS: " + eta:apoapsis at (0,11).
        print "PERIAPSIS:       " + alt:periapsis at (0, 12).

        wait 0.1.
    }

    clearScreen.
    print "Orbit achieved.".
    print "Apoapsis: " + alt:apoapsis.
    print "Periapsis: " + alt:periapsis.
    print "Remaining delta-v: " + ship:deltav.
}

function circularize_up {
    parameter tar_alt is 100.

    print "BEGINNING CIRCULARIZATION.".
    
    if ship:apoapsis > tar_alt and ship:periapsis > tar_alt {
        print("ERR: orbit is already above target of " + tar_alt + "m, returning.").
        return.
    }

    // Raise apoapsis if needed
    if ship:apoapsis < tar_alt {
        lock steering to prograde.
        lock throttle to 0.
        print "Waiting until periapsis for first lifting burn.".
        add_alarm_if("Periapsis", eta:periapsis, 25).
        wait until eta:periapsis < 20.
        print "Approaching periapsis, burning.".
        lock throttle to 1.
        until apoapsis >= tar_alt {
            stage_if_empty().
        }
    }

    // Raise periapsis if needed
    lock throttle to 0.
    print "Waiting for apoapsis to complete circularization burn.".
    add_alarm_if("Apoapsis", eta:apoapsis, 25).
    wait until eta:apoapsis < 20.
    print "Approaching apoapsis, initating burn.".
    lock steering to prograde.
    until periapsis >= tar_alt {
        stage_if_empty().
    }
}

function ascend_solids {
    parameter bearing is 90.

    clearScreen.
    print "SOLID ASCENT STAGE" at (0, 1).
    print "------------" at (0, 2).

    // Solid booster ascent
    stage.
    
    until maxThrust = 0 {

        print "PARAMS:          BEARING IS " + bearing at (0, 4).
        
        print "STAGE:           " + stage:number at (0,6).
        print "STAGE DELTA-V:   " + stage:deltav at (0,7).
        print "MAX THRUST:      " + ship:maxthrust at (0,8).
        print "ALT:             " + ship:altitude at (0,9).
        print "APOAPSIS:        " + ship:apoapsis at (0,10).
        print "ETA TO APOAPSIS: " + eta:apoapsis at (0,12).

        wait 0.1.
    }


    lock steering to heading(bearing, 85). // Lean just a little bit
    
    // Make sure we don't torch the solid boosters on stage
    lock throttle to 0.
    set ship:control:pilotmainthrottle to 0.
    
    
    // Release
    clearScreen.
    print("Releasing solid boosters.").
    stage.
    wait 1.
    print("Flying clear.").
    lock throttle to 0.2.
    wait 2.
    print("Solid ascent stage complete.").
}