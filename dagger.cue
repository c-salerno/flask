package flask

import (
	"dagger.io/dagger"

	"dagger.io/dagger/core"
	"universe.dagger.io/python"
)

dagger.#Plan & {
	actions: {
		// Load the source code 
		source: core.#Source & {
			path: "src"
		}

		// Test
		test: python.#Run & {
			script: contents: "tox"
			args: ["-e", "py310"]
		}
	}
}