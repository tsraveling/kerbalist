// This file exists to set a satellite into a polar orbit suitable for ScanSat scanning. We'll do this
// with Kerbin first, and set up the vessel to work as a relay satellite as well.

download_and_run("lib/orbits.ks"). // Load libraries for ascent

print(ship:name + " ready, AG9 to begin.").
wait until ag9.

ascend_solids(0). // Solid ascent toward a polar orbit
ascend(0, 70000).  // Ascend to an apoapsis of 70k.
complete_orbit(0). // Continue the ascent on a polar bearing until we are in orbit.
circularize_up(80000). // Circularize orbit at 100k.

print(ship:name + " is successfuly in orbit at " + altitude + "m.").