# $(distro)
# $(distro_image)
# $(use_docker)

.PHONY : docker build

version:=$(shell cat version)
release:=$(shell cat release)
source_release:=$(shell cat source_release)
full_version:=$(version)-$(source_release)$(shell [ $(release) -gt 1 ] && echo "-$(release)")

outfile=librewolf-$(full_version).en-US.$(distro)-x86_64.tar.bz2

docker :
	docker build --build-arg "distro=$(distro_image)" --build-arg "version=$(version)" --build-arg "source_release=$(source_release)" -t librewolf/bsys5-image-$(distro) - < assets/linux.Dockerfile

build : $(outfile) $(outfile).sha256sum

$(outfile) :
	${MAKE} work
ifeq ($(use_docker),false)
	(cd work/librewolf-$(version)-$(source_release) && ./mach build && cat browser/locales/shipped-locales | xargs ./mach package-multi-locale --locales)
else
	docker run --rm -v $(shell pwd)/work:/work:rw librewolf/bsys5-image-$(distro) sh -c "cd /work/librewolf-$(version)-$(source_release) && ./mach build && cat browser/locales/shipped-locales | xargs ./mach package-multi-locale --locales"
endif
	cp -v work/librewolf-$(version)-$(source_release)/obj-x86_64-pc-linux-gnu/dist/librewolf-$(version)-$(source_release).en-US.linux-x86_64.tar.bz2 $(outfile)

$(outfile).sha256sum : $(outfile)
	sha256sum $(outfile) > $(outfile).sha256sum
	cat $(outfile).sha256sum
