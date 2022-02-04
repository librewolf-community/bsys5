ARG distro
FROM $distro

# dependencies needed to run ./mach bootstrap
RUN ( apt-get -y update && apt-get -y upgrade && apt-get -y install mercurial python3 python3-dev python3-pip ; true)
RUN ( dnf -y upgrade && dnf -y install mercurial python3 python3-devel ; true)

# our work happens here, on the host filesystem.
WORKDIR /work
VOLUME ["/work"]
