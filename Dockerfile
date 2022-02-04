ARG distro
FROM $distro

# dependencies needed to run ./mach bootstrap
RUN ( apt-get -y update && apt-get -y upgrade && apt-get -y install mercurial python3 python3-dev python3-pip wget ; true)
RUN ( dnf -y upgrade && dnf -y install mercurial python3 python3-devel wget ; true)

# run ./mach bootstrap
RUN mkdir /bootstrap
WORKDIR /bootstrap
# setup wasi
RUN ( export target_wasi_location=$HOME/.mozbuild/wrlb/ && wget -q https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-14/wasi-sdk-14.0-linux.tar.gz && tar xf wasi-sdk-14.0-linux.tar.gz && mkdir -p $target_wasi_location && rm -rf $target_wasi_location/wasi-sysroot && cp -vr wasi-sdk-14.0/share/wasi-sysroot $target_wasi_location && rm -f wasi-sdk-*.tar.gz* && rm -rf wasi-sdk-* )
# run the bootstrap
RUN wget -q -O librewolf-96.0.3-3.source.tar.gz "https://gitlab.com/librewolf-community/browser/source/-/jobs/artifacts/main/raw/librewolf-96.0.3-3.source.tar.gz?job=Build"
RUN tar xf librewolf-96.0.3-3.source.tar.gz
WORKDIR librewolf-96.0.3
RUN (MOZBUILD_STATE_PATH=$HOME/.mozbuild ./mach --no-interactive bootstrap --application-choice=browser && . /root/.cargo/env && cargo install cbindgen)

# our work happens here, on the host filesystem.
WORKDIR /work
VOLUME ["/work"]
