FROM debian:bullseye

ARG version=error
ARG source_release=error

# we use this wasi version
ENV wasi_fullversion 14.0
ENV wasi_mainversion 14

# dependencies needed to run ./mach bootstrap
RUN apt-get -y update && apt-get -y upgrade && apt-get -y install mercurial python3 python3-dev python3-pip wget build-essential libpython3-dev m4 unzip uuid zip libasound2-dev libcurl4-openssl-dev libdbus-1-dev libdbus-glib-1-dev libdrm-dev libgtk-3-dev libpulse-dev libx11-xcb-dev libxt-dev xvfb rsync

# setup wasi
RUN export target_wasi_location=$HOME/.mozbuild/wrlb/ &&\
    wget -q https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-$wasi_mainversion/wasi-sdk-$wasi_fullversion-linux.tar.gz &&\
    tar xf wasi-sdk-$wasi_fullversion-linux.tar.gz &&\
    mkdir -p $target_wasi_location &&\
    rm -rf $target_wasi_location/wasi-sysroot &&\
    cp -r wasi-sdk-$wasi_fullversion/share/wasi-sysroot $target_wasi_location &&\
    rm -f wasi-sdk-*.tar.gz* && rm -rf wasi-sdk-*

# setup windows tools
RUN true

# run the bootstrap
RUN wget -q -O librewolf-$version-$source_release.source.tar.gz https://gitlab.com/librewolf-community/browser/source/-/jobs/artifacts/main/raw/librewolf-$version-$source_release.source.tar.gz?job=Build
RUN tar xf librewolf-$version-$source_release.source.tar.gz
WORKDIR librewolf-$version-$source_release
RUN echo "ac_add_options --target=x86_64-pc-mingw32" > mozconfig
RUN echo "ac_add_options --enable-bootstrap" > mozconfig
RUN echo "" > mozconfig
RUN MOZBUILD_STATE_PATH=$HOME/.mozbuild ./mach --no-interactive bootstrap --application-choice=browser
RUN /root/.cargo/bin/cargo install cbindgen
RUN /root/.cargo/bin/rustup target add x86_64-pc-mingw32

# not sure about this one..
RUN pip install testresources pycairo

# our work happens here, on the host filesystem.
WORKDIR /work
VOLUME ["/work"]
