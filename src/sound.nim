import lib/elemaudio

let c = (cycle(440) + cycle(441)) / 2$"divisor"

let channels = [c, c]

{. emit: "export {`channels` as channels}" .}

