// drums.ck
// // A random song. "improvise" over a given harmony

// 

Song song ;  
//song.init(); // init'd by score.ck 
song.sync();  // sync to the quarter


// sound chains main mixer. This is a global var used in some functions
Gain mix => dac ;


// loads samples from directory audio into an array of SndBuf the named samples.
// Chains all snd buffers to the global mix Mixer.
fun SndBuf[] load_samples( string name[] )
{
    SndBuf sb[name.cap()] ; // a snd buffer per name in the input string array names
    // read the the soundbuffer, chain it to the mixer
    for ( 0 @=> int sample; sample < name.cap(); sample++ ) {
        me.dir(-1)  + "/audio/" + name[sample] + ".wav" @=> string fname ; // complete the filename
        //<<<"Reading sample " + sample + ": " + fname>>> ;
        fname => sb[sample].read ;                        // and read sound buffer                  
        sb[sample] => Pan2 p => mix ;                     // chain the sound buffer to the mixer
        (sample + 1.0 ) / (1.0 * name.cap()) => p.pan ;   // pan the kit around listener :-) 
        //<<<p.pan()>>>;
        sb[sample].samples() => sb[sample].pos; // set all playheads to end so no sound is made
    }
    return sb ;   // return the chained, stoped samples.
}

// this is the work horse, play the given patters for a duration.
0 => int beat_mark; // global beat marker 
fun void play_patterns_for( int pattern[][], 
                            int sound[],  
                            int measures, 
                            int phrase_lenght,
                            int hpb, // hits per beat 
                            SndBuf sb[] 
                           )
{
  // initialize beat mark. goes from 1 to 16 in cycle
   1 => int pulse;   
  .7 => float velocity ; // final velocity for chords
  .8 => float chgain ;
  .1 => float gain ;     // tmp
  gain => mix.gain ;

  for ( beat_mark => int t; t <= measures; t ++ ){                             
  // play the beats, four per quarter!
    for (0 @=> int hit; hit < hpb; hit++)  {
       //<<< "Beat: ", t, "hit: ", hit, "pulse: ", pulse >>>;
       for (0 @=> int p; p < sound.cap(); p++) {
           if ( Std.rand2(1,5) == 1 ) Std.randf() * pattern[p][pulse-1] / 100.0 => gain ; 
           else pattern[p][pulse-1] / 100.0 => gain ; 
           chgain * gain => sb[p].gain ; 0 => sb[p].pos;      // play sound on its beats
       }                              
       pulse % phrase_lenght + 1 @=> pulse ; // get the next beat. may use something like "t%phr_len => beat" instead 
       (1.0/hpb)::song.quarterNote => now; // advance time
    }
    t => beat_mark ; // update beat_mark
  }        
}


// all the sound buffers are collected in this vector
load_samples( [  "kick_01", "kick_02", "hihat_01", "snare_01" ] ) @=> SndBuf sb[] ; 
0 @=> int KICK1 ;  1 @=> int KICK2 ;  2 @=> int HIHAT ;  3 @=> int SNARE ; 


play_patterns_for(
                  //   1,  2,  3,  4,  5,  6,  7,   8,  9, 10, 11, 12, 13, 14, 15,  16, 
                   [[ 80,  0, 80,  0, 80,  0, 80, 100, 80,  0, 80,  0, 80,  0, 80, 100 ],
                    [ 80,  0, 80,  0, 80,  0, 80,   0, 80, 60, 80,  0, 80,  0, 80,   0 ],
                    [ 40, 80,  0, 40, 80, 80, 80,  80, 40,  0, 80, 40, 80, 80, 40,    0 ]],
                    [KICK1, SNARE, HIHAT],
                    24, // section length
                    16, // rhythm phrase length
                    3,  // hits per beat
                    sb
                    ) ;






