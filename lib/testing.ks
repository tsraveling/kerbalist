// get_in_flight(bearing = 90, angle = 45, turn_alt = 30, drop_alt = 100)
function get_in_flight {
    parameter bearing is 90.
    parameter angle is 45.
    parameter turn_alt is 30.
    parameter drop_alt is 100.

    print("ATP: Getting in flight at bearing " + bearing).
    lock throttle to 1.0.
    lock steering to heading(bearing, 90).
    stage.
    wait until alt:radar > turn_alt.

    print("Above " + turn_alt + "m, angling down to " + angle + "...").
    lock steering to heading(bearing, angle).
    wait until alt:radar > drop_alt.
    lock throttle to 0.0.

    print("Target alt " + drop_alt + "m reached, waiting for descent phase").

    wait until verticalSpeed < 0.
    print("We are in descent ...").
}