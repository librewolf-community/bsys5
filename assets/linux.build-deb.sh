set -e

mv -v librewolf lwdist

mkdir -p librewolf/DEBIAN
cd librewolf/DEBIAN
cat <<EOF >control
Architecture: all
Build-Depends: inkscape, librsvg2-bin
Depends: lsb-release, libasound2 (>= 1.0.16), libatk1.0-0 (>= 1.12.4), libc6 (>= 2.31), libcairo-gobject2 (>= 1.10.0), libcairo2 (>= 1.10.0), libdbus-1-3 (>= 1.9.14), libdbus-glib-1-2 (>= 0.78), libfontconfig1 (>= 2.12.6), libfreetype6 (>= 2.10.1), libgcc-s1 (>= 3.3), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.42), libgtk-3-0 (>= 3.14), libharfbuzz0b (>= 0.6.0), libpango-1.0-0 (>= 1.14.0), libpangocairo-1.0-0 (>= 1.14.0), libstdc++6 (>= 10), libx11-6, libx11-xcb1 (>= 2:1.6.9), libxcb-shm0, libxcb1, libxcomposite1 (>= 1:0.4.5), libxcursor1 (>> 1.1.2), libxdamage1 (>= 1:1.1), libxext6, libxfixes3, libxi6, libxrandr2 (>= 2:1.4.0), libxrender1, libxtst6
Recommends: libcanberra0, libdbusmenu-glib4, libdbusmenu-gtk3-4
Suggests: fonts-lyx
Description: The Librewolf Browser
Download-Size: 56.0 MB
Essential: no
Installed-Size: 204 MB
Maintainer: Bert van der Weerd <bert@stanzabird.nl>
Package: librewolf
Priority: optional
Provides: gnome-www-browser, www-browser, x-www-browser
Section: web
EOF
echo "Version: $1" >>control
cd ..

mkdir -p usr/share/librewolf
mv -v ../lwdist/* usr/share/librewolf
rmdir ../lwdist

mkdir -p usr/bin
cd usr/bin
ln -vs ../share/librewolf/librewolf
cd ../..

# add the application icon
mkdir -p usr/share/applications
mkdir -p usr/share/icons
cp -v usr/share/librewolf/browser/chrome/icons/default/default64.png usr/share/icons/librewolf.png
cp -v ../start-librewolf.desktop usr/share/applications/start-librewolf.desktop

cd ..
dpkg-deb --build librewolf

echo ""
ls -lh librewolf.deb
exit 0
