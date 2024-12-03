// Load core libraries ...
print(ship:name + " automation core coming online ...").

// First get the core library onboard if we don't have it already, and run it.
if not exists("1:/lib/core.ks") {
    copyPath("0:/lib/core.ks", "1:/lib/core.ks").
}
runOncePath("lib/core.ks").

// Copied in from KOSOS

function print_l {
    parameter txt.
    parameter y.

    print txt at (15, y).
}

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

// SCRIPT BEGINS //
clearScreen.
        
until AG9 {

    local current_accel to ship:availableThrust / ship:mass.
    
    if ship:status = "LANDED" or ship:status = "PRELAUNCH" or ship:status = "SPLASHED" {
        clearScreen.
        unlock steering.
        unlock throttle.
        print_c(ship:status, 2).
        print_l("CURRENT ACCEL:      " + fmt(current_accel), 5).
        wait until ship:status <> "LANDED" and ship:status <> "SPLASHED" and ship:status <> "PRELAUNCH".
        clearScreen.
    } else {

        local burn_time to (ship:airspeed / current_accel).

        // Direction
        if ship:verticalspeed < 0 {
            print_l("FALLING:            " + fmt(ship:verticalspeed), 2).
        } else {
            print_l("UPWARD TRAJECTORY:  " + fmt(ship:verticalspeed), 2).
        }

        if AG8 {
            print_c("LOCKED", 0).
            if ship:verticalSpeed < 0 {
                lock steering to SHIP:srfretrograde.
            } else {
                unlock steering.
            }
        } else {
            unlock steering.
        }
     
        // Impact time
        if ADDONS:TR:AVAILABLE {
            if ADDONS:TR:HASIMPACT {
                local ti to ADDONS:TR:TIMETILLIMPACT.
                print_l("TIME TIL IMPACT:    " + fmt(ti), 3).
                local si to ti - burn_time.
                if si > 0 {
                    print_l("[#FF9900]START BURN IN:      " +  fmt(si), 12).
                } else {
                    print_c("[#FF0000]!!!!DANGER BURN NOW!!!!", 11).
                }

                if AG8 {
                    if ship:verticalSpeed < 0 {
                        // TODO: def put a PID in here.
                        local throt to 1.0.
                        if ship:airspeed < 3 {
                            set throt to 0.2.
                        } else if ship:airspeed < 10 {
                            set throt to 0.5.
                        }
                        if si < 2 {
                            lock throttle to throt.
                        } else {
                            unlock throttle.
                        }
                    } else {
                        unlock throttle.
                    }
                }
            } else {
                print_c("NO IMPACT!", 3).
            }
        }

        // BURN TIME
        print_l("CURRENT ACCEL:      " + fmt(current_accel), 5).
        print_l("STAGE DELTA-V:      " + fmt(stage:deltav:current), 6).
        if stage:deltav:current < ship:airspeed {
            print "!!!!" at (1, 7).
        } else {
            print "    " at (1, 7).
        }
        
        local col to "#FF0000".
        if ship:airspeed < 50 {
            set col to "#FF9900".
        } else if ship:airspeed < 25 {
            set col to "#FFFF00".
        } else if ship:airspeed < 8 {
            set col to "#FF0000".
        }
        print_l("[" + col + "]AIRSPEED:           " + fmt(ship:airspeed), 8).
        
        print_l("[#FFFF00]TIME TO STOP:       " + fmt(burn_time), 10).
    }

    wait 0.1.
}

clearScreen.
print "Script ended.".