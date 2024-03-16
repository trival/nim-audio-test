import WebRenderer from "@elemaudio/web-renderer"
import { channels } from "./sound"

const ctx = new AudioContext()
const core = new WebRenderer()

function play() {
  ctx.resume()
  core.render(...channels)
}

const btn = document.createElement("button")
btn.textContent = "Start"
btn.addEventListener("click", play)

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
