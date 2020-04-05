const noteReference = new NoteReference()
const domPiano = new DomPiano(0,8,noteReference)

this.domPiano = domPiano
var notes = [];

MIDI.loadPlugin({
		soundfontUrl: "MIDI.js-master/examples/soundfont/",
		instrument: "acoustic_grand_piano",
		onprogress: function(state, progress) {
			console.log(state, progress);
		}
	});

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


    //See doc for the event noteon object
    //https://djipco.github.io/webmidi/latest/classes/Input.html#
    // TODO see timecode
    input.addListener('noteon', "all",
      function (e) {
        //console.log("Received 'noteon' message (" + e.note.name + e.note.octave + ").");
        this.domPiano.noteOn(e.note.name + e.note.octave,60)//Change color on keyboard
        //console.log(e.data) //Raw MIDI message (array of 8 bit value)
        //Display the note number in the html page
        document.getElementById("myspan").textContent= e.note.name + e.note.octave;
        //Add the note event to a list to write the midi file
        notes.push(e.note.number, e.timestamp)
        MIDI.setVolume(0, 127);
        MIDI.noteOn(0, e.note.number, e.rawVelocity, 0);

      }
    );
    input.addListener('noteoff', "all",
      function (e) {
        //console.log("Received 'noteoff' message (" + e.note.name + e.note.octave + ").");
        this.domPiano.noteOff(e.note.name + e.note.octave,60)
        notes.push(e.note.number, e.timestamp)
        MIDI.noteOff(0, e.note.number, 0);
      }
    );
  };

  save.onclick = function(){
    //console.log(notes)
    console.log("saved midi file")
  };
});
