ARG distro
FROM $distro

ARG version=error
ARG source_release=error

# we use this wasi version
ENV wasi_fullversion 14.0
ENV wasi_mainversion 14

# these ones seem to be needed by ubuntu
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Amsterdam


# dependencies needed to run ./mach bootstrap
RUN ( apt-get -y update && apt-get -y upgrade && apt-get -y install python3 python3-dev python3-pip wget dpkg-sig ; true)
RUN ( dnf -y upgrade && dnf -y install python3 python3-devel wget rpm-build rpm-sign ; true)
RUN ( zypper -n in mercurial python3 python3-pip python3-devel wget rpm-build lld ; true)

# setup wasi
RUN export target_wasi_location=$HOME/.mozbuild/wrlb/ &&\
    wget -q https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-$wasi_mainversion/wasi-sdk-$wasi_fullversion-linux.tar.gz &&\
    tar xf wasi-sdk-$wasi_fullversion-linux.tar.gz &&\
    mkdir -p $target_wasi_location &&\
    rm -rf $target_wasi_location/wasi-sysroot &&\
    cp -r wasi-sdk-$wasi_fullversion/share/wasi-sysroot $target_wasi_location &&\
    rm -f wasi-sdk-*.tar.gz* && rm -rf wasi-sdk-*

# run the bootstrap
RUN wget -q -O librewolf-$version-$source_release.source.tar.gz https://gitlab.com/librewolf-community/browser/source/-/jobs/2753010907/artifacts/raw/librewolf-102.0.1-1.source.tar.gz &&\
    tar xf librewolf-$version-$source_release.source.tar.gz &&\
    cd librewolf-$version-$source_release &&\
    MOZBUILD_STATE_PATH=$HOME/.mozbuild ./mach --no-interactive bootstrap --application-choice=browser &&\
    /root/.cargo/bin/cargo install cbindgen &&\
    cd .. &&\
    rm -rf librewolf-$version-$source_release librewolf-$version-$source_release.source.tar.gz

# our work happens here, on the host filesystem.
WORKDIR /work
VOLUME ["/work"]
