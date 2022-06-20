FROM debian:bullseye

ARG version=error
ARG source_release=error

# we use this wasi version
ENV wasi_fullversion 14.0
ENV wasi_mainversion 14

# these ones seem to be needed by ubuntu
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Amsterdam


# dependencies needed to run ./mach bootstrap
RUN ( apt-get -y update && apt-get -y upgrade && apt-get -y install mercurial python3 python3-dev python3-pip curl wget dpkg-sig)


# setup wasi
RUN export target_wasi_location=$HOME/.mozbuild/wrlb/ &&\
    wget -q https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-$wasi_mainversion/wasi-sdk-$wasi_fullversion-linux.tar.gz &&\
    tar xf wasi-sdk-$wasi_fullversion-linux.tar.gz &&\
    mkdir -p $target_wasi_location &&\
    rm -rf $target_wasi_location/wasi-sysroot &&\
    cp -r wasi-sdk-$wasi_fullversion/share/wasi-sysroot $target_wasi_location &&\
    rm -f wasi-sdk-*.tar.gz* && rm -rf wasi-sdk-*

# install-packages
RUN apt -y install msitools p7zip-full nsis upx-ucl wine wine64-tools libssl-dev zstd

# prepare
RUN wget -q -O librewolf-$version-$source_release.source.tar.gz https://gitlab.com/librewolf-community/browser/source/-/jobs/artifacts/main/raw/librewolf-$version-$source_release.source.tar.gz?job=Build
RUN tar xf librewolf-$version-$source_release.source.tar.gz
WORKDIR librewolf-$version-$source_release

RUN echo "export MOZBUILD=$HOME/.mozbuild" > mozconfig
RUN echo "ac_add_options --enable-bootstrap" >> mozconfig
RUN echo "" >> mozconfig
RUN echo "ac_add_options --target=x86_64-pc-mingw32" >> mozconfig
RUN echo "CROSS_BUILD=1" >> mozconfig
RUN echo "" >> mozconfig
RUN echo "export WINDOWSSDKDIR=\"$MOZBUILD/win-cross/vs/windows kits/10\"" >> mozconfig
RUN echo "mk_add_options \"export LD_PRELOAD=$MOZBUILD/win-cross/liblowercase/liblowercase.so\"" >> mozconfig
RUN echo "mk_add_options \"export LOWERCASE_DIRS=$MOZBUILD/win-cross\"" >> mozconfig
RUN echo "" >> mozconfig
RUN echo "EXTRA_PATH=\"$MOZBUILD/win-cross/vs/vc/tools/msvc/14.29.30133/bin/hostx64/x64:\"" >> mozconfig
RUN echo "mk_add_options \"export PATH=$EXTRA_PATH$PATH\"" >> mozconfig
RUN echo "" >> mozconfig
RUN echo "export CC=\"$MOZBUILD/clang/bin/clang-cl\"" >> mozconfig
RUN echo "export CXX=\"$MOZBUILD/clang/bin/clang-cl\"" >> mozconfig
RUN echo "export HOST_CC=\"$MOZBUILD/clang/bin/clang\"" >> mozconfig
RUN echo "export HOST_CXX=\"$MOZBUILD/clang/bin/clang++\"" >> mozconfig
RUN echo "" >> mozconfig

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH /root/.cargo/bin:$PATH
RUN rustup target add x86_64-pc-windows-msvc

RUN ./mach --no-interactive bootstrap --application-choice=browser
RUN ./mach artifact toolchain --from-build linux64-binutils
RUN ./mach artifact toolchain --from-build linux64-clang
RUN ./mach artifact toolchain --from-build linux64-rust-cross
RUN ./mach artifact toolchain --from-build linux64-nasm
RUN ./mach artifact toolchain --from-build linux64-node
RUN ./mach artifact toolchain --from-build linux64-cbindgen
RUN ./mach artifact toolchain --from-build linux64-wine
RUN ./mach artifact toolchain --from-build linux64-liblowercase

RUN (cd build/liblowercase && cargo build && mkdir -p ~/.mozbuild/win-cross/liblowercase && cp -v target/debug/liblowercase.so ~/.mozbuild/win-cross/liblowercase)

RUN ./mach python --virtualenv build build/vs/pack_vs.py build/vs/vs2019.yaml -o ${HOME}/.mozbuild/vs.tar.zst
RUN (cd ${HOME}/.mozbuild/win-cross && tar xf ../vs.tar.zst)
RUN rm -rf ${HOME}/.mozbuild/vs.tar.zst

# cleanup big mozilla build folder.
WORKDIR ..
RUN rm -rf librewolf-$version-$source_release librewolf-$version-$source_release.source.tar.gz

# expose the /work folder
WORKDIR /work
VOLUME ["/work"]













# dependencies needed to run ./mach bootstrap
#RUN apt-get -y update && apt-get -y upgrade && apt-get -y install mercurial python3 python3-dev python3-pip wget build-essential libpython3-dev m4 unzip uuid zip libasound2-dev libcurl4-openssl-dev libdbus-1-dev libdbus-glib-1-dev libdrm-dev libgtk-3-dev libpulse-dev libx11-xcb-dev libxt-dev xvfb rsync







# run the bootstrap
#RUN wget -q -O librewolf-$version-$source_release.source.tar.gz https://gitlab.com/librewolf-community/browser/source/-/jobs/artifacts/main/raw/librewolf-$version-$source_release.source.tar.gz?job=Build
#RUN tar xf librewolf-$version-$source_release.source.tar.gz
#WORKDIR librewolf-$version-$source_release
#
# mozconfig file
#RUN echo "" > mozconfig
#RUN echo "ac_add_options --target=x86_64-pc-mingw32" >> mozconfig
#RUN echo "ac_add_options --enable-bootstrap" >> mozconfig
##RUN echo "ac_add_options --disable-profiling" >> mozconfig
#RUN echo "" >> mozconfig
#
#RUN pip install winregistry
#
#RUN MOZBUILD_STATE_PATH=$HOME/.mozbuild ./mach --no-interactive bootstrap "--application-choice=browser"
#RUN /root/.cargo/bin/cargo install cbindgen
## 	x86_64-pc-windows-gnu
##	x86_64-pc-windows-msvc
#RUN /root/.cargo/bin/rustup target add x86_64-pc-windows-gnu
##failes target(s): x86_64-pc-mingw32
#
#
#WORKDIR ..
#RUN rm -rf librewolf-$version-$source_release librewolf-$version-$source_release.source.tar.gz


# our work happens here, on the host filesystem.


##
##
##
#
#FROM debian:bullseye
#
#ARG version=error
#ARG source_release=error
#
# setup windows tools
#
#RUN true
#

#
# run the bootstrap
#
####RUN wget -q -O librewolf-$version-$source_release.source.tar.gz https://gitlab.com/librewolf-community/browser/source/-/jobs/artifacts/main/raw/librewolf-$version-$source_release.source.tar.gz?job=Build
#RUN tar xf librewolf-$version-$source_release.source.tar.gz
#WORKDIR librewolf-$version-$source_release

#RUN wget -q -O firefox-$version.source.tar.gz "https://archive.mozilla.org/pub/firefox/releases/$version/source/firefox-$version.source.tar.xz"
#RUN tar xf firefox-$version.source.tar.gz
#WORKDIR firefox-$version

#RUN mkdir -p work
#WORKDIR work
#RUN wget -O bootstrap.py https://hg.mozilla.org/mozilla-central/raw-file/default/python/mozboot/bin/bootstrap.py
#RUN python3 bootstrap.py --no-interactive --application-choice=browser
#WORKDIR mozilla-unified
#
#
#
# mozconfig file
#RUN echo "" > mozconfig
#RUN echo "ac_add_options --target=x86_64-pc-mingw32" >> mozconfig
#RUN echo "ac_add_options --enable-bootstrap" >> mozconfig
#RUN echo "ac_add_options --disable-profiling" >> mozconfig
#RUN echo "" >> mozconfig
#
#
# throw in a patch to see if that fixes the zstandard issue.
#RUN wget https://raw.githubusercontent.com/archlinuxarm/PKGBUILDs/master/extra/firefox/revert-crossbeam-crates-upgrade.patch
#RUN patch -p1 -i revert-crossbeam-crates-upgrade.patch
#
#
#RUN MOZBUILD_STATE_PATH=$HOME/.mozbuild ./mach --no-interactive bootstrap --application-choice=browser
#RUN ./mach --no-interactive bootstrap --application-choice=browser
#
#
#
#RUN /root/.cargo/bin/cargo install cbindgen
#RUN /root/.cargo/bin/rustup target add x86_64-pc-mingw32
# not sure about this one..
#RUN pip install testresources pycairo
#
#
#
# setup wasi
#ENV wasi_fullversion 14.0
#ENV wasi_mainversion 14
#RUN export target_wasi_location=$HOME/.mozbuild/wrlb/ &&\
#    wget -q https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-$wasi_mainversion/wasi-sdk-$wasi_fullversion-linux.tar.gz &&\
#    tar xf wasi-sdk-$wasi_fullversion-linux.tar.gz &&\
#    mkdir -p $target_wasi_location &&\
#    rm -rf $target_wasi_location/wasi-sysroot &&\
#    cp -r wasi-sdk-$wasi_fullversion/share/wasi-sysroot $target_wasi_location &&\
#    rm -f wasi-sdk-*.tar.gz* && rm -rf wasi-sdk-*
#
# our work happens here, on the host filesystem.
#WORKDIR /work
#VOLUME ["/work"]






