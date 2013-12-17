// score.ck
// "On time for Kansas City" A random song. "improvise" over a given harmony

<<<"Added Score">>>;

// utility function for chord parsing
fun string[] tokenize( string in ){
    //<<<in>>>;
    // do not even try to find this in the doc. This even may not work for you.
    // see https://lists.cs.princeton.edu/pipermail/chuck-users/2012-July/006808.html
    // and better http://chuck.cs.princeton.edu/release/VERSIONS
    StringTokenizer token;                    // a string tokenizer just keeps cuting at spaces at each call to .next() 
    string out [1] ;                          // must have at least one item. IMPORTANT: use it starting from 1 too!!!
    token.set(in);                            // set the input string
    string last_chord ;                       // needed for %
    0 => int pos ;                            // keep counting the chords 
    "1" => string chdur ;                     // chord duration, whole by default
    while (token.more()) {                    // if there are more chords, 
        token.next() @=> string n ;           // get the next chord
        if (n == "/") continue ;              // ignore separators, continue for the next chord
        if (n == "%") last_chord @=> n;       // % substitute for last chord. better not be the first chord.
        if (n == "-") {                       // "-"? then current and last chord are half notes
            "2" => chdur ;                    // chord duration is 2, half note
            chdur + last_chord @=> out[pos] ; // correct the last one
            continue ;                        // and go for the next
        }
        n @=> last_chord ;                    // save the clean chord name
        out << chdur + last_chord ;           // << operator appends new elements into array
        "1" => chdur ;                        // reset chord duration
        pos ++ ;
    }
    return out;
}
// example of use:
// tokenize("E7 A7 E7 % / A7 A7 E7 E7 / B7 A7 E7 F#m7 - B7") @=> string r[] ;


// classes already init'd by initialize.ck
Song song ;      
BeatEvent measure ;
BeatEvent beat ;

// set up our song
song.signature( 4,4 ) ;
song.tempo(120);
song.key_mode( "E", 2); // E dorian 
song.ends(60::second) ; // song lenght, aprox 30 measures at 120 bps


public class Score {
    
    string changes ;
    
    fun void start( BeatEvent measure, BeatEvent beat){
        
        //Machine.add(me.dir() + "/harmony.ck") => int harmonyID;
        //Machine.add(me.dir() + "/bass.ck") => int bassID;
        //Machine.add(me.dir() + "/drums.ck") => int drumID;
        //Machine.add(me.dir() + "/flute.ck") => int fluteID;    
        Harmony bells;
        
        song.sync() ;
        spork ~ song.metro.start( measure, beat, song.end ) ;
        spork ~ track (tokenize(changes)) ;
        spork ~ bells.start(measure, beat) ;
    }

    // follow the given changes
    fun void follow( string chs ) {
        chs @=> changes ;
    }
    
    // tracks the changes, keeps changing the mode, for the duration of the chord
    fun void track (string chs[]) {
        /// bad things happen if you try to start here from 0.
        for ( 1 => int p; p < chs.cap(); p ++ ) { // for each chord,
            // change_for sets the scale and returns the chord duration. Note it starts from 1, not 0
            song.change_for( chs[p] ) => int duration ; 
            chs[p] => measure.chord ; // tell all what is this measure about
            song.scale() @=> measure.scale ; 
            song.metro.spn( duration ) => now ; // wait for next chord
        }
    }
}


// these are the song changes, a blues:
"E7 A7 E7 % / A7 A7 E7 E7 / B7 A7 E7 F#m7 - B7 / E7 A7 E7 %" => string changes ;


// time to start with the music
Score score ;
score.follow( changes ) ;
score.start( measure, beat) ;


// do not assume song.scale() keeps the same in the following lines
// piano.play_section( 0, 4, 5, song.scale(),  [[1,3,6,7], [3,4,7,11], [7,11,13,8], [3,5,7,8], [3,6,7,8] ])  ;
// piano.play_section( 0, 2, 4, song.scale(),  [[3,4,7,11], [7,11,13,14] ])  ;
// piano.play_section( 0, 1, 1, song.scale(),  [[0,0,0,0]])  ;
// piano.play_section( 0, 2, 4, song.scale(),  [[1,3,6,7], [3,4,7,11], [7,11,13,8], [3,6,7,9] ])  ;

    
<<< song.end - now >>>;
song.end - now => now ; 


// while(1) { 1::second => now; }


//song.spm(1) => now ; // 1 measure

//song.spm(1) => now ; // 1 measure

//song.accelerando(120, 6) ;

//song.spm(6) => now ; // 6 measures
//song.accelerando(80, 2) ;


// not needed:
//Machine.remove(drumID);
//Machine.remove(pianoID);
//Machine.remove(bassID);
//Machine.remove(fluteID);


