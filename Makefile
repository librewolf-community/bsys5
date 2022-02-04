.PHONY : help all clean veryclean fetch prune


version:=$(shell cat version)
release:=$(shell cat release)
source_release:=$(shell cat source_release)


help :
	@echo "Use: make [help] [all] [clean] [veryclean] [fetch] [prune]"

all :
	${MAKE} make-docker-image-debian11
	${MAKE} run-docker-image-debian11
clean :
	sudo rm -rf work

veryclean :

prune :
	docker system prune --all --force

# fetching the source
tarball=librewolf-$(version)-$(source_release).source.tar.gz
fetch : $(tarball)
$(tarball) :
	wget -O $(tarball) "https://gitlab.com/librewolf-community/browser/source/-/jobs/artifacts/main/raw/$(tarball)?job=Build"



# debian11
tag=debian11
tag_distro=debian:bullseye
make-docker-image-debian11 :
	script -e -c 'time docker build --no-cache --build-arg distro=$(tag_distro) -t librewolf/bsys5-image-$(tag) - < Dockerfile'
run-docker-image-debian11 :
	sudo rm -rf work
	mkdir work
	(cd work && tar xf ../$(tarball))
	script -e -c 'time docker run --rm -v $(shell pwd)/work:/work:rw librewolf/bsys5-image-$(tag) sh -c "cd /work/librewolf-$(version) && MOZBUILD_STATE_PATH=$$HOME/.mozbuild ./mach --no-interactive bootstrap --application-choice=browser && . /root/.cargo/env && cargo install cbindgen && ./mach build && ./mach package"'




