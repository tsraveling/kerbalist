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
    local diff to target_alt - base.
    local ascent_angle to 90.

    clearScreen.
    print "ASCENT STAGE" at (0, 1).
    print "------------" at (0, 2).
    
    local base_angle to 85.
    lock steering to heading(bearing, ascent_angle).
    lock throttle to 1.
    until apoapsis > target_alt + 200 {

        stage_if_empty().

        print "PARAMS:          " + base + "m TO " + target_alt + "m, AGGR: " + aggression at (0, 4).
        
        output("ALTITUDE", ship:altitude, 6).
        output("APOAPSIS", ship:apoapsis, 7).
        output("ASCENT ANGLE", ascent_angle, 8).
        output("PERIAPSIS", ship:periapsis, 9).
        output("ETA TO APOAPSIS", eta:apoapsis, 10).
        output("PRESSURE", ship:dynamicpressure, 11).

        // 1. Get height above the base / start altitude.
        // 2. Divide that by the difference between base and target to get the percentage of
        //    our progress to the target altitude.
        // 3. Use that to calculate our current angle as a linear progression from 0 to 90 based on alt.
        // 4. Modify with aggression: > 1 = more horizontal, < 1 = more vertical.
        if (ship:altitude < base) {
            set ascent_angle to base_angle.
        } else {
            set ascent_angle to max(base_angle - ((((ship:altitude - base) / diff) * base_angle) * aggression), 0).
        }

        wait 0.1.
    }

    clearScreen.
    lock throttle to 0.
    print("Ascent stage ended; apoapsis now at " + ship:apoapsis).
}

function complete_orbit {
    parameter bearing is 90.

    if (ship:apoapsis < 70) {
        // TODO: Handle this more gracefully if e.g. on the Mun.
        print("ERR: apoapsis is only " + ship:apoapsis + "m, orbit impossible! Returning.").
        return.
    }

    clearScreen.
    print "ORBIT STAGE" at (0, 1).
    print "------------" at (0, 2).

    lock orbit_speed to ship:velocity:orbit:mag.
    lock throttle to 0.

    // Wait until we exit atmo, if necessary
    until ship:dynamicpressure = 0 {
        print "LEAVING ATMO" at (0, 4).
        output("ALTITUDE", ship:altitude, 6).
        output("APOAPSIS", ship:apoapsis, 7).
        output("ORBIT SPD", orbit_speed, 8).
    }

    // Calculate burn required
    local tar_alt to ship:apoapsis.
    local target_speed to sqrt(ship:body:mu / (tar_alt + ship:body:radius)).
    
    // Aim at the horizon
    log_event("Leaving atmosphere, aiming at horizon for circularization in " + eta:apoapsis + "s.").
    local ascent_angle to 0.
    lock steering to heading(bearing, ascent_angle).

    local tar_throttle to 0.0.
    lock throttle to tar_throttle.

    // Calculate burn
    lock deltav_req to target_speed - orbit_speed.
    local current_accel to ship:availableThrust / ship:mass.
    local burn_time to (deltav_req / current_accel) + 10. // Start early
    
    if stage:deltav:current < deltav_req {
        log_error("Stage does not have enough deltaV to circularize, adding 20s.").
        set burn_time to burn_time + 20.
        // TODO: Account for next stage here.
    }

    add_alarm_if("Orbital burn", eta:apoapsis - (burn_time / 2), 25).

    until deltav_req <= 0 {

        if eta:apoapsis < (burn_time / 2) {
            set tar_throttle to 1.0.
            if verticalSpeed < 0 {
                set ascent_angle to 5.
            }
            clear_line(5).
        } else {
            output ("BURN ETA:", eta:apoapsis - (burn_time / 2), 5).
        }

        stage_if_empty().

        print "PARAMS:          BEARING is " + bearing at (0, 4).
        
        output("DELTA-V LEFT", deltav_req, 6).
        
        output("ALTITUDE", ship:altitude, 7).
        output("APOAPSIS", ship:apoapsis, 8).
        output("PERIAPSIS", ship:periapsis, 9).
        output("ETA TO APOAPSIS", eta:apoapsis, 10).
        
        wait 0.1.
    }

    clearScreen.
    
    local atmo to ship:body:atm.
    if (atmo:exists) {
        print "CLEARING ATMO" at (0, 1).
        print "------------" at (0, 2).
        
        until ship:periapsis >= atmo:height {
            output("ATMO", atmo:height, 4).
            output("ALTITUDE", ship:altitude, 5).
            output("APOAPSIS", ship:apoapsis, 6).
            output("PERIAPSIS", ship:periapsis, 7).
        }
    }

    clearScreen.

    // Wait for apoapsis 
    local circ_orbit_speed to sqrt(ship:body:mu / (ship:apoapsis + ship:body:radius)).
    lock deltav_req to circ_orbit_speed - orbit_speed.
    local current_accel to ship:availableThrust / ship:mass.
    lock circ_burn_time to (deltav_req / current_accel) + 10.
    set tar_throttle to 0.

    print "CIRCULARIZING" at (0, 1).
    print "------------" at (0, 2).

    add_alarm_if("Orbital burn", eta:apoapsis - (circ_burn_time / 2), 25).

    until deltav_req <= 0 {

        if eta:apoapsis < (circ_burn_time / 2) {
            set tar_throttle to 1.0.
            if verticalSpeed < 0 {
                set ascent_angle to 5.
            }
            clear_line(5).
        } else {
            output ("BURN ETA:", eta:apoapsis - (circ_burn_time / 2), 5).
        }

        stage_if_empty().

        print "PARAMS:          BEARING is " + bearing at (0, 4).
        
        output("DELTA-V LEFT", deltav_req, 6).
        
        output("ALTITUDE", ship:altitude, 7).
        output("APOAPSIS", ship:apoapsis, 8).
        output("PERIAPSIS", ship:periapsis, 9).
        output("ETA TO APOAPSIS", eta:apoapsis, 10).
        
        wait 0.1.
    }
    
    // clearScreen.
    print "Orbit achieved.".
    print "Apoapsis: " + alt:apoapsis.
    print "Periapsis: " + alt:periapsis.
    print "Remaining delta-v: " + ship:deltav:current.

    unlock deltav_req.
    unlock orbit_speed.
}

function raise_orbit {
    parameter tar_alt is 100.

    print "BEGINNING ORBIT RAISE.".
    
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
    unlock throttle.
    unlock steering.
}

function ascend_solids {
    parameter bearing is 90.

    clearScreen.
    print "SOLID ASCENT STAGE" at (0, 1).
    print "------------" at (0, 2).

    // Solid booster ascent
    stage.
    lock steering to heading(bearing, 85). // Lean just a little bit
    
    until maxThrust = 0 {

        print "PARAMS:          BEARING IS " + bearing at (0, 4).

        output("ALT", ship:altitude, 6).
        output("APOAPSIS", ship:apoapsis, 7).
        output("ETA TO APOAPSIS", eta:apoapsis, 8).
        output("PRESSURE", ship:dynamicpressure, 9).
        
        wait 0.1.
    }

    clearScreen.
    
    // Make sure we don't torch the solid boosters on stage
    lock throttle to 0.
    set ship:control:pilotmainthrottle to 0.
    print("Waiting 7 seconds for cooldown.").
    wait 7.
    
    
    // Release
    print("Releasing solid boosters.").
    stage.
    wait 1.
    print("Flying clear.").
    lock throttle to 0.2.
    wait 2.
    print("Solid ascent stage complete.").
}