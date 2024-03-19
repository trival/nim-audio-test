import lib/elemaudio
import lib/music
import lib/sequencer

const null = 0.0

proc n (midi: int, duration: float): MelodyNote[float] = 
  (duration, midi.toFrequency)

proc b (duration: float): MelodyNote[float] = 
 (duration, null)

proc m (): Melody[float] = 
  for midi in (C, 4).chord(d7):
    result.add(n(midi, 0.5))

  result.add(b(1.0))

  for midi in (F, 3).chord(maj7).revert:
    result.add(n(midi, 0.5))

  result.add(b(1.0))

var s = createSequencer(m().toSequence(null), null, bpm = 80.0)

proc play(time: float): array[2, AudioNode] = 
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

{. emit: "export {`play` as synth}" .}

