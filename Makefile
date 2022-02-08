.PHONY : help clean veryclean fetch prune docker push build update work docker-debian11 debian11 docker-mint20 mint20 docker-ubuntu20 ubuntu20 docker-ubuntu21 ubuntu21 docker-fedora34 fedora34 docker-fedora35 fedora35 docker-macos-x86_64 macos-x86_64 docker-macos-aarch64 macos-aarch64

version:=$(shell cat version)
release:=$(shell cat release)
source_release:=$(shell cat source_release)

help :
	@echo "Use: make [help] [docker] [push] [build] [clean] [veryclean]"
	@echo "          [fetch] [update] [prune]"
	@echo ""
	@echo "docker targets:" 
	@echo "  [docker-debian11]"
	@echo "  [docker-mint20]"
	@echo "  [docker-ubuntu20]"
	@echo "  [docker-ubuntu21]"
	@echo "  [docker-fedora34]"
	@echo "  [docker-fedora35]"
	@echo "  [docker-macos-x86_64]"
	@echo "  [docker-macos-aarch64]"
	@echo ""
	@echo "build targets:" 
	@echo "  [debian11]"
	@echo "  [mint20]"
	@echo "  [ubuntu20]"
	@echo "  [ubuntu21]"
	@echo "  [fedora34]"
	@echo "  [fedora35]"
	@echo "  [macos-x64_64]"
	@echo "  [macos-aarch64]"
	@echo ""


clean :
	sudo rm -rf work

veryclean : clean
	rm -f $(tarball)
	rm -f librewolf-*-*.en-US.*-x86_64.tar.bz2 librewolf-*-*.en-US.*-x86_64.tar.bz2.sha256sum librewolf-*-*.en-US.mac.*

prune :
	docker system prune --all --force

docker : docker-debian11 docker-mint20 docker-ubuntu20 docker-ubuntu21 docker-fedora34 docker-fedora35 docker-macos-x86_64 docker-macos-aarch64

build :
	${MAKE} clean
	${MAKE} debian11
	${MAKE} clean
	${MAKE} mint20
	${MAKE} clean
	${MAKE} ubuntu20
	${MAKE} clean
	${MAKE} ubuntu21
	${MAKE} clean
	${MAKE} fedora34
	${MAKE} clean
	${MAKE} fedora35
	${MAKE} clean
	${MAKE} macos-x86_64
	${MAKE} clean
	${MAKE} macos-aarch64
	${MAKE} clean


full-build :
	${MAKE} docker-debian11
	${MAKE} clean
	${MAKE} debian11
	${MAKE} docker-mint20
	${MAKE} clean
	${MAKE} mint20
	${MAKE} docker-ubuntu20
	${MAKE} clean
	${MAKE} ubuntu20
	${MAKE} docker-ubuntu21
	${MAKE} clean
	${MAKE} ubuntu21
	${MAKE} docker-fedora34
	${MAKE} clean
	${MAKE} fedora34
	${MAKE} docker-fedora35
	${MAKE} clean
	${MAKE} fedora35
	${MAKE} docker-macos-x86_64
	${MAKE} clean
	${MAKE} macos-x86_64
	${MAKE} docker-macos-aarch64
	${MAKE} clean
	${MAKE} macos-aarch64
	${MAKE} clean

push :
	docker push librewolf/bsys5-image-debian11
	docker push librewolf/bsys5-image-mint20
	docker push librewolf/bsys5-image-ubuntu20
	docker push librewolf/bsys5-image-ubuntu21
	docker push librewolf/bsys5-image-fedora34
	docker push librewolf/bsys5-image-fedora35
	docker push librewolf/bsys5-image-macos-x86_64
	docker push librewolf/bsys5-image-macos-aarch64

update :
	@wget -q -O version "https://gitlab.com/librewolf-community/browser/source/-/raw/main/version"
	@wget -q -O source_release "https://gitlab.com/librewolf-community/browser/source/-/raw/main/release"
	@echo Source version: $(shell cat version)-$(shell cat source_release)
	@echo Bsys5 release: $(shell cat release)





## setting up the work folder
tarball=librewolf-$(version)-$(source_release).source.tar.gz
$(tarball) :
	wget -q -O $(tarball) "https://gitlab.com/api/v4/projects/32320088/packages/generic/librewolf-source/$(version)-$(source_release)/$(tarball)"
work : $(tarball)
	mkdir work
	(cd work && tar xf ../$(tarball))




#
# Linux
#

## debian11
docker-debian11 :
	${MAKE} -f assets/linux.mk distro=debian11 "distro_image=debian:bullseye" docker
debian11 :
	${MAKE} -f assets/linux.mk distro=debian11 build
	${MAKE} -f assets/linux.artifacts.mk distro=debian11 artifacts-deb
## mint20
docker-mint20 :
	${MAKE} -f assets/linux.mk distro=mint20 "distro_image=linuxmintd/mint20.2-amd64" docker
mint20 :
	${MAKE} -f assets/linux.mk distro=mint20 build
	${MAKE} -f assets/linux.artifacts.mk distro=mint20 artifacts-deb
## ubuntu20
docker-ubuntu20 :
	${MAKE} -f assets/linux.mk distro=ubuntu20 "distro_image=ubuntu:20.04" docker
ubuntu20 :
	${MAKE} -f assets/linux.mk distro=ubuntu20 build
	${MAKE} -f assets/linux.artifacts.mk distro=ubuntu20 artifacts-deb
## ubuntu21
docker-ubuntu21 :
	${MAKE} -f assets/linux.mk distro=ubuntu21 "distro_image=ubuntu:21.10" docker
ubuntu21 :
	${MAKE} -f assets/linux.mk distro=ubuntu21 build
	${MAKE} -f assets/linux.artifacts.mk distro=ubuntu21 artifacts-deb
## fedora34
docker-fedora34 :
	${MAKE} -f assets/linux.mk distro=fedora34 "distro_image=fedora:34" docker
fedora34 :
	${MAKE} -f assets/linux.mk distro=fedora34 build
	${MAKE} -f assets/linux.artifacts.mk distro=fedora34 artifacts-rpm
## fedora35
docker-fedora35 :
	${MAKE} -f assets/linux.mk distro=fedora35 "distro_image=fedora:35" docker
fedora35 :
	${MAKE} -f assets/linux.mk distro=fedora35 build
	${MAKE} -f assets/linux.artifacts.mk distro=fedora35 artifacts-rpm


#
# MacOS
#

## macos-x86_64
docker-macos-x86_64 :
	${MAKE} -f assets/macos.mk arch=x86_64 docker
macos-x86_64 :
	${MAKE} -f assets/macos.mk arch=x86_64 build

## macos-aarch64
docker-macos-aarch64 :
	${MAKE} -f assets/macos.mk arch=aarch64 docker
macos-aarch64 :
	${MAKE} -f assets/macos.mk arch=aarch64 build
