import lib/elemaudio
import lib/music
import lib/sequencer

const null = 0.0

var melody: Melody[float] = @[]

proc note (midi: int, duration: float): void = 
  melody.add((duration, midi.toFrequency))

proc brk (duration: float): void = 
  melody.add((duration, null))

# setup melody 

for midi in (C, 4).chord(d7):
  note(midi, 0.5)

1.0.brk

for midi in (F, 3).chord(maj7).revert:
  note(midi, 0.5)

1.0.brk

# setup sequencer

var s = createSequencer(melody.toSequence(null), null,
  bpm = 80.0, debug = true)

proc render(time: float): array[2, AudioNode] = 
  let notes = s.currentNotes(time)

  let n1 = notes[0]
  let n2 = notes[1]

  # let phaseLFO = (cycle(0.5).fit1101 + 0.1) * 3.0 
  # let c = triangle((C, 4).toFrequency) * (phasor(phaseLFO) > 0.5) 

  echo n1
  echo n2

  let c = triangle(n1.data@"1") * n1.triggerSignal +
    triangle(n2.data@"2") * n2.triggerSignal

  [c, c]

{. emit: "export {`render` as render}" .}

