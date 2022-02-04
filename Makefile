.PHONY : help all clean veryclean fetch prune docker push build docker-debian11 debian11 ci-debian11 docker-mint20 mint20 ci-mint20 docker-ubuntu20 ubuntu20 ci-ubuntu20 docker-ubuntu21 ubuntu21 ci-ubuntu21 docker-fedora34 fedora34 ci-fedora34 docker-fedora35 fedora35 ci-fedora35

version:=$(shell cat version)
release:=$(shell cat release)
source_release:=$(shell cat source_release)

tarball=librewolf-$(version)-$(source_release).source.tar.gz

help :
	@echo "Use: make [help] [all] [docker] [push] [build] [clean]"
	@echo "          [veryclean] [fetch] [prune]"
	@echo ""
	@echo "docker targets:" 
	@echo "  [docker-debian11]"
	@echo "  [docker-mint20]"
	@echo "  [docker-ubuntu20]"
	@echo "  [docker-ubuntu21]"
	@echo "  [docker-fedora34]"
	@echo "  [docker-fedora35]"
	@echo ""
	@echo "build targets:" 
	@echo "  [debian11]"
	@echo "  [mint20]"
	@echo "  [ubuntu20]"
	@echo "  [ubuntu21]"
	@echo "  [fedora34]"
	@echo "  [fedora35]"
	@echo ""
	@echo "CI targets:"
	@echo "  [ci-debian11]"
	@echo "  [ci-mint20]"
	@echo "  [ci-ubuntu20]"
	@echo "  [ci-ubuntu21]"
	@echo "  [ci-fedora34]"
	@echo "  [ci-fedora35]"
	@echo ""


all :
	@echo "Nothing happens."
clean :
	sudo rm -rf work

veryclean : clean
	rm -f $(tarball)
	rm -f librewolf-*-*.en-US.*-x86_64.tar.bz2

prune :
	docker system prune --all --force

fetch : $(tarball)

$(tarball) :
	wget -O $(tarball) "https://gitlab.com/librewolf-community/browser/source/-/jobs/artifacts/main/raw/$(tarball)?job=Build"

docker : docker-debian11 docker-mint20 docker-ubuntu20 docker-ubuntu21 docker-fedora34 docker-fedora35

build : debian11 mint20 ubuntu20 ubuntu21 fedora34 fedora35

push :
	docker push librewolf/bsys5-image-debian11 librewolf/bsys5-image-mint20 librewolf/bsys5-image-ubuntu20 librewolf/bsys5-image-ubuntu21 librewolf/bsys5-image-fedora34 librewolf/bsys5-image-fedora35

work : $(tarball)
	mkdir work
	(cd work && tar xf ../$(tarball))



## debian11
docker-debian11 :
	${MAKE} -f linux.mk distro=debian11 "distro_image=debian:bullseye" docker
debian11 : work
	${MAKE} -f linux.mk distro=debian11 build
ci-debian11 : work
	${MAKE} -f linux.mk distro=debian11 ci

## mint20
docker-mint20 :
	${MAKE} -f linux.mk distro=mint20 "distro_image=linuxmintd/mint20.2-amd64" docker
mint20 : work
	${MAKE} -f linux.mk distro=mint20 build
ci-mint20 : work
	${MAKE} -f linux.mk distro=mint20 ci

## ubuntu20
docker-ubuntu20 :
	${MAKE} -f linux.mk distro=ubuntu20 "distro_image=ubuntu:20.04" docker
ubuntu20 : work
	${MAKE} -f linux.mk distro=ubuntu20 build
ci-ubuntu20 : work
	${MAKE} -f linux.mk distro=ubuntu20 ci

## ubuntu21
docker-ubuntu21 :
	${MAKE} -f linux.mk distro=ubuntu21 "distro_image=ubuntu:21.10" docker
ubuntu21 : work
	${MAKE} -f linux.mk distro=ubuntu21 build
ci-ubuntu21 : work
	${MAKE} -f linux.mk distro=ubuntu21 ci



## fedora34
docker-fedora34 :
	${MAKE} -f linux.mk distro=fedora34 "distro_image=fedora:34" docker
fedora34 : work
	${MAKE} -f linux.mk distro=fedora34 build
ci-fedora34 : work
	${MAKE} -f linux.mk distro=fedora34 ci

## fedora35
docker-fedora35 :
	${MAKE} -f linux.mk distro=fedora35 "distro_image=fedora:35" docker
fedora35 : work
	${MAKE} -f linux.mk distro=fedora35 build
ci-fedora35 : work
	${MAKE} -f linux.mk distro=fedora35 ci


