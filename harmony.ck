// piano.ck
// A random song. "improvise" over a given harmony

<<<"Added Piano">>>;

Song song ;  


public class Harmony {
    
    // sound chains main mixer (a pan ugen).
    Pan2 mix;
    0.4 => float velocity ;    
    TubeBell instr[];
    
    0 => static int initd ;
    if (!initd) init() ;
    
    fun void init() {
        mix => dac ;
        -0.2 => mix.pan ;
        .1 => mix.gain ;
    }

    // ModalBar, TubeBell
    // create, chain to mix and mute the chord instrument
    fun TubeBell[] make_section( int ns ) { 
        TubeBell instrument[ns];
        Delay d ;
        JCRev r => mix ;
        1::song.metro.quarterNote => d.max => d.delay ;
        // quarter => d.delay ;
        for (0 => int n; n < ns ; n++ ) {
            instrument[n] => d => r ; // d => mix ;
            0 => instrument[n].noteOff;
        }
        instrument @=> instr;
    }

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

    fun void play_chord( string chord, int scale[]) {
        <<< "piano", chord >>>;
        // for now, play [3, 5, 6, 9] always 
        play_chord( velocity, [3, 5, 7, 9], scale ) ; 
    }

    fun void start(BeatEvent mEvent, BeatEvent beat) {
        while(1) {
            beat => now ;
            play_chord(  mEvent.chord, mEvent.scale ) ;
        }
    }
    
    
}


// four notes chords
//make_section( 4 ) ; //  @=> TubeBell instr[]; 
