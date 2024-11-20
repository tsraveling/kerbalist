// download(): will download a file from the mainframe
function download {
    parameter filePath.
    parameter localPath is filePath.
    if not exists("0:/" + filePath) {
        print "ERROR: " + filePath + " does not exist on mainframe.".
        return.
    }
    copyPath("0:/" + filePath, "1:/" + localPath).
    print("Copied " + filePath + " to local storage.").
}

// load(filePath, force): This will download and run a file from the mainframe, loading any functions into memory
function download_and_run {
    parameter filePath.
    parameter force is false.

    if not force and exists("1:/" + filePath) {
        print filePath + " already local; executing.".
        switch to 1.
        runPath(filePath).
        return.
    }

    if not exists("0:/" + filePath) {
        print "ERROR: " + filePath + " does not exist on mainframe.".
        return.
    }
    
    copyPath("0:/" + filePath, "1:/" + filePath).
    print("Copied " + filePath + " to local storage and executing.").
    switch to 1.
    runPath(filePath).
}

function notify {
    parameter msg.

    // text, delay, pos (1: ul, 2: uc, 3: ur, 4: lc), font size, color, echo to terminal
    hudtext(msg, 5, 2, 50, yellow, true).
}

// add_alarm_if_needed(message, seconds, margin=10, notes="")
function add_alarm_if {
    if not ADDONS:KAC:AVAILABLE {
        log_error("KAC NOT INSTALLED!").
        return.
    }
    parameter message. // the alarm message
    parameter seconds. // will add an alarm if at least 30s
    parameter margin is 10. // margin to add to timer
    parameter notes is "". // the alarm notes

    local amt to seconds - margin.

    if amt > 30 {
        log_event("ALARM SET: " + message + " (in " + amt + "s)").
        addAlarm("Raw", time:seconds + amt, message, notes).
    }
}

function call_home {
    if not homeConnection:isconnected {
        print(ship:name + " is not connected to the KSC mainframe; signal failed.").
        return false.
    }
    print("KSC transmitting to " + ship:name + ", stand by for " + homeConnection:delay + "s signal delay ...").
    add_alarm_if("KSC Signal Delay", controlConnection:delay, 20, ship:name + " receives KSC automation package").
    wait homeConnection:delay.
    print(ship:name + " signal received. Executing automation payload ...").
    return true.
}

function call_control {
    if not controlConnection:isconnected {
        print(ship:name + " is not connected to KSC or a controlled vessel.").
        return false.
    }
    // TODO: Test this w/ KSC
    print(controlConnection:destination + " transmitting to " + ship:name + ", stand by for " + homeConnection:delay + "s signal delay ...").
    add_alarm_if("Control Delay", controlConnection:delay, 20, ship:name + " receives control package").
    wait homeConnection:delay.
    print(ship:name + " signal received. Executing control payload ...").
    return true.
}

// This will display at the bottom of the log screen.
function log_event {
    parameter msg.
    parameter domain to "GLOBAL".
    
    print ":=================================:" at (0, 23).
    print domain at (5, 23).
    print msg at (0, 24).
}

// This will log an error at the bottom of the log screen
function log_error {
    parameter msg.
    
    print "!!!!===========ERROR===========!!!!" at (0, 21).
    print msg at (0, 22).
}

// Terminal setup
set terminal:height to 24.