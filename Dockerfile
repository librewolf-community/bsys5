ARG distro

FROM $distro

# dependencies needed to run ./mach bootstrap

RUN ( apt -y update && apt -y upgrade && apt -y install mercurial python3 python3-dev python3-pip ; true)
RUN ( dnf -y upgrade && dnf -y install mercurial python3 python3-devel && python3 -m pip install --user mercurial ; true)

# our work happens here, on the host filesystem.
WORKDIR /work
VOLUME ["/work"]
