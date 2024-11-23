@lazyGlobal off.

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

// Bind the RPM console buttons to a function
function bind_buttons {
    parameter del is donothing.

    global buttons to addons:kpm:buttons.
    local monitors to addons:kpm:getmonitorcount().

    FROM {local x is 0.} UNTIL x = monitors STEP {set x to x+1.} DO {
        set buttons:currentmonitor to x.
        FROM {local y is -6.} UNTIL y=12 STEP {set y to y+1.} DO {
            buttons:setdelegate(y,del:BIND(y)).
        }
    }
}

local clear_line to "                                    ".

// This will display at the bottom of the log screen.
function log_event {
    parameter msg.
    print "clear_line" at (0, 18).
    print "[#FFFF00]" + msg at (0, 18).
}

// This will log an error at the bottom of the log screen
function log_error {
    parameter msg.
    print "clear_line" at (0, 18).
    print "[#FF0000]" + msg at (0, 18).
}

// This will log an error at the bottom of the log screen
function log_win {
    parameter msg.
    print "clear_line" at (0, 18).
    print "[#99FF00]" + msg at (0, 18).
}

function wait_for_go {
    clearScreen.
    set AG10 to true.
    print "[#FFFFFF]WAIT FOR GO." at (5, 1).
    wait until not AG10.
}