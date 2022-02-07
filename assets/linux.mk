# $(distro)
# $(distro_image)
# $(use_docker)

.PHONY : docker build

version:=$(shell cat version)
release:=$(shell cat release)
source_release:=$(shell cat source_release)

use_docker=true

outfile=librewolf-$(version)-$(release).en-US.$(distro)-x86_64.tar.bz2

docker :
	docker build --build-arg "distro=$(distro_image)" -t librewolf/bsys5-image-$(distro) - < assets/linux.Dockerfile

build :

	if [ $(use_docker) = true ]; then \
		docker run --rm -v $(shell pwd)/work:/work:rw librewolf/bsys5-image-$(distro) sh -c "cd /work/librewolf-$(version)-$(source_release) && ./mach build && ./mach package" ; \
	else \
		(cd /work/librewolf-$(version)-$(source_release) && ./mach build && ./mach package) ; \
	fi
	cp -v work/librewolf-$(version)-$(source_release)/obj-x86_64-pc-linux-gnu/dist/librewolf-$(version)-$(source_release).en-US.linux-x86_64.tar.bz2 librewolf-$(version)-$(release).en-US.$(distro)-x86_64.tar.bz2 
	sha256sum $(outfile) > $(outfile).sha256sum
	cat $(outfile).sha256sum