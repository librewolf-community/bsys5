# $(arch)

FROM debian:bullseye

ARG arch=error

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

# setup osx sdk
RUN mkdir -p /osx-cross/MacOSX-SDKs &&\
    cd /osx-cross/MacOSX-SDKs &&\
    wget -q "https://github.com/phracker/MacOSX-SDKs/releases/download/11.3/MacOSX11.3.sdk.tar.xz" &&\
    tar xf MacOSX11.3.sdk.tar.xz &&\
    rm -f MacOSX11.3.sdk.tar.xz

# run the bootstrap
RUN wget -q -O librewolf-$version-$source_release.source.tar.gz https://gitlab.com/librewolf-community/browser/source/-/jobs/artifacts/main/raw/librewolf-$version-$source_release.source.tar.gz?job=Build &&\
    tar xf librewolf-$version-$source_release.source.tar.gz &&\
    cd librewolf-$version-$source_release &&\
    echo ac_add_options --target=$arch-apple-darwin > mozconfig &&\
    echo ac_add_options --enable-bootstrap >> mozconfig &&\
    echo ac_add_options --with-macos-sdk=/osx-cross/MacOSX-SDKs/MacOSX11.3.sdk >> mozconfig &&\
    MOZBUILD_STATE_PATH=$HOME/.mozbuild ./mach --no-interactive bootstrap --application-choice=browser &&\
    ./mach artifact toolchain --from-build linux64-libdmg &&\
    ./mach artifact toolchain --from-build linux64-cctools-port &&\
    ./mach artifact toolchain --from-build linux64-hfsplus &&\
    ./mach artifact toolchain --from-build linux64-binutils &&\
    ./mach artifact toolchain --from-build linux64-clang-macosx-cross &&\
    /root/.cargo/bin/cargo install cbindgen &&\
    /root/.cargo/bin/rustup target add $arch-apple-darwin  &&\
    cp -r binutils /root/.mozbuild &&\
    cp -r cctools /root/.mozbuild &&\
    cp -r clang /root/.mozbuild &&\
    cp -r dmg /root/.mozbuild &&\
    cp -r hfsplus-tools /root/.mozbuild &&\
    pip install testresources pycairo &&\
    cd .. &&\
    rm -rf librewolf-$version-$source_release librewolf-$version-$source_release.source.tar.gz

# our work happens here, on the host filesystem.
WORKDIR /work
VOLUME ["/work"]
