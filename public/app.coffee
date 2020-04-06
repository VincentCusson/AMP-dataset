for el in document.querySelectorAll("noscript")
	el.remove() # for screenreaders (maybe should be earlier than this asynchronously loaded coffeescript)

el_to_replace_content_of_on_error = document.querySelector(".replace-content-on-error") ? document.body
fullscreen_target_el = document.getElementById("fullscreen-target")
canvas = document.getElementById("midi-viz-canvas")
no_notes_recorded_message_el = document.getElementById("no-notes-recorded-message")
no_midi_devices_message_el = document.getElementById("no-midi-devices-message")
loading_midi_devices_message_el = document.getElementById("selectIn")
usersurvey = document.getElementById("usersurvey")
export_midi_file_button = document.getElementById("submit")
play_file_button = document.getElementById("play-file-button")
fullscreen_button = document.getElementById("fullscreen-button")
px_per_second_input = document.getElementById("note-gravity-pixels-per-second")
note_gravity_direction_select = document.getElementById("note-gravity-direction-select")
layout_select = document.getElementById("layout-select")
midi_range_left_input = document.getElementById("midi-range-min")
midi_range_right_input = document.getElementById("midi-range-max")
learn_range_or_apply_button = document.getElementById("learn-range-or-apply-button")
learn_range_text_el = document.getElementById("learn-midi-range-button-text")
apply_text_el = document.getElementById("apply-midi-range-button-text")
cancel_learn_range_button = document.getElementById("cancel-learn-midi-range-button")
midi_devices_table = document.getElementById("midi-devices")

# options are initialized from the URL & HTML later
layout = "equal"
px_per_second = 20
note_gravity_direction = "up"
selected_range = [0, 128]
midi_file = new MIDIFile()

is_learning_range = false
learning_range = [null, null]
view_range_while_learning = [0, 128]


objectifyForm = (formArray) ->
	returnArray = {}
	for [0...10]
		returnArray[formArray[i]['name']] = formArray[i]['value']
	return returnArray

uuid = ->
  'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) ->
    r = Math.random() * 16 | 0
    v = if c is 'x' then r else (r & 0x3|0x8)
    v.toString(16)
)

sessionuuid = uuid()
console.log(sessionuuid);
midi_device_ids_to_rows = new Map

smi = new SimpleMidiInput()

#loading_midi_devices_message_el.hidden = false

on_success = (midi)->
	smi.attach(midi)
	console.log 'smi: ', smi
	console.log 'inputs (as a Map): ', new Map(midi.inputs)

on_error = (error)->
	show_error_screen_replacing_ui("Failed to get MIDI access", error)
	console.log "requestMIDIAccess failed:", error

if navigator.requestMIDIAccess
	navigator.requestMIDIAccess().then on_success, on_error
else
	show_error_screen_replacing_ui("Your browser doesn't support MIDI access.")

notes = []
current_notes = new Map
#export_midi_file_button.disabled = true

current_pitch_bend_value = 0
global_pitch_bends = []
current_sustain_active = off
global_sustain_periods = []

demo = ->
	iid = setInterval ->
		velocity = 127 # ??? range TBD - my MIDI keyboard isn't working right now haha, I'll have to restart my computer

		start_time = performance.now()

		# keys_to_be_held = [
		# 	Math.round(((+Math.sin(start_time / 6400 + Math.sin(start_time / 2345)) + 1) / 2) * 128)
		# 	Math.round(((-Math.sin(start_time / 6400 + Math.sin(start_time / 2345)) + 1) / 2) * 128)
		# ]
		# keys_to_be_held =
			# n for n in [0...128] when (start_time / 500 % n) < 4
			# n for n in [0...128] when ((start_time / 100) % (n * Math.sin(start_time / 6400 + Math.sin(start_time / 2345)) + 1) / 2) < 4
			# n for n in [0...128] when ((start_time / 100) % (n * Math.sin(start_time / 6400 + Math.sin(start_time / 2345)) + 1) / 2) < 4 and (Math.sin(start_time / 6400 + Math.sin(start_time / 2345)) > 0)
			# n for n in [0...128] when ((start_time / 100) % (n * Math.sin(start_time / 6400 + Math.sin(start_time / 2345)) + 1) / 2) < 4 and (Math.sin(start_time / 6400 + Math.sin(start_time / 2345)) > ((n / 128) - 0.5))
			# n for n in [0...128] when ((start_time / 100) % (((n / 128) - 0.5) * Math.sin(start_time / 6400 + Math.sin(start_time / 2345)) + 1) / 2) < 0.1
			# n for n in [0...128] when ((start_time / 1000) % (((n / 128) - 0.5) * Math.sin(start_time / 64000 + Math.sin(start_time / 23450)) + 1) / 2) < 0.1
			# n for n in [0...128] when (
			# 	((start_time / 100) % (((n / 128) - 0.5) * Math.sin(start_time / 6400 + Math.sin(start_time / 2345)) + 1) / 2) < 0.1 and
			# 	Math.abs(Math.sin(start_time / 640 + Math.sin(start_time / 250)) - ((n / 128) - 0.5)) < 0.5
			# )
		# t = start_time / 1000
		# keys_to_be_held =
			# n for n in [0...128] when (
			# 	((t / 1) % (((n / 128) - 0.5) * Math.sin(t / 64 + Math.sin(t / 23)) + 1) / 2) < 0.1 and
			# 	Math.abs(Math.sin(t / 6 + Math.sin(t / 2)) - ((n / 128) - 0.5)) < 0.5
			# )
		t = start_time / 1000
		# t = t % 4 if t % 16 < 4
		# root = 60 + Math.floor(t / 4) % 4
		# root = 60 + [0, 5, 3, 6][(Math.floor(t / 4) % 4)]
		root = 60 + [0, 5, 3, 6][(Math.floor(t / 4) % 4)]
		keys_to_be_held =
			# n for n in [0...128] when (
			# 	((t / 1) % (((n / 128) - 0.5) * Math.sin(t / 64 + Math.sin(t / 24)) + 1) / 2) < 0.1 and
			# 	Math.abs(Math.sin(t / 8 + Math.sin(t / 2)) - ((n / 128) - 0.5)) < 0.5
			# )
			n for n in [0...128] when (
				# (n - root) %% 12 < 1
				# (n - root) %% 12 < Math.abs(Math.sin(t / 8 + Math.sin(t / 2)) - ((n / 128) - 0.5)) 
				# ((n - root) %% 12) % Math.abs(Math.sin(t / 8 + Math.sin(t / 2)) - ((n / 128) - 0.5)) > 1

				# ((n - root) %% 12) % Math.abs(Math.sin(t / 8 + Math.sin(t / 2)) - ((n / 128) - 0.5)) %% 0.5 < 0.1 and
				# ((n - root)) % Math.abs(Math.sin(t / 8 + Math.sin(t / 2)) - ((n / 128) - 0.5)) %% 0.5 < 0.1

				# ((n - root) %% 12) %% (n - t) %% 0.5 < 0.1
				# ((n - root) %% 12) %% (-n + t) %% 0.5 < 0.1
				((n - root) %% 12) %% (n & (t / 4)) < (t / 16) %% 1 and
				((n - root)) % Math.abs(Math.sin(t / 80 + Math.sin(t / 20)) - ((n / 128) - 0.5)) %% 0.5 < 0.1
			)

		current_notes.forEach (note, note_key)->
			unless note_key in keys_to_be_held
				note.end_time = performance.now()
				note.length = note.end_time - note.start_time
				current_notes.delete(note_key)

		for key in keys_to_be_held
			old_note = current_notes.get(key)
			unless old_note
				note = {key, velocity, start_time, pitch_bends: [{
					time: start_time,
					value: current_pitch_bend_value,
				}]}
				current_notes.set(key, note)
				notes.push(note)


		no_notes_recorded_message_el.hidden = true
		export_midi_file_button.disabled = false

	, 10

# do demo
window.demo = demo

smi.on 'noteOn', (data)->
	console.log("yoyoyo");
	{event, key, velocity} = data
	old_note = current_notes.get(key)
	start_time = performance.now()
	return if old_note
	note = {
		key, velocity, start_time,
		pitch_bends: [{
			time: start_time,
			value: current_pitch_bend_value,
		}],
	}
	current_notes.set(key, note)
	notes.push(note)

	#no_notes_recorded_message_el.hidden = true
	#export_midi_file_button.disabled = false

smi.on 'noteOff', (data)->
	{event, key} = data
	note = current_notes.get(key)
	if note
		note.end_time = performance.now()
		note.length = note.end_time - note.start_time
	current_notes.delete(key)

smi.on 'pitchWheel', (data)->
	{event, value} = data
	value /= 0x2000
	current_pitch_bend_value = value
	pitch_bend = {time: performance.now(), value}
	global_pitch_bends.push(pitch_bend)
	current_notes.forEach (note, key)->
		note.pitch_bends.push(pitch_bend)

smi.on 'global', (data)->
	# if data.event not in ['clock', 'activeSensing']
	# 	console.log(data)
	if data.event is "cc" and data.cc is 64
		active = data.value >= 64 # ≤63 off, ≥64 on https://www.midi.org/specifications-old/item/table-3-control-change-messages-data-bytes-2
		if current_sustain_active and not active
			global_sustain_periods[global_sustain_periods.length - 1]?.end_time = performance.now()
		else if active and not current_sustain_active
			global_sustain_periods.push({
				start_time: performance.now(),
				end_time: undefined,
			})
		current_sustain_active = active

piano_accidental_pattern = [0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0].map((bit_num)-> bit_num > 0)

# accidental refers to the black keys
# natural refers to the white keys
nth_accidentals = []
nth_naturals = []
nth_accidental = 0
nth_natural = 0
for is_accidental, i in piano_accidental_pattern
	if is_accidental
		nth_accidental += 1
	else
		nth_natural += 1
	nth_accidentals.push(nth_accidental)
	nth_naturals.push(nth_natural)

# measurements of a keyboard
# octave_width_inches = 6 + 1/4 + 1/16
# natural_key_width_inches = octave_width_inches / 7
# accidental_key_width_inches = 1/2 + 1/16 # measured by the hole that the keys sticks up out of
# group_of_3_span_inches = 2 + 1/2 + 1/8
# group_of_2_span_inches = 1 + 3/4 - 1/16

# group_of_3_span_size = group_of_3_span_inches / octave_width_inches * 12
# group_of_2_span_size = group_of_2_span_inches / octave_width_inches * 12
# natural_key_size = 12 / 7
# accidental_key_size = natural_key_size * accidental_key_width_inches / natural_key_width_inches

# console.log {group_of_2_span_size, group_of_3_span_size, accidental_key_size}
# console.log group_of_2_span_size/natural_key_size, group_of_3_span_size/natural_key_size, accidental_key_size/natural_key_size
# 1.8712871287128714 2.9108910891089113 0.6237623762376237

export_midi_file_button.onclick = ->

	if notes.length is 0
		alert "No notes have been recorded!"
		return

	events = []
	for note in notes
		events.push({
			# delta: <computed later>
			_time: note.start_time
			type: MIDIEvents.EVENT_MIDI
			subtype: MIDIEvents.EVENT_MIDI_NOTE_ON
			channel: 0
			param1: note.key
			param2: note.velocity
		})
		events.push({
			# delta: <computed later>
			_time: note.end_time
			type: MIDIEvents.EVENT_MIDI
			subtype: MIDIEvents.EVENT_MIDI_NOTE_OFF
			channel: 0
			param1: note.key
			param2: 5 # TODO?
		})

	# TODO: EVENT_MIDI_CHANNEL_AFTERTOUCH

	for pitch_bend in global_pitch_bends
		events.push({
			# delta: <computed later>
			_time: pitch_bend.time
			type: MIDIEvents.EVENT_MIDI
			subtype: MIDIEvents.EVENT_MIDI_PITCH_BEND
			channel: 0
			param1: 0
			param2: (pitch_bend.value + 1) * 64
#			param2: ((pitch_bend.value + 1) * 0x2000) / 128
#			param2: pitch_bend.value * 0x2000 / 128 + 64
#			param2: pitch_bend.value * 0x1000 / 64 + 64
		})

	for sustain_period in global_sustain_periods
		events.push({
			# delta: <computed later>
			_time: sustain_period.start_time
			type: MIDIEvents.EVENT_MIDI
			subtype: MIDIEvents.EVENT_MIDI_CONTROLLER
			channel: 0
			param1: 64
			param2: 127
		})
		events.push({
			# delta: <computed later>
			_time: sustain_period.end_time ? performance.now()
			type: MIDIEvents.EVENT_MIDI
			subtype: MIDIEvents.EVENT_MIDI_CONTROLLER
			channel: 0
			param1: 64
			param2: 0
		})

	events.sort((a, b)-> a._time - b._time)
	total_track_time = events[events.length - 1]._time
	last_time = null
	BPM = 120 # beats per minute
	PPQ = 192 # pulses per quarter note
	ms_per_tick = 60000 / (BPM * PPQ)
#	console.log({total_track_time, ms_per_tick})
	for event in events
		unless event.delta?
			if last_time?
				event.delta = (event._time - last_time) / ms_per_tick
			else
				event.delta = 0
			last_time = event._time
		delete event._time

	events.push({
		delta: 0
		type: MIDIEvents.EVENT_META
		subtype: MIDIEvents.EVENT_META_END_OF_TRACK
		length: 0
	})

	first_track_events = [
		{
			delta: 0
			type: MIDIEvents.EVENT_META
			subtype: MIDIEvents.EVENT_META_TIME_SIGNATURE
			length: 4
			data: [4, 2, 24, 8]
			param1: 4
			param2: 2
			param3: 24
			param4: 8
		}
		{
			delta: 0
			type: MIDIEvents.EVENT_META
			subtype: MIDIEvents.EVENT_META_SET_TEMPO
			length: 3
			tempo: 500000
			tempoBPM: 120 # not used
		}
#		{
#			delta: 0
#			type: MIDIEvents.EVENT_META
#			subtype: MIDIEvents.EVENT_META_TRACK_NAME
#			length: 0 # TODO: name "Tempo track" / "Meta track" / "Conductor track"
#		}
		{
			delta: ~~total_track_time
			type: MIDIEvents.EVENT_META
			subtype: MIDIEvents.EVENT_META_END_OF_TRACK
			length: 0
		}
	]
	midi_file.setTrackEvents(0, first_track_events)
	midi_file.addTrack(1)
	midi_file.setTrackEvents(1, events)

	output_array_buffer = midi_file.getContent()

	stringFirstTrackEvents = JSON.stringify(first_track_events);
	stringEvents = JSON.stringify(events);
	
	userdata = new FormData(usersurvey);
	console.log(userdata)

	$.post '/savemidi',
		type: 'POST'
		dataType: 'json'
		sessionuuid: sessionuuid
		firsttrackevents: stringFirstTrackEvents
		events: stringEvents
		(data) -> $('#no-notes-recorded-message').append "Successfully posted to the page."