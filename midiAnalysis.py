from mido import MidiFile

mid = MidiFile('midifiles/midiFile.midi')

data = []

for i, track in enumerate(mid.tracks):
    for msg in track:
        if not msg.is_meta: # Remove meta messages
            data.append(msg)

def get_note_on(data):
    notes_on = []
    for i in data:
        if i.type == 'note_on':
            # print(i)
            notes_on.append(i)
    return notes_on
#####
def get_length(data):
    # Check if there is the right number of notes
    # If the scale does not have 8 notes, ignore it
    if len(data) == 16:
        print('The scale has the right amount of note (8)')
    else:
        print('The scale has {}, expecting 8'.format(len(data)))

def is_right_notes(data):
    # Check if the right notes are played in the scale
    # TODO modulo for octave equivalence
    right_notes = [48,50,52,53,55,57,59,60]
    notes = []
    for i in data:
        notes.append(i.note)
    if notes == right_notes:
        print('The scale contains the right notes')
    else:
        print('This scale is not a one octave C major scale')
    return
#####
def get_velo(data):
    # Get velocity of note_on
    velo = []
    for i in data:
        velo.append(i.velocity)
    #print(velo)
    return velo

def velo_stats(velocities):
    # Get stats on the notes velocity in the scale
    minVelo = min(velocities)
    maxVelo = max(velocities)
    rangeVelo = maxVelo - minVelo
    meanVelo = sum(velocities) / len(velocities)
    varianceVelo = sum([((x - meanVelo) ** 2) for x in velocities]) / len(velocities)
    resVelo = varianceVelo ** 0.5
    print('\nThis scale has a minimum note velocity of {}, a maximum of {}, with a range of {}'.format(minVelo, maxVelo, rangeVelo))
    print('The mean velocity is {:.2f} with a standard deviation of {:.2f}'.format(meanVelo, resVelo))
    return
#####
def get_duration(data):
    # Get the duration of each notes by getting the time info of note_off
    dur = []
    for i in data:
        if i.type == 'note_off':
            dur.append(i.time)
    #print(dur)
    return dur

def dur_stats(durations):
    # Get stats on the notes duration in the scale
    minDur = min(durations)
    maxDur = max(durations)
    rangeDur = maxDur - minDur
    meanDur = sum(durations) / len(durations)
    varianceDur = sum([((x - meanDur) ** 2) for x in durations]) / len(durations)
    resDur = varianceDur ** 0.5
    print('\nThis scale has a minimum note duration of {}, a maximum of {}, with a range of {}'.format(minDur, maxDur, rangeDur))
    print('The mean duration is {:.2f} with a standard deviation of {:.2f}'.format(meanDur, resDur))
    return
#####
def get_notes_pos(data):
    # Get each note absolute pos by adding delta times of events
    all_pos = [i.time for i in data]
    pos = []
    for i in range(0, len(all_pos),2):
        start = sum(all_pos[0:i+1])
        pos.append(start)
    # print(pos)
    return pos

def pos_stats(positions):
    # Get stats on the notes attack distances in the scale
    # Get distances from note positions
    inter = []
    for i in range(1, len(positions)):
        diff = positions[i] - positions[i-1]
        inter.append(diff)

    minDiff = min(inter)
    maxDiff = max(inter)
    rangeDiff = maxDiff - minDiff
    meanDiff = sum(inter) / len(inter)
    varianceDiff = sum([((x - meanDiff) ** 2) for x in inter]) / len(inter)
    resDiff = varianceDiff ** 0.5
    print('\nThis scale has a minimum inter-note difference of {}, a maximum of {}, with a range of {}'.format(minDiff, maxDiff, rangeDiff))
    print('The mean inter-note difference is {:.2f} with a standard deviation of {:.2f}'.format(meanDiff, resDiff))
    return
#####
def analyse_midi_file(data):
    notes_on = get_note_on(data)

    get_length(data)
    is_right_notes(notes_on)

    dur_stats(get_duration(data))
    velo_stats(get_velo(notes_on))
    pos_stats(get_notes_pos(data))

analyse_midi_file(data)
