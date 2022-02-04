.PHONY : help all clean veryclean fetch prune docker build debian11 fedora35 ci-debian ci-fedora35


version:=$(shell cat version)
release:=$(shell cat release)
source_release:=$(shell cat source_release)

tarball=librewolf-$(version)-$(source_release).source.tar.gz

help :
	@echo "Use: make [help] [all] [docker] [build] [clean] [veryclean] [fetch] [prune]"
	@echo ""
	@echo "OS targets:" 
	@echo "  [debian11]  - build for debian11"
	@echo "  [fedora35]  - build for fedora35"
	@echo ""
	@echo "CI targets:"
	@echo "  [ci-debian11]"
	@echo "  [ci-fedora35]"
	@echo ""


all :
	@echo "Nothing happens."
clean :
	sudo rm -rf work

veryclean : clean
	rm -f $(tarball)
prune :
	docker system prune --all --force

fetch : $(tarball)

$(tarball) :
	wget -O $(tarball) "https://gitlab.com/librewolf-community/browser/source/-/jobs/artifacts/main/raw/$(tarball)?job=Build"

docker : make-docker-image-debian11 make-docker-image-fedora35 
build : run-docker-image-debian11 run-docker-image-fedora35

## debian11
debian11 : run-docker-image-debian11

make-docker-image-debian11 :
	docker build --build-arg "distro=debian:bullseye" -t librewolf/bsys5-image-debian11 - < Dockerfile
run-docker-image-debian11 :
	mkdir work
	(cd work && tar xf ../$(tarball))
	docker run --rm -v $(shell pwd)/work:/work:rw librewolf/bsys5-image-debian11 sh -c "(cd work/librewolf-$(version) && ./mach build && ./mach package)"
	cp -v work/librewolf-$(version)/obj-x86_64-pc-linux-gnu/dist/librewolf-$(version)-$(source_release).en-US.linux-x86_64.tar.bz2 librewolf-$(version)-$(release).en-US.debian11-x86_64.tar.bz2 

ci-debian11 :
	mkdir work
	(cd work && tar xf ../$(tarball))
	(cd work/librewolf-$(version) && ./mach build && ./mach package)
	cp -v work/librewolf-$(version)/obj-x86_64-pc-linux-gnu/dist/librewolf-$(version)-$(source_release).en-US.linux-x86_64.tar.bz2 librewolf-$(version)-$(release).en-US.debian11-x86_64.tar.bz2 






## fedora35
fedora35 : run-docker-image-fedora35

make-docker-image-fedora35 :
	docker build --build-arg "distro=fedora:35" -t librewolf/bsys5-image-fedora35 - < Dockerfile
run-docker-image-fedora35 :
	mkdir work
	(cd work && tar xf ../$(tarball))
	docker run --rm -v $(shell pwd)/work:/work:rw librewolf/bsys5-image-fedora35 sh -c "cd /work/librewolf-$(version) && ./mach build && ./mach package"
	cp -v work/librewolf-$(version)/obj-x86_64-pc-linux-gnu/dist/librewolf-$(version)-$(source_release).en-US.linux-x86_64.tar.bz2 librewolf-$(version)-$(release).en-US.fedora35-x86_64.tar.bz2 

ci-fedora35 :
	mkdir work
	(cd work && tar xf ../$(tarball))
	(cd /work/librewolf-$(version) && ./mach build && ./mach package)
	cp -v work/librewolf-$(version)/obj-x86_64-pc-linux-gnu/dist/librewolf-$(version)-$(source_release).en-US.linux-x86_64.tar.bz2 librewolf-$(version)-$(release).en-US.fedora35-x86_64.tar.bz2 




