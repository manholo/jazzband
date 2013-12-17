// Song.ck

// // Song manages the timming and scale issues, delegating in a Metronome and Scale objetcs.
// // hold for common sharing the current key and mode, and the song end time. 


// uses scale builder Scale

<<< "Added Song" >>>;

public class Song  // this is class BPM "slightly" modified
{
    // global variables
    // to be shared.
    static int current_key  ;    // current key (as midi) and
    static int current_mode ;    // scale mode, defaults to C Ionian
    //static int notes[]      ;
    // 
    static time end ;            // song end, a time point. Must be initialized
    
    Scale current_scale ;        // current scale (from current key and mode)
    Metronome metro ;            // handles all timing
    static int initd ;      // init once
    
    // init code, only once
    if (!initd) init () ;

    // init sets some defaults.
    fun void init() {
        48 => current_key ;
        1 => current_mode ;
        current_scale.key_mode( current_key, current_mode );
        metro.signature( 4, 4 ); // already is 4/4 by default
        1 => initd ;
    }


    // sets the end time from now, usually in seconds or measures.
    fun void ends(dur ticks){
         now + ticks => end ;
        <<<"(", now, ") song ends at ", end,  "in", ticks, " ticks">>>;
    }

    // current beats per minute, deletate to metronome
    fun float bpm() {
        return metro.current_bpm ;
    }

    // seconds per beat. utility
    fun float spb( float spb) {
        return metro.spb(spb); // delegate to metro
    }

    // set timming signature
    fun void signature( int n, int m ) {
        <<<"Song is ",n, "/", m>>>;
        metro.signature(n, m) ;
    }

    // get the current timming signature from metronome
    fun int[] current_signature() {
        return metro.current_signature() ;
    }

    // the metronome keeps the current measure
    fun int current_measure() {
        metro.current_measure;
    }

    // and the current beat, taking into account the current timming signature
    fun int current_beat(){
        metro.current_beat;
    }
    
    // sets key and mode
    fun void key_mode( string key, int mode ) {
        <<<"Song key ",key, "mode ", mode>>>;
        current_scale.key_mode(key, mode) ; // notes not used 
        current_scale.key => current_key ;
        current_scale.mode => current_mode ;
    }

   // sets key and mode, for key as midi
   fun void key_mode( int key, int mode ) {
       current_scale.key_mode(key, mode) ; // notes not used 
       key => current_key ;
       mode => current_mode ;
    }

    // delegates to scale, changes it to match chord, also returns the chord duration
    fun int change_for( string chord ) {
        current_scale.change_for( chord ) => int duration ;
        current_scale.key => current_key ;
        current_scale.mode => current_mode ;
        return duration ;
    }
    
    fun int[] scale() {
        <<<"harmony to scale">>>;
       //<<<current_key, current_mode>>>;
       //current_scale.key_mode(current_key, current_mode) ;
       //return current_scale.notes ;
   }
   
   // synchronize to period. delegate to the metronome.
   fun void sync(){
       metro.sync(); 
   }

   // sets tempo
   fun void tempo(float bpm)  {
       <<<"Song tempo is ",bpm>>>;
       metro.tempo(bpm) ;
   }
   
   // accelerate the tempo up (or down),  up to final_bpm, in the given number of measures
   fun void accelerando(float final_bpm, int measures){
       metro.current_bpm => float old_bpm ; // save to restore later
       final_bpm - metro.current_bpm => float inc_bpm ;
       repeat (measures) {
           tempo(metro.current_bpm + inc_bpm / measures ) ; // increase (or decrease) the tempo
           metro.spm(1)  => now ;                           // jump a measure
       }
       tempo(old_bpm) ; // restore original bpm
   }

}


// Song song ;
// song.init();

// song.tempo(80) ;
// song.set_signature( 4,4 );
// song.key_mode("C", 1) ;
// <<< song.bpm() >>> ;
// song.tempo(60) ;
// <<< song.bpm() >>> ;
//spork ~ song.accelerando(80, 4) ;
// while (true) {
    //     <<< song.bpm() >>> ;
    //     song.quarterNote => now ;
    // }

