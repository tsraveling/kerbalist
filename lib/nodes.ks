// Currently taken directly from the kOS tutorial.
function execute_next {
    set nd to nextnode.

    //print out node's basic parameters - ETA and deltaV
    print "Node in: " + round(nd:eta) + ", DeltaV: " + round(nd:deltav:mag).

    //calculate ship's max acceleration
    set max_acc to ship:maxthrust/ship:mass.

    // Now we just need to divide deltav:mag by our ship's max acceleration
    // to get the estimated time of the burn.
    //
    // Please note, this is not exactly correct.  The real calculation
    // needs to take into account the fact that the mass will decrease
    // as you lose fuel during the burn.  In fact throwing the fuel out
    // the back of the engine very fast is the entire reason you're able
    // to thrust at all in space.  The proper calculation for this
    // can be found easily enough online by searching for the phrase
    //   "Tsiolkovsky rocket equation".
    // This example here will keep it simple for demonstration purposes,
    // but if you're going to build a serious node execution script, you
    // need to look into the Tsiolkovsky rocket equation to account for
    // the change in mass over time as you burn.
    //
    set burn_duration to nd:deltav:mag/max_acc.
    print "Crude Estimated burn duration: " + round(burn_duration) + "s".

    local wait_amt to nd:eta - (burn_duration/2 + 60).
    add_alarm_if("Node execution", wait_amt, 25).
    wait until nd:eta <= (burn_duration/2 + 60).
}