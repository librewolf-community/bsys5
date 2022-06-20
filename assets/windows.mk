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

#
# here we add stuff that needs to be patched and changed before doing the build
# BUILD FOLDER = "work/librewolf-$(version)-$(source_release)"
#

	cp -v assets/windows.mozconfig work/librewolf-$(version)-$(source_release)/mozconfig
	cp -v assets/windows.build.sh work

ifeq ($(use_docker),false)
	(cd work/librewolf-$(version)-$(source_release) && ../windows.build.sh)
else
	docker run --rm -v $(shell pwd)/work:/work:rw win64:latest sh -c "cd /work/librewolf-$(version)-$(source_release) && ../windows.build.sh"
endif
	cp -v work/librewolf-$(version)-$(source_release)/obj-x86_64-pc-mingw32/dist/librewolf-$(version)-$(source_release).en-US.linux-x86_64.tar.bz2 $(outfile)

$(outfile).sha256sum : $(outfile)
	sha256sum $(outfile) > $(outfile).sha256sum
	cat $(outfile).sha256sum
