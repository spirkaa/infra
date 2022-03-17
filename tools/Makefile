.POSIX:

TAG=infra-tools

default: build run

build:
	@DOCKER_BUILDKIT=1 docker build . --tag ${TAG}

run:
	@docker run \
		--rm \
		--interactive \
		--tty \
		--network host \
		--cap-add=CAP_IPC_LOCK \
		--env "TZ=Europe/Moscow" \
		--env "TERM=${TERM}" \
		--env "HOME=${HOME}" \
		--volume "${HOME}:${HOME}" \
		--volume "/etc/passwd:/etc/passwd" \
		--user "$(shell id -u ${USER}):$(shell id -g ${USER})" \
		--workdir "$(shell pwd)/.." \
		${TAG}
