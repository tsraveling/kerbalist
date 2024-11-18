// This file exists to set a satellite into a polar orbit suitable for ScanSat scanning. We'll do this
// with Kerbin first, and set up the vessel to work as a relay satellite as well.

print(ship:name + " ready, AG9 to begin.").
download_and_run("lib/orbits.ks"). // Load libraries for ascent
wait until ag9.

solid_stage(0). // Solid ascent toward a polar orbit
ascend(0, 80000).  // Ascend to an apoapsis of 80k.
orbit(0). // Continue the ascent on a polar bearing until we are in orbit.
circularize_up(100000). // Circularize orbit at 100k.

print(ship:name + " is successfuly in orbit at " + altitude + "m.").