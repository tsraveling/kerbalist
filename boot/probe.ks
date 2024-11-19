print(ship:name + " automation core coming online ...").

// First get the core library onboard if we don't have it already, and run it.
if not exists("1:/lib/core.ks") {
    copyPath("0:/lib/core.ks", "1:/lib/core.ks").
}
runOncePath("lib/core.ks").

// Check for ship autoload -- load and rewrite if still in prelaunch (for quick debugging)
local auto_file to "autoload/" + ship:name + ".ks".
if exists("0:/" + auto_file) and ship:status = "PRELAUNCH" {
    print("Autoloading file ...").

    // Call the nearest control node, await signal delay, then fire code
    if call_home() {
        download(auto_file, "start.ks").
        switch to 1.
        run "start.ks".
    }
} else {
    print("No new commands found, settling in.").
}

// Check for commands
local cmd_file to "cmd/" + ship:name + ".ks".
if exists(cmd_file) {
    print("KSC command file found, transmitting ...").

    // Call the nearest control node, await signal delay, then fire code
    if call_control() {
        download_and_run(cmd_file).
        deletePath("0:/" + cmd_file).
        deletePath("1:/" + cmd_file).
        print("Automation executed; powering down.").
    }
} else {
    print("No new commands found, settling in.").
}