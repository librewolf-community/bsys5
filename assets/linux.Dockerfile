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
RUN ( zypper -n in mercurial python3 python3-pip python3-devel wget rpm-build ; true)

# run the bootstrap
RUN cd /tmp &&\
    wget -q -O librewolf-$version-$source_release.source.tar.gz https://gitlab.com/librewolf-community/browser/source/-/jobs/artifacts/main/raw/librewolf-$version-$source_release.source.tar.gz?job=Build &&\
    tar xf librewolf-$version-$source_release.source.tar.gz &&\
    cd librewolf-$version-$source_release &&\
    MOZBUILD_STATE_PATH=$HOME/.mozbuild ./mach --no-interactive bootstrap --application-choice=browser &&\
    (cd /root/.mozbuild && /tmp/librewolf-$version-$source_release/mach artifact toolchain --from-build sysroot-wasm32-wasi) &&\
    /root/.cargo/bin/cargo install cbindgen &&\
    cd .. &&\
    rm -rf librewolf-$version-$source_release librewolf-$version-$source_release.source.tar.gz

# our work happens here, on the host filesystem.
WORKDIR /work
VOLUME ["/work"]
