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
	@echo "[debug] Building DEB:" $@ "using as source:" $<

	mkdir -p work
	(cd work && tar xf ../$<)
	cp -v assets/linux.build-deb.sh work/
	sed "s/MYDIR/\/usr\/share\/librewolf/g" < assets/linux.librewolf.desktop.in > work/start-librewolf.desktop
	if [ $(use_docker) = true ]; then \
		docker run --rm -v $(shell pwd)/work:/work:rw librewolf/bsys5-image-$(distro) sh -c "bash linux.build-deb.sh $(version) $(release)" ; \
	else \
		(cd work && bash linux.build-deb.sh $(version) $(release)) ; \
	fi
	cp -v work/librewolf.deb $@
	sha256sum $@ > $@.sha256sum
	cat $@.sha256sum



artifacts-deb : $(infile) $(infile).sha256sum
	sha256sum -c $(infile).sha256sum
	${MAKE} -f assets/linux.artifacts.mk distro=$(distro) librewolf-$(version)-$(release).en-US.$(distro).x86_64.deb














###### .RPM ######

librewolf-$(version)-$(release).$(fc).x86_64.rpm : $(infile)
	@echo "[debug] Building RPM:" $@ "using as source:" $<

artifacts-rpm : $(infile) $(infile).sha256sum
	sha256sum -c $(infile).sha256sum
	${MAKE} -f assets/linux.artifacts.mk fc=$(fc) distro=$(distro) librewolf-$(version)-$(release).$(fc).x86_64.rpm

