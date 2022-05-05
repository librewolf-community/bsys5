# $(arch)
# $(use_docker)

.PHONY : docker build

version:=$(shell cat version)
release:=$(shell cat release)
source_release:=$(shell cat source_release)
full_version:=$(version)-$(source_release)$(shell [ $(release) -gt 1 ] && echo "-$(release)")

outfile=librewolf-$(full_version).en-US.mac.$(arch).dmg

docker :
	docker build --build-arg "arch=$(arch)" --build-arg "version=$(version)" --build-arg "source_release=$(source_release)" -t librewolf/bsys5-image-macos-$(arch) - < assets/macos.Dockerfile

build : $(outfile) $(outfile).sha256sum

$(outfile) :
	${MAKE} work
	sed "s/_ARCH_/$(arch)/g" < assets/macos.mozconfig > work/librewolf-$(version)-$(source_release)/mozconfig
ifeq ($(use_docker),false)
	(cd work/librewolf-$(version)-$(source_release) && ./mach build && ./mach package)
else
	docker run --rm -v $(shell pwd)/work:/work:rw librewolf/bsys5-image-macos-$(arch) sh -c "cd /work/librewolf-$(version)-$(source_release) && ./mach build && ./mach package"
endif
	cp -v work/librewolf-$(version)-$(source_release)/obj-$(arch)-apple-darwin/dist/librewolf-$(version)-$(source_release).en-US.mac.dmg $(outfile)

$(outfile).sha256sum : $(outfile)
	sha256sum $(outfile) > $(outfile).sha256sum
	cat $(outfile).sha256sum
