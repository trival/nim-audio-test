import WebRenderer from "@elemaudio/web-renderer"
import { render } from "./sound"

const ctx = new AudioContext()
const core = new WebRenderer()

let playing = false

const btn = document.createElement("button")
btn.textContent = "Start"
btn.addEventListener("click", play)

function play() {
	playing = !playing
	ctx.resume()
	btn.textContent = playing ? "Stop" : "Start"
	setInterval(() => {
		if (playing) {
			core.render(...render(ctx.currentTime))
		} else {
			core.render(0, 0)
		}
	}, 1000 / 30)
}

document.querySelector<HTMLDivElement>("#app")!.appendChild(btn)

async function start() {
	let node = await core.initialize(ctx, {
		numberOfInputs: 0,
		numberOfOutputs: 1,
		outputChannelCount: [2],
	})

	node.connect(ctx.destination)
}

start()
