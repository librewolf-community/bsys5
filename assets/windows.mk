# $(use_docker)

.PHONY : docker build

version:=$(shell cat version)
release:=$(shell cat release)
source_release:=$(shell cat source_release)

#use_docker=true
ifeq ($(use_docker),)
use_docker:=true
endif

outfile=librewolf-$(version)-$(release).en-US.win64.zip
docker-image=librewolf/bsys5-image-windows

docker :
	docker build --build-arg "version=$(version)" --build-arg "source_release=$(source_release)" -t $(docker-image) - < assets/windows.Dockerfile

build : $(outfile) $(outfile).sha256sum

$(outfile) $(outfile).sha256sum :
	${MAKE} work
	if [ $(use_docker) = true ]; then \
		docker run --rm -v $(shell pwd)/work:/work:rw $(docker-image) sh -c "cd /work/librewolf-$(version)-$(source_release) && ./mach build && ./mach package" ; \
	else \
		(cd work/librewolf-$(version)-$(source_release) && ./mach build && ./mach package) ; \
	fi
