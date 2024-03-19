import elemaudio 
import math

type 
  MelodyNote*[T] = tuple
    duration: float = 0.0
    data: T 

  Melody*[T] = seq[MelodyNote[T]]

  SeqNote*[T] = object
    start: float = 0.0
    duration: float = 0.0
    data: T

  Sequence*[T] = object
    notes: seq[SeqNote[T]]
    duration: float = 0.0

func toSequence*[T](melody: Melody[T], null: T) : Sequence[T] =
  for note in melody:
    if note.data != null:
      let n = SeqNote[T](
        start: result.duration,
        duration: note.duration,
        data: note.data
      )
      result.notes.add(n)
    result.duration += note.duration

func `&`*[T](s1: Sequence[T], s2: Sequence[T]): Sequence[T] =
  result.duration = s1.duration + s2.duration
  result.notes = s1.notes & s2.notes

# Sequencer

type
  PlayableNote*[T] = object
    data*: T
    idx*: int
    gate*: elemaudio.AudioNode

  Period = tuple 
    start: float
    finish: float

  Sequencer[T] = object
    sequence: Sequence[T]
    initData: T

    trackCount: int
    bpm: float
    repetitions: int
    startTime: float
    seqKey: string
    debug: bool

    secPerBeat: float 
    seqDuration: float
    noteIntervals: seq[Period]
    tracks: seq[PlayableNote[T]]
    playingNotes: seq[bool]

    currentTrackIdx = 0

func createSequencer*[T](
  s: Sequence[T],
  initData: T,
  trackCount: int = 2,
  bpm: float = 120.0,
  repetitions: int = 0,
  startTime: float = 0.0,
  seqKey: string = "seq_trigger",
  debug: bool = false
): Sequencer[T] =
  result.sequence = s
  result.initData = initData
  result.trackCount = trackCount
  result.bpm = bpm
  result.repetitions = repetitions
  result.startTime = startTime
  result.seqKey = seqKey
  result.debug = debug

  let secPerBeat = 60.0 / bpm
  result.secPerBeat = secPerBeat

  let seqDuration = s.duration * secPerBeat
  result.seqDuration = seqDuration

  var noteIntervals: seq[Period] = @[]

  for i, note in s.notes:
    let start = note.start * secPerBeat - seqDuration
    let finish = start + note.duration * secPerBeat
    if finish > 0.0: 
      noteIntervals.add((start, finish))

  var playingNotes: seq[bool] = @[]

  for i, note in s.notes:
    let start = note.start * secPerBeat 
    let finish = start + note.duration * secPerBeat
    noteIntervals.add((start, finish))
    playingNotes.add(false)

  result.noteIntervals = noteIntervals
  result.playingNotes = playingNotes

  var tracks: seq[PlayableNote[T]] = @[]

  for i in 0..<trackCount:
    tracks.add(PlayableNote[T](
      data: initData,
      idx: i,
      gate: timedTrigger(0, 0, seqKey & $i)
    ))

  result.tracks = tracks

func getNextTrackIdx*[T](s: var Sequencer[T]): int =
  result = s.currentTrackIdx
  s.currentTrackIdx = (s.currentTrackIdx + 1) mod s.trackCount

proc currentNotes*[T](s: var Sequencer[T], currentTime: float): seq[PlayableNote[T]] =
  let currentLoop = floor((currentTime - s.startTime) / s.seqDuration)

  if s.repetitions == 0 or currentLoop.toInt < s.repetitions:
    let seqTime = currentTime - currentLoop * s.seqDuration

    for i, n in s.noteIntervals:
      if n.start - 0.1 <= seqTime and n.finish > seqTime:
        if not s.playingNotes[i]:
          let note = s.sequence.notes[i]
          let start = n.start + currentLoop * s.seqDuration
          let nextTrackIdx = s.getNextTrackIdx
          s.tracks[nextTrackIdx].data = note.data
          s.tracks[nextTrackIdx].gate = elemaudio.timedTrigger(
            start,
            note.duration * s.secPerBeat,
            s.seqKey & $nextTrackIdx
          )
          s.playingNotes[i] = true
      else: 
        if s.playingNotes[i]:
          s.playingNotes[i] = false
      

    if s.debug:
      var playing: seq[int] = @[]
      for i, v in s.playingNotes:
        if v: playing.add(i)
      echo s.seqKey, " ", s.currentTrackIdx, " ", playing

  s.tracks