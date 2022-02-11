# $(distro)
# $(use_docker)

.PHONY : artifacts-deb artifacts-rpm

version:=$(shell cat version)
release:=$(shell cat release)
source_release:=$(shell cat source_release)

use_docker=true

infile=librewolf-$(version)-$(release).en-US.$(distro)-x86_64.tar.bz2


###### .DEB ######



librewolf-$(version)-$(release).en-US.$(distro).x86_64.deb : $(infile)
	@echo "[debug] Building DEB:"

artifacts-deb : $(infile) $(infile).sha256sum
	sha256sum -c $(infile).sha256sum
	${MAKE} -f assets/linux.artifacts.mk distro=$(distro) librewolf-$(version)-$(release).en-US.$(distro).x86_64.deb














###### .RPM ######

librewolf-$(version)-$(release).$(fc).x86_64.rpm : $(infile)
	@echo "[debug] Building RPM:"

artifacts-rpm : $(infile) $(infile).sha256sum
	sha256sum -c $(infile).sha256sum
	${MAKE} -f assets/linux.artifacts.mk fc=$(fc) distro=$(distro) librewolf-$(version)-$(release).$(fc).x86_64.rpm

