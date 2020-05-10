### Crowdsourced MIDI recorder

Work done in the context of MUMT621.

This project describes the first steps toward the creation of the AMP (Amateur MIDI Performance) dataset. This code includes the Web recording interface and early data analysis in Python.

---

To run the web page locally:
* Visit the official [Node.js website](https://nodejs.org/) and get a pre-built installer for your platform
* In the root folder, run `npm i` to install dependencies
* From your terminal, run `node server.js` to launch the server
* With the Chrome browser, access http://localhost:8080

To run the MIDI analysis with Python 3:
* From your terminal, install the dependencies with `pip install -r requirements.txt`
* In the root folder, run the script with `python midiAnalysis.py`







##### Acknowledgments
* [OutsourcedGuru/syn-midi](https://github.com/OutsourcedGuru/syn-midi)
* [mudcube/MIDI.js](https://github.com/mudcube/MIDI.js)
* [1j01/midi-recorder](https://github.com/1j01/midi-recorder)
* [mido/mido](https://github.com/mido/mido)
* [djipco/webmidi](https://github.com/djipco/webmidi)
