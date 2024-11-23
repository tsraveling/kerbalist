download_and_run("lib/orbits.ks", true). // Load libraries for ascent

wait_for_go().

// 3. Get into orbit
complete_orbit(0). // Continue the ascent on a polar bearing until we are in orbit.

print(ship:name + " is successfuly in orbit at " + altitude + "m.").