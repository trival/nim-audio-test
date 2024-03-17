# export const midiToFc = (midi: number) => {
# 	return 2 ** ((midi - 69) / 12) * 440
# }

# export type NoteName =
# 	| 'C'
# 	| 'C#'
# 	| 'Db'
# 	| 'D'
# 	| 'D#'
# 	| 'Eb'
# 	| 'E'
# 	| 'F'
# 	| 'F#'
# 	| 'Gb'
# 	| 'G'
# 	| 'G#'
# 	| 'Ab'
# 	| 'A'
# 	| 'A#'
# 	| 'Bb'
# 	| 'B'

# export type NoteValue = `${NoteName}-${number}`

# export type Note = {
# 	note: NoteName
# 	octave: number
# }

# function noteFromValue(value: NoteValue): Note {
# 	const [note, octave] = value.split('-')
# 	return {
# 		note: note as NoteName,
# 		octave: parseInt(octave),
# 	}
# }

# export const noteToMidi = (note: Note | NoteValue) => {
# 	const n = typeof note === 'string' ? noteFromValue(note) : note
# 	const { note: name, octave } = n
# 	const sharps: NoteName[] = [
# 		'C',
# 		'C#',
# 		'D',
# 		'D#',
# 		'E',
# 		'F',
# 		'F#',
# 		'G',
# 		'G#',
# 		'A',
# 		'A#',
# 		'B',
# 	]
# 	const flats: NoteName[] = [
# 		'C',
# 		'Db',
# 		'D',
# 		'Eb',
# 		'E',
# 		'F',
# 		'Gb',
# 		'G',
# 		'Ab',
# 		'A',
# 		'Bb',
# 		'B',
# 	]
# 	let toneIndex = sharps.indexOf(name)
# 	if (toneIndex === -1) {
# 		toneIndex = flats.indexOf(name)
# 	}
# 	return (octave + 1) * 12 + toneIndex
# }

# export type ChordName = 'maj' | 'min' | 'maj7' | '7' | 'min7' | 'dim' | 'dim7'

# export function chord(baseNote: number | NoteValue, chordName: ChordName) {
# 	const base = typeof baseNote === 'number' ? baseNote : noteToMidi(baseNote)
# 	const chord = chordName.includes('min')
# 		? [0, 3, 7]
# 		: chordName.includes('dim')
# 			? [0, 3, 6]
# 			: [0, 4, 7]
# 	if (chordName === 'maj7') {
# 		chord.push(11)
# 	} else if (chordName.includes('7')) {
# 		chord.push(10)
# 	}

# 	return chord.map((n) => base + n)
# }

# function invertUp(chord: number[]) {
# 	const [first, ...rest] = chord
# 	return [...rest, first + 12]
# }

# function invertDown(chord: number[]) {
# 	const [last, ...rest] = [...chord].reverse()
# 	return [last - 12, ...rest.reverse()]
# }

# export function invert(chord: number[], times = 1) {
# 	if (times < 0) {
# 		times = Math.abs(times)
# 		for (let i = 0; i < times; i++) {
# 			chord = invertDown(chord)
# 		}
# 	} else {
# 		for (let i = 0; i < times; i++) {
# 			chord = invertUp(chord)
# 		}
# 	}
# 	return chord
# }

# export function harmonicMajorScale(baseFrequency: number) {
# 	return [
# 		baseFrequency / 1,

# 		(baseFrequency * 7) / 6,
# 		// (baseTone * 6) / 5, // no minor third
# 		(baseFrequency * 5) / 4,
# 		(baseFrequency * 4) / 3,
# 		(baseFrequency * 3) / 2,

# 		(((baseFrequency * 3) / 2) * 7) / 6,
# 		(((baseFrequency * 3) / 2) * 5) / 4,
# 	]
# }

# export enum ScaleType {
# 	MAJOR = 'major',
# 	MINOR = 'minor',
# 	HARMONIC_MINOR = 'harmonicMinor',
# }

# export function scaleIntervals(type: ScaleType) {
# 	switch (type) {
# 		case ScaleType.MAJOR:
# 			return [0, 2, 4, 5, 7, 9, 11]
# 		case ScaleType.MINOR:
# 			return [0, 2, 3, 5, 7, 8, 10]
# 		case ScaleType.HARMONIC_MINOR:
# 			return [0, 2, 3, 5, 7, 8, 11]
# 	}
# }

# export function scale(baseNote: NoteValue, type: ScaleType) {
# 	const intervals = scaleIntervals(type)
# 	const notes = intervals
# 		.map((i) => i + noteToMidi(baseNote))
# 		.concat(intervals.map((i) => i + noteToMidi(baseNote) + 12))
# 		.concat(intervals.map((i) => i + noteToMidi(baseNote) + 24))

# 	return function (value: number, prefix?: '#' | 'b') {
# 		const note = notes[value - 1]
# 		if (prefix === '#') {
# 			return note + 1
# 		} else if (prefix === 'b') {
# 			return note - 1
# 		}
# 		return note
# 	}
# }

# export function octaveTransposedScale(
# 	s: ReturnType<typeof scale>,
# 	octaves = 1,
# ) {
# 	return function (value: number, prefix?: '#' | 'b') {
# 		return s(value, prefix) + 12 * octaves
# 	}
# }

import math

type 
  NoteName* = enum
    C, Cx, Db, D, Dx, Eb, E, F, Fx, Gb, G, Gx, Ab, A, Ax, Bb, B

  Note* = tuple[name: NoteName, octave: int]

  ChordName* = enum
    maj, min, maj7, d7, min7, dim, dim7

const minorChords = {min, min7}
const dimChords = {dim, dim7}
const min7Chords = {min7, dim7, d7}

func midiToFq* (midi: int): float = 
  pow(2, float(midi - 69) / 12.0) * 440.0

func noteToMidi* (note: Note): int = 
  let sharps = [C, Cx, D, Dx, E, F, Fx, G, Gx, A, Ax, B]
  let flats = [C, Db, D, Eb, E, F, Gb, G, Ab, A, Bb, B]
  var toneIndex = sharps.find(note.name)
  if toneIndex == -1:
    toneIndex = flats.find(note.name)
  result = (note.octave + 1) * 12 + toneIndex

func chord* (baseNoteMidi: int, chordName: ChordName): seq[int] =
  var chord = @[0, 4, 7]
  if chordName in minorChords:
    chord = @[0, 3, 7]
  elif chordName in dimChords:
    chord = @[0, 3, 6]

  if chordName == ChordName.maj7:
    chord.add(11)
  elif chordName in min7Chords:
    chord.add(10)

  for n in chord:
    result.add(baseNoteMidi + n)

func chord* (baseNote: Note, chordName: ChordName): seq[int] =
  chord(noteToMidi(baseNote), chordName)