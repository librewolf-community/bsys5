# $(use_docker)

.PHONY : docker build

version:=$(shell cat version)
release:=$(shell cat release)
source_release:=$(shell cat source_release)
full_version:=$(version)-$(source_release)$(shell [ $(release) -gt 1 ] && echo "-$(release)")

outfile=librewolf-$(full_version).en-US.win64-x86_64.tar.bz2

docker :
	docker build --build-arg "version=$(version)" --build-arg "source_release=$(source_release)" -t win64:latest - < assets/windows.Dockerfile

build : $(outfile) $(outfile).sha256sum

$(outfile) :
	${MAKE} work
ifeq ($(use_docker),false)
	(cd work/librewolf-$(version)-$(source_release) && ./mach build && cat browser/locales/shipped-locales | xargs ./mach package-multi-locale --locales > /dev/null)
else
	docker run --rm -v $(shell pwd)/work:/work:rw win64:latest sh -c "cd /work/librewolf-$(version)-$(source_release) && ./mach build && echo Packaging... && cat browser/locales/shipped-locales | xargs ./mach package-multi-locale --locales >/dev/null"
endif
	cp -v work/librewolf-$(version)-$(source_release)/obj-x86_64-pc-linux-gnu/dist/librewolf-$(version)-$(source_release).en-US.linux-x86_64.tar.bz2 $(outfile)

$(outfile).sha256sum : $(outfile)
	sha256sum $(outfile) > $(outfile).sha256sum
	cat $(outfile).sha256sum


## $(use_docker)
#
#.PHONY : docker build
#
#version:=$(shell cat version)
#release:=$(shell cat release)
#source_release:=$(shell cat source_release)
#
##use_docker=true
#ifeq ($(use_docker),)
#use_docker:=true
#endif
#
#outfile=librewolf-$(version)-$(release).en-US.win64.zip
#docker-image=librewolf/bsys5-image-windows

