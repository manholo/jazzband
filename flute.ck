// flute.ck
// // A random song. "improvise" over a given harmony

Song song ;  
//song.init(); // init'd by score.ck 
song.sync();  // sync to the quarter


SinOsc vib => Moog solo => JCRev rev => Pan2 mix => dac ;
solo => Delay d => d => rev ;
//0.1::second => d.max => d.delay ;
1::song.quarterNote => d.max => d.delay ;
0.3 => d.gain ;
8 => vib.freq ;  // for vibrato

// sound
0.1 => rev.mix ;
-0.1 => mix.pan ;

//now + song.end::second => time end ;
0.3 => float velocity ;


// gets the chord to play the solo notes from it.
fun void play_section( int beat_mark, int times, int measures, int scale[], StkInstrument instr, int chords[][]) {
    [ .75, .25 ] @=> float swing[] ;
    for ( beat_mark => int t; t <= measures ; t ++ )
    {   
        if ( now >= song.end ) return ; // done with the music     
        //if ( now < m_start ) return ;  // do not play before cue
        //play some notes
        chords[t%chords.cap()] @=> int notes[] ;
        if (!Math.random2(0, 5) ) { 0 => notes[0]  ; } 1 => notes[2] ;  
        for( 1 => int beat ; beat <= 2*times ; beat++ ) {
          if (notes[0] != 0) {
              notes[Math.random2(0,3)] => int n ;
              n%7 => int note ; n/7 + 1 => int octave;
              octave * Std.mtof(scale[note]) * 2.0 => instr.freq ; 
              velocity * (.5 + .5 * t / measures ) => instr.noteOn ;
          } else {
              1.0 => instr.noteOff ;
          }
        swing[beat%2] * song.halfNote => now ;
        }
    
    }
}


// do not assume scale keeps constant
play_section( 0, 2, 4, song.scale(), solo, [[3,4,7,11], [7,11,13,14] ])  ;
play_section( 0, 1, 1, song.scale(), solo, [[0,0,0,0]])  ;
play_section( 0, 2, 4, song.scale(), solo, [[1,3,6,7], [3,4,7,11], [7,11,13,8], [3,6,7,9] ])  ;
.5 => solo.noteOff ;
2::song.quarterNote => now ; // left the delay do it thing at the end (only for large values)  
1 => solo.noteOff ;
