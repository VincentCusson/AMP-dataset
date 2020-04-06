var express = require('express');
var app = express();
var path = require('path');
var MIDIFile = require('./public/lib/midifile/MIDIFile.js');
var bodyParser = require('body-parser');
var fs = require('fs');

app.use(bodyParser.urlencoded());

app.use(bodyParser.json());

app.use(express.static('public'))

app.use(bodyParser.urlencoded({
    extended: true
  }));

app.get('/', function(req, res) {
    res.sendFile(path.join(__dirname + '/public/index.html'));
});

app.post('/savemidi', function(req,res) {
    var DataBody = req.body;
    console.log("Saving New Midi File From Session :" + DataBody.sessionuuid);
    midi_file = new MIDIFile();
	midi_file.setTrackEvents(0,JSON.parse(DataBody.firsttrackevents));
	midi_file.addTrack(1);
	midi_file.setTrackEvents(1, JSON.parse(DataBody.events));
    output_array_buffer = midi_file.getContent();
    fs.appendFileSync("./midifiles/" + DataBody.sessionuuid + "_" + Date.now() + ".midi", output_array_buffer);
    console.log("Saved new midi file !!!");
});

app.listen(8080);