const noteReference = new NoteReference()
const domPiano = new DomPiano(0,8,noteReference)
this.domPiano = domPiano
WebMidi.enable(function (err) {

  if (err) {
    console.log("WebMidi could not be enabled.", err);
  } else {
    console.log("WebMidi enabled!");
  }

  // List MIDI devices
  var inputs = WebMidi.inputs;
  var select = document.getElementById("selectIn");
  var inputList = [];
  for (var i = 0; i < inputs.length; i++) {
      var opt = inputs[i].name;
      var ele = document.createElement("option");
      inputList.push(opt)
      ele.textContent = opt;
      ele.value = opt;
      select.appendChild(ele);
  }
  //Select MIDI device
  var strUser = select.value;
  var inputNumber = 0;
  var input = WebMidi.inputs[inputNumber];
  select.onchange = function(){
    strUser = select.value
    inputNumber = inputList.indexOf(strUser);
    console.log(strUser)
    input.removeListener(); //To remove previous input selected
    input = WebMidi.inputs[inputNumber]; // Listen for a 'note on' message on all channels

    var notes = [];
    //See doc for the event noteon object
    //https://djipco.github.io/webmidi/latest/classes/Input.html#
    // TODO see timecode
    input.addListener('noteon', "all",
      function (e) {
        console.log("Received 'noteon' message (" + e.note.name + e.note.octave + ").");
        //this.domPiano.blinkNote('C2',60)
        this.domPiano.noteOn(e.note.name + e.note.octave,60)
        //console.log(e.data) //Raw MIDI message (array of 8 bit value)
        //Display the note number in the html page
        document.getElementById("myspan").textContent= e.note.name + e.note.octave;
        //Add the note event to a list to write the midi file
        notes.push(e.note.number, e.timestamp)
      }
    );
    input.addListener('noteoff', "all",
      function (e) {
        console.log("Received 'noteoff' message (" + e.note.name + e.note.octave + ").");
        this.domPiano.noteOff(e.note.name + e.note.octave,60)
        notes.push(e.note.number, e.timestamp)

      }
    );
  };
  // var notes = [MidiEvent.noteOn(60, 0),
  //   MidiEvent.noteOff(60, 1000),
  //   MidiEvent.noteOn(62, 0),
  //   MidiEvent.noteOn(62, 500)];
  // Create a track that contains the events to play the notes above
  //var track = new MidiTrack({ events: notes });
  // Creates an object that contains the final MIDI track in base64 and some
  // useful methods.
  //var song  = MidiWriter({ tracks: [track] });
  // Alert the base64 representation of the MIDI file
  // alert(song.b64);
  // Play/save the song (depending of MIDI plugins in the browser). It opens
  // a new window and loads the generated MIDI file with the proper MIME type
  //song.save();

  // // Create MIDI file
  // var midi = new Midi()
  // // add a track
  // const track = midi.addTrack()
  // var save = document.getElementById("save");
  save.onclick = function(){
    //fs.writeFileSync("output.mid", new Buffer(midi.toArray()))
    //song.save();
    console.log("saved midi file")
  };
});
