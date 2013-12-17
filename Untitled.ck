
fun string[] tokenize( string in ){
    <<<in>>>;
    // do not even try to find this in the doc. This even may not work for you.
    // see https://lists.cs.princeton.edu/pipermail/chuck-users/2012-July/006808.html
    // and better http://chuck.cs.princeton.edu/release/VERSIONS
    StringTokenizer token; // a string tokenizer just keeps cuting at spaces at each call to .next() 
    string out [1] ;
    token.set(in);
    string last_chord ;
    0 => int pos ;
    "1" => string chdur ;                     // chord duration, whole by default
    while (token.more()) {
        token.next() @=> string n ;
        if (n == "/") continue ;              // ignore separators
        if (n == "%") last_chord @=> n;       // substitute for last chord. better not be the first chord.
        if (n == "-") {                       // then current and last chord have duration 2
            "2" => chdur ;
            chdur + last_chord @=> out[pos] ; // correct the last one
            continue ;
        }
        n @=> last_chord ;
        out << chdur + last_chord ;
        "1" => chdur ;                 // reset chord duration
        pos ++ ;
    }
    return out;
}
    
int mode_for_suffix[1] ; // assoc array suffix mode -> int mode (for use in key_mode)
int allnotes[] ;  // all note names and their midi value ( from C3 up )
    
// initialization code
int tmp_notes[12] ; // allnotes can't be declared as "static int alnotes[12]" so, trick.
[48, 50, 52, 53, 55, 57, 59] @=> int cmajor[] ;
for (0=>int n; n<7 ; n ++){
    // substring is not even in the doc.
    // see http://lists.cs.princeton.edu/pipermail/chuck-dev/2012-March/000436.html
    // I could do 48 => notes["C"] ; ... 59 => notes["B"] ; but I'm lazy
    // also, notes is an associative array. see Chuck Manual, p 46
    "CDEFGAB".substring(n,1) => string name ;
    cmajor[n] => int value ;
    value     @=> tmp_notes[name];
    value + 1 @=> tmp_notes[name+"#"];
    value - 1 @=> tmp_notes[name+"b"];
}
tmp_notes @=> allnotes;
// set up the known modes and their prefixes:
["", "m7", "b9b6", "+4", "7", "-", "0", "o" ] @=> string known_modes[] ;
for (0 => int n; n < known_modes.cap(); n++) n @=> mode_for_suffix[known_modes[n]] ;

// converts "C" to 48, "C#" to 49, "Bb" to 58, etc. Enharmonics included
// (not doubling ## nor bb, its just a couple of lines, anyway) 
fun int note2midi( string name ){
    // this uses the local assoc array, must initialize it with init_notes()
    return allnotes[name] ;
}
// returns the mode for a give suffix. e.g. "7" is Mixolidian => 5, "M" is Ionian => 1...
fun int mode_for( string suffix ) {
    return mode_for_suffix[suffix] ;
}


// get the duration, root and mode from the chord name
// uses RegEx, guess what? It is not in the doc, neither. Seems all the good stuff it is undocumented.
fun int [] chord_info( string chord) {
    //<<<chord >>>;
    string match[4] ;                             
    if ( RegEx.match("([1248])([A-G](#|b)*)(.*)", chord, match ) ) {
         //<<<chord, "match: ", match[1], match[2], match[4]>>>;
         return [ Std.atoi(match[1]),         // duration of chord usually none (1) or 2
                  note2midi( match[2]),   // the root, as midi
                  mode_for(  match[4]) ]; // the mode suffix, as int 
    } else { 
          <<< chord, ": no match">>> ;
          return [0,0,0] ;
    }
 
}


//int info[1];
//chord_info("E7") @=> info ;
//<<<info[0], info[1]>>>;

tokenize("E7 A7 E7 % / A7 A7 E7 E7 / B7 A7 E7 F#m7 - B7") @=> string r[] ;

int info[2];
for (1=>int p; p< r.cap(); p++) {
    chord_info(r[p]) @=> info ;
    <<<p, r[p], info[0], info[1], info[2] >>>;
}


/*
// compute the numeric scale changes for string of chord changes 
fun int[][][] changes( string chs ) {
    tokenize( chs ) @=> string ch [];
    int out [0][0][0];  // numeric scale changes
    int info[2];
    1 => int measure ;
    1 => int nch ;   // chords in a measure, usually just 1
    int m_info[0][2] ; // numeric info for the chords in a measure
    for (1=>int p; p< ch.cap(); p++) {
        chord_info(ch[p]) @=> info ;
        //<<<p, ch[p], info[0], info[1], info[2] >>>;
        //m_info << [ info[0], info[1], info[2] ] ;
        m_info << info;
        <<<"m_info:", m_info.cap()>>>;
        if (info[0] > 1) { <<<"C">>>; continue ; } // keep adding chords to this measure
        out << m_info ;
        <<<"out:", out.cap()>>>;
        m_info.clear() ;
    }
}


changes("E7 A7 E7 % / A7 A7 E7 E7 / B7 A7 E7 F#m7 - B7") @=>  int r[][][] ;

<<<"n chords ", r.cap>>>;

for (0=>int i; i<r.cap(); i++ )     
    for(0=>int j; j< r[i].cap(); j++)
        for(0=>int k; k< r[i][j].cap(); k++)
            <<< i,j,k>>>; //, r[i][j][k] >>>;

    
    



