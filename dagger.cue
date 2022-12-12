package flask

import (
	"dagger.io/dagger"

	"universe.dagger.io/docker"
)

#PythonBuild: {
	app: dagger.#FS

	image: _build.output

	_build: docker.#Build & {
		steps: [
			docker.#Pull & {
				source: "python:3.10"
			},
			docker.#Copy & {
				contents: app
				dest: "/app"
			},
			docker.#Run & {
				command: {
					name: "pip",
					args: ["install", "tox"]
				}
			}
		]
	}
}

dagger.#Plan & {
    client: filesystem: ".": read: contents: dagger.#FS

    actions: {
        build: #PythonBuild & {
            app: client.filesystem.".".read.contents
        }

		#Run: docker.#Run & {
            input: build.image
            mounts: "app": {
                contents: client.filesystem.".".read.contents
                dest: "/app"
            }
            workdir: "/app"
        }

		test: #Run & {
			command: {
				name: "tox"
				args: ["-e", "py310"]
			}
		}
	}
}