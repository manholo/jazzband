
<<< "Added Metronome" >>>;

public class Metronome  // this is class keeps track of current song  measure and beat for all players
{
    // global variables
    //
    static dur fullNote,
               halfNote,
               quarterNote,
               eighthNote,
               sixteenthNote,
               thirtysecondNote;         // duration of some notes in the current tempo
    //
    120 => static float current_bpm ;    // current tempo in bpm               
    4   => static int num_sg;
    4   => static int base_sg ;          // current signature, defaults to 4/4
    1   => static int current_measure ;  // current meassure and beat. metronome keeps track of this
    1   => static int current_beat ;     
    // must be initialized
    // static time end ;             // song end, in sec

    // Not static, because Chuck can not declare non prim statics yet:
    dur current_durations[6];         // current note durations. 
    
    // init code
    init() ;
    
    fun void init(){
        tempo(current_bpm); 
    }
    
    fun float bpm() {
        return current_bpm ;
    }
    
    fun float spb( float spb) {
        return 60.0/(current_bpm) ; // seconds per beat
    }

    // set signature
    fun void signature( int n, int m ) {
        n => num_sg ;
        m => base_sg ;
    }
    
    fun int[] current_signature() {
        return [num_sg, base_sg] ;
    }

    // 4 is a quarter, 8, an eight, 2 a half and 1 a whole.
    // spn returns their current duration
   fun dur spn( int note ) {  
       return current_durations[(Math.log(note)/Math.log(2))$ int] ;
   }

   // duration in seconds, per meassure in the current signature and tempo
   fun dur spm( int measures ) {
       return measures * num_sg * spn( base_sg ) ;
   }

   // synchronize withing a note (quarter is 4). From the chuck manual, p. 70
   // e.g, sync(4) ; 
   fun void syncTo( int note ){
       spn( note ) => dur d;
       d - (now % d) => now; 
   }
   // syncs to the current signature base note
   fun void sync() { syncTo( base_sg ) ; } // current_signature[1]
   
   // sets tempo
   fun void tempo(float bpm)  {
       // BPM, example 120 beats per minute
       bpm => current_bpm ; // save it
       // update note durations with the new seconds per beat value
       spb(bpm) :: second => quarterNote;
       quarterNote   * 0.5  => eighthNote;
       eighthNote    * 0.5  => sixteenthNote;
       sixteenthNote * 0.5  => thirtysecondNote;
       quarterNote   * 2    => halfNote ;
       halfNote      * 2    => fullNote ;
       
       // store data in array used in spn()
       [fullNote, halfNote, quarterNote, eighthNote, sixteenthNote, thirtysecondNote] @=> current_durations;
   }
   
   // accelerate the tempo up (or down),  up to final_bpm, in the given number of measures
   fun void accelerando(float final_bpm, int measures){
       current_bpm => float old_bpm ; // save to restore later
       final_bpm - current_bpm => float inc_bpm ;
       repeat (measures) {
           tempo(current_bpm + inc_bpm / measures ) ; // increase (or decrease) the tempo
           spm(1)  => now ;                           // jump a measure
       }
       tempo(old_bpm) ; // restore original bpm
   }

   // keeps track of current measure and beat, use as spork ~ metronome.start() in initialize.ck/score.ck
   fun void start(BeatEvent mEvent, BeatEvent bEvent, time fine)
   {
       <<<"metronome start">>>;
       // now + end::second => time fine ;
       while ( 1 ) {//now < fine ) {
           <<< "M", current_measure >>> ;
           current_measure => mEvent.measure ;
           current_beat    => mEvent.beat ; // should be 1 always
           mEvent.broadcast() ;             // signal the new measure
           repeat (num_sg) {
               <<< "b", current_beat >>> ;
               current_measure => bEvent.measure ;
               current_beat    => bEvent.beat ;
               bEvent.broadcast() ;        // signal the new beat
               spn( base_sg )  => now ;    // jump a beat         
               current_beat++ ;            // count this beat
           }
           1 => current_beat ;             // here we go again
           current_measure++ ;             // next measure
       }
   }

}

// Score should spark metronome.start()