// piano.ck
// A random song. "improvise" over a given harmony

<<<"Added Piano">>>;

Song song ;  
song.sync();  // sync to the quarter


// sound chains main mixer (a pan ugen).
Pan2 mix => dac ;
-0.2 => mix.pan ;
.1 => mix.gain ;


// ModalBar, TubeBell
// create, chain to mix and mute the chord instrument
fun TubeBell[] make_section( int ns ) { 
    TubeBell instr[ns];
    Delay d ;
    JCRev r => mix ;
    1::song.metro.quarterNote => d.max => d.delay ;
    // quarter => d.delay ;
    for (0 => int n; n < ns ; n++ ) {
        instr[n] => d => r ; // d => mix ;
        
        0 => instr[n].noteOff;
    }
    return instr;
}

// four notes chord
make_section( 4 ) @=> TubeBell instr[]; 


// mute the instrument
fun void mute() { 
    for (0 => int n; n < instr.cap() ; n++ ) {
        0 => instr[n].noteOff;
    }
}

// play a chord on the chord 
fun void play_chord( float vel, int chord[], int scale[]) { 
    if (chord[0] == 0) { mute( ) ;  return ; }  // a null in the chord means a rest
    for (0 => int n; n < chord.cap() ; n++ ) {
        chord[n]%7 => int note ; chord[n]/7 + 2 => int octave;
        octave * Std.mtof(scale[note]) => instr[n].freq ;
        vel => instr[n].noteOn;
    }
}


//now + song.end::second => time end ;
0.4 => float velocity ;

fun void play_section( int beat_mark, int times, int measures, int scale[], int chords[][]) {
    for ( beat_mark => int t; t <= measures ; t ++ )
    {   <<<"t ", t>>>;   
        if ( now >= song.end ) { <<<"end", song.end >>>; return ;} // done with the music     
        //if ( now < m_start ) return ;  // do not play before cue
        //play some chords
        repeat( times ) {
            <<<"key">>>;
            play_chord( velocity * (.5 + .5 * t / measures ) , 
                        chords[t%chords.cap()], 
                        scale
                       ) ;
            song.metro.quarterNote => now ;
       }
       
   }

}




// do not assume song.scale() keeps the same in the following lines

play_section( 0, 4, 5, song.scale(),  [[1,3,6,7], [3,4,7,11], [7,11,13,8], [3,5,7,8], [3,6,7,8] ])  ;
play_section( 0, 2, 4, song.scale(),  [[3,4,7,11], [7,11,13,14] ])  ;
play_section( 0, 1, 1, song.scale(),  [[0,0,0,0]])  ;
play_section( 0, 2, 4, song.scale(),  [[1,3,6,7], [3,4,7,11], [7,11,13,8], [3,6,7,9] ])  ;

2::song.metro.quarterNote => now ; // left the delay do it thing at the end (only for large values)         



