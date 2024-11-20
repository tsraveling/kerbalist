// This file exists to set a satellite into a polar orbit suitable for ScanSat scanning. We'll do this
// with Kerbin first, and set up the vessel to work as a relay satellite as well.

download_and_run("lib/orbits.ks", true). // Load libraries for ascent

print(ship:name + " ready, AG9 to begin.").
wait until ag9.

// 1. Ascend w/ solid stages
ascend_solids(0). // Solid ascent toward a polar orbit

// 2. Ascend to apoapsis >= 72 km
ascend(0, 75000, 7000, 1.2).  // Ascend to an apoapsis of 70k.

// 3. Get into orbit
complete_orbit(0). // Continue the ascent on a polar bearing until we are in orbit.

// 4. Circularize up to 80 km
//circularize_up(80000). // Circularize orbit at 100k.

print(ship:name + " is successfuly in orbit at " + altitude + "m.").