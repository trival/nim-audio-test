{. emit: """import { el } from "@elemaudio/core" """ .}

type AudioNode = ref object 

func `$`* (val: float): AudioNode {.importjs: "el.const({value: #})" .}
func `$`* (val: float, key: cstring): AudioNode {. importjs: "el.const({value: #, key: #})" .}
func cycle* (fq: float): AudioNode {. importjs: "el.cycle(@)" .}
func cycle* (a: AudioNode): AudioNode {. importjs: "el.cycle(@)" .}
func `+`* (a: AudioNode, b: AudioNode ): AudioNode {. importjs: "el.add(@)" .}
func `/`* (a: AudioNode, b: AudioNode ): AudioNode {. importjs: "el.div(@)" .}
func `/`* (a: AudioNode, b: float ): AudioNode {. importjs: "el.div(@)" .}
