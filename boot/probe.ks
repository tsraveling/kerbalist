print(ship:name + " automation core coming online ...").

// First get the core library onboard if we don't have it already, and run it.
if not exists("1:/lib/core.ks") {
    copyPath("0:/lib/core.ks", "1:/lib/core.ks").
}
runOncePath("lib/core.ks").

// Check for ship launch scripts -- load and rewrite if still in prelaunch (for quick debugging)
local auto_file to "launch/" + ship:name + ".ks".
if exists("0:/" + auto_file) and ship:status = "PRELAUNCH" {
    print("Loading launch script ...").

    // Load up and run the launch script
    download(auto_file, "start.ks").
    switch to 1.
    run "start.ks".

} else {
    print("No new commands found, settling in.").
}

// Check for commands (WILL RUN ONLY AFTER LAUNCH)
local cmd_file to "cmd/" + ship:name + ".ks".
if exists("0:/" + cmd_file) {
    print("KSC command file found, transmitting ...").

    // Call the nearest control node, await signal delay, then fire code
    if ship:status = "PRELAUNCH" {
        download(cmd_file, "cmd.ks").
    } else {
        // Maybe add option to download via interface?
        if call_control() {
            download(cmd_file, "cmd.ks").
            print("New script downloaded; settling in.").
        }

        run "cmd.ks".
    }
} else {
    print("No new commands found, settling in.").
}