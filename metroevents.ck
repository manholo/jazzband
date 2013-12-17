// Metronome Event, a event that include the current beat and measure

// Just use two separate instances of thus if you want to have an event per measure,
// and another at each beat.

public class BeatEvent extends Event {
    1 => int measure ;
    1 => int beat ;
    string chord ;
    int mode ; // not filled
    int scale [7] ;
}

