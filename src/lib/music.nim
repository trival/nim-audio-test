
import math

type 
  NoteName* = enum
    C, Cx, Db, D, Dx, Eb, E, F, Fx, Gb, G, Gx, Ab, A, Ax, Bb, B

  Note* = tuple[name: NoteName, octave: int]

func toMidi* (note: Note): int = 
  const sharps = [C, Cx, D, Dx, E, F, Fx, G, Gx, A, Ax, B]
  const flats = [C, Db, D, Eb, E, F, Gb, G, Ab, A, Bb, B]
  var toneIndex = sharps.find(note.name)
  if toneIndex == -1:
    toneIndex = flats.find(note.name)
  (note.octave + 1) * 12 + toneIndex

func toFrequency* (midi: int): float = 
  pow(2, float(midi - 69) / 12) * 440.0

func toFrequency* (note: Note): float = 
  note.toMidi.toFrequency

func harmonicMajorScale* (baseFrequency: float): seq[float] =
  @[
    baseFrequency / 1.0,
    (baseFrequency * 7) / 6,
    (baseFrequency * 5) / 4,
    (baseFrequency * 4) / 3,
    (baseFrequency * 3) / 2,

    ((baseFrequency * 3) / 2 * 7) / 6,
    ((baseFrequency * 3) / 2 * 5) / 4
  ]

# midi chords

type 
  Chord* = enum
    maj, min, dim, maj7, d7, min7, dim7, aug, dimFull

func midiOffsets* (name: Chord): seq[int] =
  case name
    of maj: @[0, 4, 7]
    of min: @[0, 3, 7]
    of dim: @[0, 3, 6]
    of aug: @[0, 4, 8]
    of maj7: @[0, 4, 7, 11]
    of d7: @[0, 4, 7, 10]
    of min7: @[0, 3, 7, 10]
    of dim7: @[0, 3, 6, 10]
    of dimFull: @[0, 3, 6, 9]

func chord* (baseNoteMidi: int, chordName: Chord): seq[int] =
  for n in chordName.midiOffsets:
    result.add(baseNoteMidi + n)

func chord* (baseNote: Note, chordName: Chord): seq[int] =
  chord(baseNote.toMidi, chordName)

func invertUp* (chord: seq[int]): seq[int] =
  chord[1..^1] & @[chord[0] + 12]

func invertDown* (chord: seq[int]): seq[int] =
  @[chord[-1] - 12] & chord[0..^1]

func invert* (chord: seq[int], times = 1): seq[int] =
  result = chord
  if times < 0:
    for i in 1..abs(times):
      result = result.invertDown
  else:
    for i in 1..times:
      result = result.invertUp

func reverse* (chord: seq[int]): seq[int] =
  var i = chord.high
  while i >= chord.low:
    result.add(chord[i])
    i.dec

# midi scales

type
  Scale* = enum
    major, minor, harmonicMinor, majorPentatonic, minorPentatonic, blues

func midiOffsets* (scale: Scale): seq[int] =
  case scale
    of major: @[0, 2, 4, 5, 7, 9, 11]
    of minor: @[0, 2, 3, 5, 7, 8, 10]
    of harmonicMinor: @[0, 2, 3, 5, 7, 8, 11]
    of majorPentatonic: @[0, 2, 4, 7, 9]
    of minorPentatonic: @[0, 3, 5, 7, 10]
    of blues: @[0, 3, 5, 6, 7, 10]

func scale* (baseNoteMidi: int, scale: Scale): seq[int] =
  let offsets = scale.midiOffsets
  for j in 0..<3:
    for i in offsets:
      result.add(i + baseNoteMidi + (j * 12))

func scale* (baseNote: Note, scaleType: Scale): seq[int] =
  baseNote.toMidi.scale(scaleType)

func sharp* (note: int): int = 
  note + 1

func flat* (note: int): int =
  note - 1
