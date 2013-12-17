// bass.ck
// // A random song. "improvise" over a given harmony

Song song ;  
//song.init(); // init'd by score.ck 
song.sync();  // sync to the quarter


// sound chains main mixer. This is a global var used in some functions
Mandolin bass => NRev r => Pan2 mix => dac ;

0.1 => r.mix;
0.2 => mix.pan ; 
0.5 => mix.gain ;
0.0 => bass.stringDamping ;
0.02 => bass.stringDetune ;
0.05 => bass.bodySize ;

//now + song.end::second => time end ;
0.3 => float velocity ;


// gets the chord to play the bass notes from it. can always play root instead.
fun void play_section( int beat_mark, int times, int measures, int scale[], StkInstrument instr, int chords[][]) {
    [ .6, .4 ] @=> float swing[] ;
    for ( beat_mark => int t; t <= measures ; t ++ )
    {   
        if ( now >= song.end ) return ; // done with the music     
        //if ( now < m_start ) return ;  // do not play before cue
        //play some notes
        chords[t%chords.cap()] @=> int notes[] ;
        1 => notes[2] => notes[3] ;  
        for( 1 => int beat ; beat <= 2*times ; beat++ ) {
            if (notes[0] != 0) {
                notes[Math.random2(0,3)] => int n ;
                n%7 => int note ; n/7 + 1 => int octave;
                octave * Std.mtof(scale[note]) / 2.0 => bass.freq ; 
                velocity * (.5 + .5 * t / measures ) => bass.pluckPos => bass.noteOn ;
            } else {
                1.0 => bass.noteOff ;
            }
            swing[beat%2] * song.quarterNote => now ;
        }
        
    }
    
}


// do not assume scale keeps constant
// bass.follow( song.harmony )
// bass.play_section( 5 )
play_section( 0, 4, 5, song.scale(), bass, [[1,3,6,7], [3,4,7,11], [7,11,13,14], [3,5,7,14], [3,6,7,8] ])  ;
play_section( 0, 2, 4, song.scale(), bass, [[3,4,7,11], [7,11,13,14] ])  ;
play_section( 0, 1, 1, song.scale(), bass, [[0,0,0,0]])  ;
play_section( 0, 2, 4, song.scale(), bass, [[1,3,6,7], [3,4,7,11], [7,11,13,14], [3,6,7,8] ])  ;

2::song.quarterNote => now ; // left the delay do its thing at the end (only for large values)         






