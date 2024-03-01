# thanks to https://klotzandrew.com/blog/brotli-compresssion-cgo-in-docker

FROM golang:1.22.0 as builder
COPY main.go /build/main.go
COPY go.mod /build/go.mod
COPY go.sum /build/go.sum
RUN \
	apt update --yes && \
	apt install --yes \
		apt-transport-https \
		autoconf \
		automake \
		bc \
		build-essential \
		cmake \
		gcc \
		git \
		libtool \
		make && \
	mkdir /brotli && \
	cd /brotli && \
		git init && \
		git remote add origin https://github.com/google/brotli.git && \
		git fetch --depth 1 origin ccec9628e49208173c9a8829ff66d0d7f6ceff5f && \
		git checkout FETCH_HEAD && \
		mkdir ./out && \
		cd ./out && \
			cmake \
				-DCMAKE_BUILD_TYPE=Release \
				-DCMAKE_INSTALL_PREFIX=./installed .. && \
			cmake \
				--build . \
				--config Release \
				--target install && \
			cp -r ./installed/* /usr/local/ && \
	cd /build && \
		go mod tidy && \
		CGO_ENABLED=1 \
			LD_LIBRARY_PATH=/usr/local/lib \
			GOOS=linux \
			go build -o main .

FROM alpine:3.19.1
WORKDIR /srv
COPY --from=builder /usr/local/lib /usr/local/lib
COPY --from=builder /build/main .
COPY nav.html nav.html
RUN \
	apk add --no-cache --update \
		ca-certificates \
		libc6-compat && \
	./main
