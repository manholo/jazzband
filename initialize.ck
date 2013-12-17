// "On time for Kansas City" A random song. "improvise" over a given harmony

// initialize.ck



// scale builder
Machine.add(me.dir()+"/scale.ck");
// beat Events 
Machine.add(me.dir()+"/metroevents.ck");
// beat-timer class
Machine.add(me.dir()+"/metronome.ck");
// the conductor
Machine.add(me.dir()+"/song.ck");
// the instruments
Machine.add(me.dir() + "/harmony.ck") ;

// our score
Machine.add(me.dir()+"/score.ck");


