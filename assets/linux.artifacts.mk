# $(distro)
# $(fc)
# $(use_docker)

.PHONY : artifacts-deb artifacts-rpm

version:=$(shell cat version)
release:=$(shell cat release)
source_release:=$(shell cat source_release)

infile=librewolf-$(version)-$(release).en-US.$(distro)-x86_64.tar.bz2

#
# Debian based:
#

librewolf-$(version)-$(release).en-US.$(distro).x86_64.deb : $(infile)
	mkdir -p work
	(cd work && tar xf ../$<)
	cp -v assets/linux.build-deb.sh work/
	(cd work && sed "s/MYDIR/\/usr\/share\/librewolf/g" < ../assets/linux.librewolf.desktop.in > start-librewolf.desktop)
ifeq ($(use_docker),false)
	(cd work && bash linux.build-deb.sh $(version) $(release))
else
	docker run --rm -v $(shell pwd)/work:/work:rw librewolf/bsys5-image-$(distro) sh -c "bash linux.build-deb.sh $(version) $(release)"
endif
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
ifeq ($(use_docker),false)
	(cp -r work / && cd work && bash linux.build-rpm.sh $(version) $(release)) ; \
	cp -v /work/$@ $@
else
	docker run --rm -v $(shell pwd)/work:/work:rw librewolf/bsys5-image-$(distro) sh -c "bash linux.build-rpm.sh $(version) $(release)" ; \
	cp -v work/$@ $@
endif
	sha256sum $@ > $@.sha256sum
	cat $@.sha256sum

artifacts-rpm : $(infile) $(infile).sha256sum
	sha256sum -c $(infile).sha256sum
	${MAKE} -f assets/linux.artifacts.mk fc=$(fc) distro=$(distro) librewolf-$(version)-$(release).$(fc).x86_64.rpm

