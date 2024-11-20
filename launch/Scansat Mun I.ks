// This file exists to set a satellite into a polar orbit suitable for ScanSat scanning. We'll do this
// with Kerbin first, and set up the vessel to work as a relay satellite as well.

download_and_run("lib/orbits.ks"). // Load libraries for ascent


print(ship:name + " ready, AG9 to begin.").
wait until ag9.

// 1. Get in orbit

print "SOLID STAGE:".
ascend_solids(0). // Solid ascent toward a polar 

print "ASCENT STAGE:".
ascend(0, 250000).  // Ascend to an apoapsis of 70k.

print "ORBIT STAGE:".
complete_orbit(0). // Continue the ascent on a polar bearing until we are in orbit.

print "CIRCULARIZE STAGE:".
circularize_up(300000). // Circularize orbit at 100k.

print(ship:name + " is successfuly in orbit at " + altitude + "m.").

// 2. Get an intercept with the MUN (manually?) with a target periapsis
// 3. Fly to the mun
// 4. Halfway there burn normal, watching the next patch:inclination to get a polar-ish orbit without losing the encounter
// 5. Circularize at periapsis
// 6. Shift inclination to tweak if desired
// 7. Start scans etc.