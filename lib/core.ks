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

    if force and exists("1:/" + filePath) {
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

function add_alarm_if_needed {
    parameter what. // string: what is this alarm?
    parameter seconds. // will add an alarm if at least 30s
    parameter message. // the alarm message
    parameter notes is "". // the alarm notes

    if seconds > 30 {
        print(what + " is more thant 30s out; creating an alarm for 10s prior..").
        addAlarm("raw", time:seconds + homeConnection:delay - 10, message, notes).
    }
}

function call_home {
    if not homeConnection:isconnected {
        print(ship:name + " is not connected to the KSC mainframe; signal failed.").
        return false.
    }
    print("KSC transmitting to " + ship:name + ", stand by for " + homeConnection:delay + "s signal delay ...").
    add_alarm_if_needed("KSC delay", controlConnection:delay, ship:name + " receives KSC automation package").
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
    add_alarm_if_needed("Control delay", controlConnection:delay, ship:name + " receives control package").
    wait homeConnection:delay.
    print(ship:name + " signal received. Executing control payload ...").
    return true.
}