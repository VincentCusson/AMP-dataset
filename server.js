var express = require('express');
var app = express();
var path = require('path');
var MIDIFile = require('./public/lib/midifile/MIDIFile.js');
var bodyParser = require('body-parser');
var fs = require('fs');
const store = require('data-store')({ path: './data.json' });


app.use(bodyParser.urlencoded({ extended: true }));

app.use(bodyParser.json());

app.use(express.static('public'))

app.use(bodyParser.urlencoded({
    extended: true
}));

app.get('/', function (req, res) {
    res.sendFile(path.join(__dirname + '/public/index.html'));
});

app.post('/savemidi', function (req, res) {
    var DataBody = req.body;
    var UserObj;

    if(store.hasOwn(DataBody.sessionuuid) == false) {
        UserObj = {
            SessionId:DataBody.sessionuuid,
            test:"TOTOTO",
            midifiles: []
        }
    } else {
        UserObj = store.get(DataBody.sessionuuid);
    }

    console.log(UserObj);
    console.log("Saving New Midi File From Session :" + DataBody.sessionuuid);
    midi_file = new MIDIFile();
    midi_file.setTrackEvents(0, JSON.parse(DataBody.firsttrackevents))
    midi_file.addTrack(1)
    midi_file.setTrackEvents(1, JSON.parse(DataBody.events))
    output_array_buffer = midi_file.getContent();
    var filename = "./midifiles/" + DataBody.sessionuuid + "_" + Date.now() + ".midi";
    fs.appendFileSync(filename, Buffer.from(output_array_buffer));
    UserObj.midifiles.push(filename);
    console.log("Saved new midi file !!!");
    store.set(DataBody.sessionuuid,UserObj);
    res.send("Saved new midi file !!!");
});

app.listen(8080);

console.log("Server Started On Port 8080 !");
