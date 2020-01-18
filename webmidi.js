WebMidi.enable(function (err) {

  if (err) {
    console.log("WebMidi could not be enabled.", err);
  } else {
    console.log("WebMidi enabled!");
  }

  var inputs = WebMidi.inputs;
  var select = document.getElementById("selectIn");

  for (var i = 0; i < inputs.length; i++) {
      var opt = inputs[i].name;
      var el = document.createElement("option");
      el.textContent = opt;
      el.value = opt;
      select.appendChild(el);
  }
  var strUser = select.value;
  select.onchange = function(){
    strUser = select.value
    console.log(strUser)
  };

  // Listen for a 'note on' message on all channels
  // TODO see timecode
  var input = WebMidi.inputs[0];
  input.addListener('noteon', "all",
    function (e) {
      console.log("Received 'noteon' message (" + e.note.name + e.note.octave + ").");
      document.getElementById("myspan").textContent= e.note.name + e.note.octave;
    }
  );

});
