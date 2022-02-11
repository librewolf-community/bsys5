# $(distro)
# $(use_docker)

.PHONY : artifacts-deb artifacts-rpm

version:=$(shell cat version)
release:=$(shell cat release)
source_release:=$(shell cat source_release)

use_docker=true

infile=librewolf-$(version)-$(release).en-US.$(distro)-x86_64.tar.bz2

#
# Debian based:
#

librewolf-$(version)-$(release).en-US.$(distro).x86_64.deb : $(infile)
	@echo ""
	@echo "[debug] Building DEB:" $@ "using as source:" $<
	@echo ""
	mkdir -p work
	(cd work && tar xf ../$<)
	cp -v assets/linux.build-deb.sh work/
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



#
# RPM Based:
#

librewolf-$(version)-$(release).$(fc).x86_64.rpm : $(infile)
	@echo ""
	@echo "[debug] Building RPM:" $@ "using as source:" $<
	@echo ""
	mkdir -p work
	(cd work && tar xf ../$<)
	cp -v assets/linux.build-rpm.sh work
	cp -v version work
	cp -v release work
	cp -v assets/linux.librewolf.spec work/librewolf.spec
	cp -v assets/linux.librewolf.desktop.in work/librewolf/start-librewolf.desktop.in
	cp -v assets/linux.librewolf.ico work/librewolf/librewolf.ico
	rm -f work/librewolf/browser/features/proxy-failover@mozilla.com.xpi
	rm -f work/librewolf/pingsender
	rm -f work/librewolf/precomplete
	rm -f work/librewolf/removed-files
	if [ $(use_docker) = true ]; then \
		docker run --rm -v $(shell pwd)/work:/work:rw librewolf/bsys5-image-$(distro) sh -c "bash linux.build-rpm.sh $(version) $(release)" ; \
	else \
		(cd / && cp -r /work / && cd /work && bash linux.build-rpm.sh $(version) $(release)) ; \
	fi
	cp -v work/$@ $@
	sha256sum $@ > $@.sha256sum
	cat $@.sha256sum

artifacts-rpm : $(infile) $(infile).sha256sum
	sha256sum -c $(infile).sha256sum
	${MAKE} -f assets/linux.artifacts.mk fc=$(fc) distro=$(distro) librewolf-$(version)-$(release).$(fc).x86_64.rpm

