print(ship:name + " ready, AG9 to begin.").
download_and_run("lib/testing.ks").
wait until ag9.

print("Grasshopper I starting launch script in 3...").
wait 3.

// TEST SETUP: Get up in the air with some surface speed ...
// get_in_flight(bearing = 90, angle = 45, turn_alt = 30, drop_alt = 100)
get_in_flight(180, 45, 30, 100).


// APPLICATION: Then try to land it.

lock steering to srfRetrograde.

wait until alt:radar < 100.
print("Below 100m, burning"). 

lock throttle to 1.0.

until false {
    if verticalSpeed < -10 {
        lock throttle to 1.0.
    } else {
        lock throttle to 0.5.
    }
    wait 0.5.

    if ship:status = "LANDED" {
        print("TOUCHDOWN!").
        break.
    }

    if maxThrust = 0 {
        print("Out of fuel, prepare for crash landing").
        break.
    }
}

print("Landing script complete.").



