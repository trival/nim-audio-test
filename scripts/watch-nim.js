import { watch } from "fs/promises"
import { $ } from "bun"
import * as childProcess from "child_process"

const watcher = watch(process.cwd(), { recursive: true })

for await (const event of watcher) {
	if (event.filename?.endsWith(".nim")) {
		console.log("Recompiling nim...")
		// recompile the Nim code
		childProcess.execSync("nim js -d:release src/sound.nim")
	}
}
