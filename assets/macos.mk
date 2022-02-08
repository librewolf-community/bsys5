# $(arch)
# $(use_docker)

.PHONY : docker build

version:=$(shell cat version)
release:=$(shell cat release)
source_release:=$(shell cat source_release)

use_docker=true

outfile=librewolf-$(version)-$(source_release).en-US.mac.$(arch).dmg

docker :
	docker build --build-arg "arch=$(arch)" --build-arg "version=$(version)" --build-arg "source_release=$(source_release)" -t librewolf/bsys5-image-macos-$(arch) - < assets/macos.Dockerfile

build : $(outfile) $(outfile).sha256sum

$(outfile) $(outfile).sha256sum :
	sed "s/_ARCH_/$(arch)/g" < assets/macos.mozconfig > work/librewolf-$(version)-$(source_release)/mozconfig
	if [ $(use_docker) = true ]; then \
		docker run --rm -v $(shell pwd)/work:/work:rw librewolf/bsys5-image-macos-$(arch) sh -c "cd /work/librewolf-$(version)-$(source_release) && ./mach build && ./mach package" ; \
	else \
		(cd /work/librewolf-$(version)-$(source_release) && ./mach build && ./mach package) ; \
	fi
	cp -v work/librewolf-96.0.3-5/obj-$(arch)-apple-darwin/dist/librewolf-$(version)-$(source_release).en-US.mac.dmg $(outfile)
	sha256sum $(outfile) > $(outfile).sha256sum
	cat $(outfile).sha256sum
