# import { ElemNode } from '@elemaudio/core'
# import { timedTrigger } from './elemaudio'
# import { rotate } from './base'

# export interface MelodyNote<T> {
# 	duration: number
# 	data: T | null
# }

# export type Melody<T> = MelodyNote<T>[]

# export interface SeqNote<T> {
# 	start: number
# 	duration: number
# 	data: T
# }

# export interface Sequence<T> {
# 	notes: SeqNote<T>[]
# 	duration: number
# }

# export function melodyNote<T>(duration: number, data: T | null = null) {
# 	return {
# 		duration,
# 		data,
# 	}
# }

# export function melodyToSeq<T>(melody: Melody<T>): Sequence<T> {
# 	const notes: SeqNote<T>[] = []
# 	let duration = 0

# 	melody.forEach((note) => {
# 		if (note.data != null) {
# 			notes.push({
# 				start: duration,
# 				duration: note.duration,
# 				data: note.data,
# 			})
# 		}
# 		duration += note.duration
# 	})

# 	return {
# 		notes,
# 		duration,
# 	}
# }

# export function combine<T>(...seqs: Sequence<T>[]): Sequence<T> {
# 	const notes: SeqNote<T>[] = []
# 	let duration = 0

# 	seqs.forEach((seq) => {
# 		seq.notes.forEach((note) => {
# 			notes.push({
# 				start: duration + note.start,
# 				duration: note.duration,
# 				data: note.data,
# 			})
# 		})
# 		duration += seq.duration
# 	})

# 	return {
# 		notes,
# 		duration,
# 	}
# }

# export interface PlayableNote<T> {
# 	data: T
# 	idx: number
# 	triggerSignal: ElemNode
# }

# interface SequenceProps<T> {
# 	initData: T
# 	trackCount: number
# 	bpm: number
# 	repetitions: number
# 	startTime: number
# 	seqTriggerKey: string
# 	debug?: boolean
# }

# const defaultSequenceProps: Omit<SequenceProps<any>, 'initData'> = {
# 	bpm: 120,
# 	repetitions: 0,
# 	startTime: 0,
# 	seqTriggerKey: 'trigger',
# 	trackCount: 2,
# }

# export function createSequencer<T>(
# 	seq: Sequence<T>,
# 	props: Partial<SequenceProps<T>> & { initData: T },
# ): (currentTime: number) => PlayableNote<T>[] {
# 	const {
# 		bpm,
# 		repetitions,
# 		startTime,
# 		seqTriggerKey,
# 		trackCount,
# 		initData,
# 		debug,
# 	} = {
# 		...defaultSequenceProps,
# 		...props,
# 	}
# 	const secPerBeat = 60 / bpm

# 	let noteIntervals: { start: number; end: number; idx: number }[] = []
# 	seq.notes.forEach((note, i) => {
# 		const start = note.start * secPerBeat
# 		if (note.data != null) {
# 			noteIntervals.push({
# 				start: start,
# 				end: start + note.duration * secPerBeat,
# 				idx: i,
# 			})
# 		}
# 	})

# 	const seqDuration = seq.duration * secPerBeat

# 	noteIntervals = noteIntervals
# 		.map((n) => ({
# 			...n,
# 			start: n.start - seqDuration,
# 			end: n.end - seqDuration,
# 		}))
# 		.concat(noteIntervals)
# 		.filter((n) => n.end > 0)

# 	const tracks: PlayableNote<T>[] = Array.from(
# 		{ length: trackCount },
# 		(_, i) => ({
# 			idx: i,
# 			data: initData,
# 			triggerSignal: timedTrigger(0, 0, seqTriggerKey + i),
# 		}),
# 	)

# 	let currentTrackIdx = 0

# 	const getNextTrackIdx = () => {
# 		const idx = currentTrackIdx
# 		currentTrackIdx = (currentTrackIdx + 1) % trackCount
# 		return idx
# 	}

# 	const playingNotes: { [idx: number]: boolean } = {}

# 	return (currentTime: number) => {
# 		const currentLoop = Math.floor((currentTime - startTime) / seqDuration)

# 		if (repetitions === 0 || currentLoop < repetitions) {
# 			const seqTime = currentTime - currentLoop * seqDuration

# 			noteIntervals.forEach((n) => {
# 				if (n.start - 0.1 <= seqTime && n.end > seqTime) {
# 					if (!playingNotes[n.idx]) {
# 						const note = seq.notes[n.idx]
# 						const start = n.start + currentLoop * seqDuration
# 						const nextTrackIdx = getNextTrackIdx()
# 						tracks[nextTrackIdx].data = note.data!
# 						tracks[nextTrackIdx].triggerSignal = timedTrigger(
# 							start,
# 							start + note.duration * secPerBeat,
# 							seqTriggerKey + nextTrackIdx,
# 						)
# 						playingNotes[n.idx] = true
# 						console.log('adding seq note', seqTriggerKey, n.idx, nextTrackIdx)
# 					}
# 				} else {
# 					playingNotes[n.idx] = false
# 				}
# 			})

# 			debug &&
# 				console.log(
# 					seqTriggerKey,
# 					Object.entries(playingNotes)
# 						.filter(([_, v]) => v)
# 						.map(([k]) => k),
# 				)
# 		}

# 		return tracks
# 	}
# }

type MelodyNote[T] = object
  duration: float
  data: T 
