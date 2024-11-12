print(vessel:name + " automation core coming online ...").

// First get the core library onboard if we don't have it already, and run it.
if not exists("1:/lib/core.ks") {
    copyPath("0:/lib/core.ks", "1:/lib/core.ks").
}
runOncePath("lib/core.ks").

// Check for commands
local cmd_file to "cmd/" + vessel:name + ".ks".
if exists(cmd_file) {
    print("KSC command file found, transmitting ...").

    // Call the nearest control node, await signal delay, then fire code
    if call_control() {
        load(cmd_file).
        deletePath("1:/" + cmd_file).
        deletePath(cmd_file).
        print("Automation executed; powering down.").
        shutdown.
    }
} else {
    print("No new commands found, powering down.").
    shutdown.
}