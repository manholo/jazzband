// Scale class, for now it handles major modes

<<<"Added Scale">>>;


public class Scale
{
    int key ;                // midi value for the root note 
    int mode ;               // the mode for the scale
    int notes[7] ;           // the scale
    int mode_for_suffix[8] ; // assoc array suffix mode -> int mode (for use in key_mode)
    static int allnotes[] ;  // all note names and their midi value ( from C3 up )
    static int initd ;       // 1 once Scale static data is initialized (so, only once)

    if (!initd) {
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
        set_mode_suffixes ();
        
        // set up the known modes and their prefixes:
        //["", "m7", "b9b6", "+4", "7", "-", "0", "o" ]  @=> string known_modes[] ;
        //for (0 => int n; n < known_modes.cap(); n++) (n + 1) => mode_for_suffix[known_modes[n]] ;
        //for (1 => int n; n < 9; n++) <<< n, known_modes[n-1], mode_for_suffix[known_modes[n-1]]>>>;
        
        
        // initialized!
        1 => initd ; // do not compute again allnotes, et al.
    }


    fun void set_mode_suffixes() {
        ["", "m7", "b9b6", "+4", "7", "-", "0", "o" ]  @=> string known_modes[] ;
        for (0 => int n; n < known_modes.cap(); n++) (n + 1) => mode_for_suffix[known_modes[n]] ;
        // for (1 => int n; n < 9; n++) <<< n, known_modes[n-1], mode_for_suffix[known_modes[n-1]]>>>;
    }
    
    // converts "C" to 48, "C#" to 49, "Bb" to 58, etc. Enharmonics included
    // (not doubling ## nor bb, its just a couple of lines, anyway) 
    fun int note2midi( string name ){
        // this uses the local assoc array, must initialize it with init_notes()
        return allnotes[name] ;
    }

    // returns the mode for a give suffix. e.g. "7" is Mixolidian => 5, "M" is Ionian => 1...
    fun int mode_for( string suffix ) {
        // for some reason I must set this up again. 
        set_mode_suffixes ();
        return  mode_for_suffix[suffix] ; 
    }

    // sets the key and mode. key as string like "C#"
    fun void key_mode(string root, int m) {
        key_mode( note2midi(root), m);
    }

    // same, from a midi note and mode number
    fun void key_mode(int root, int m)
    {
        <<<"in key_mode int", root, m>>>;
        root => key ;
        m => mode ;
        [[ 2,2,1,2,2,2,1], // 1: IONIAN
         [ 2,1,2,2,2,1,2], // 2: DORIAN
         [ 1,2,2,2,1,2,2], // 3: PHRYGIAN
         [ 2,2,2,1,2,2,1], // 4: LYDIAN
         [ 2,2,1,2,2,1,2], // 5: MIXOLYDIAN
         [ 2,1,2,2,1,2,2], // 6: AEOLIAN
         [ 1,2,2,1,2,2,2], // 7: LOCRIAN, half diminished
         [ 2,1,2,1,2,2,2]  // 8: SUPERLOCRIAN, LOCRIAN#2, half diminished#2
        ] @=>int modes[][] ;
        modes[mode-1] @=> notes ;  
        root => int next_note ;
        0 => int step ;
        for (0=>int n; n<7; n++) {
            notes[n] => step ;
            next_note => notes[n] ;
            step +=> next_note ; 
            <<< "new notes ", n+1, step, ":", notes[n] >>>;
        }
    }

    // gets the root and mode from the chord name
    // uses RegEx, guess what? It is not in the doc, neither. Seems all the good stuff it is undocumented.
    fun int [] chord_info( string chord) {
        string match[4] ;                             // for the results
        
        // RegEx match the chord with a regular expresion:
        // takes the note and a possible modifier into match[1] - whatever matches the first parentheses
        // the rest, if there are chars left, is the mode sufix, ends up in match[3] - the third parentheses match
        // match[2] gets the modifier, if any  - the second (inner) parentheses match
        
        if ( RegEx.match("([1248])([A-G](#|b)*)(.*)", chord, match ) ) {
            <<<chord, "match: ", match[1], match[2], match[4]>>>;
            return [ Std.atoi ( match[1]),           // duration of chord usually none (1) or 2
                     note2midi( match[2]),           // the root, as midi
                     mode_for ( match[4])  ];        // the mode suffix, as int 
        } else { 
                <<< chord, ": no match">>> ;
                return [0,0,0] ;
        }        
    }

    fun int change_for( string chord ) {
        int info [2] ;
        chord_info( chord ) @=> info ;
        key_mode(info[1], info[2]) ; // set key and mode from the chord analisys
        return info[0];              // return duration
    }
    
}

//Scale scale;
//scale.init_notes();
//scale.key_mode("C", 1) ;//@=> int notes[];


