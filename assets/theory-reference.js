const NOTE_NAMES = ['A','A#','B','C','C#','D','D#','E','F','F#','G','G#']

const A0_NUM = 21
const MAX_MIDI_NUM = 127

class NoteReference{
  constructor(){
    const midiReference = {}

    const numNotes =  NOTE_NAMES.length
    for(let x = A0_NUM; x <= MAX_MIDI_NUM; x++){
      const letter = NOTE_NAMES[(x - A0_NUM) % numNotes]
      const octave = Math.floor((x - numNotes) / numNotes)
      const name = letter + octave
      midiReference[x] = { letter, octave, name }
    }

    this.midiRef = midiReference
    this.letterHierarchy = {
      'C': 0, 'C#': 1, 'D': 2,
      'D#': 3, 'E': 4, 'F': 5,
      'F#': 6, 'G': 7, 'G#': 8,
      'A': 9, 'A#': 10, 'B': 11
    }
  }
}
