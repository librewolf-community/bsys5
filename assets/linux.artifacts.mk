# $(distro)
# $(use_docker)

.PHONY : artifacts-deb artifacts-rpm

version:=$(shell cat version)
release:=$(shell cat release)
source_release:=$(shell cat source_release)

use_docker=true

infile=librewolf-$(version)-$(release).en-US.$(distro)-x86_64.tar.bz2

artifacts-deb : $(infile) $(infile).sha256sum
	sha256sum -c $(infile).sha256sum
artifacts-rpm : $(infile) $(infile).sha256sum
	sha256sum -c $(infile).sha256sum

