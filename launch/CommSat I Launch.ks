// This file exists to set a satellite into a polar orbit suitable for ScanSat scanning. We'll do this
// with Kerbin first, and set up the vessel to work as a relay satellite as well.

download_and_run("lib/orbits.ks", true). // Load libraries for ascent
wait_for_go().

local BEARING to 90.
ascend_solids(BEARING). // Solid ascent toward a polar orbit
ascend(BEARING, 100000, 10000, 1.0).
complete_orbit(BEARING).

print(ship:name + " is successfuly in orbit at " + altitude + "m.").