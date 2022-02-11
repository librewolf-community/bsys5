set -e

rm -rf /WORK
mkdir /WORK
cd /WORK

mkdir /artifacts

version=$(cat /work/version)
release=$(cat /work/release)

echo '---'
echo "--- LibreWolf version file is: $version"
echo "--- LibreWolf release is: $release"
echo '---'
echo '--- Contents of /artifacts folder:'
ls -la /artifacts
echo '---'
echo '--- Contents of /WORK folder:'
ls -la /WORK
echo '---'




rm -rf rpmbuild
mkdir -p rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
sed "s/__VERSION__/$version/g" < /work/librewolf.spec > /work/tmp.spec
sed "s/__RELEASE__/$release/g" < /work/tmp.spec > rpmbuild/SPECS/librewolf.spec

# copy in the librewolf assets
cp -rv /work/librewolf rpmbuild/SOURCES


cd rpmbuild/SOURCES

mkdir -p librewolf-$version/usr/share/librewolf
mkdir -p librewolf-$version/usr/bin

mv -v librewolf/* librewolf-$version/usr/share/librewolf
rmdir librewolf
cd librewolf-$version/usr/bin
ln -s ../share/librewolf/librewolf
cd ../../..

# Application icon
mkdir -p librewolf-$version/usr/share/applications
mkdir -p librewolf-$version/usr/share/icons
cp -v librewolf-$version/usr/share/librewolf/browser/chrome/icons/default/default64.png librewolf-$version/usr/share/icons/librewolf.png
sed "s/MYDIR/\/usr\/share\/librewolf/g" < /work/librewolf/start-librewolf.desktop.in > librewolf-$version/usr/share/applications/librewolf.desktop


tar cvfz lw.tar.gz librewolf-$version
# todo perhaps: rm -rf librwolf-$version

cd ../..

rm -rf $HOME/rpmbuild
cp -rv rpmbuild $HOME

# Build the package!
echo '---'
echo "[debug] Running rpmbuild.."
echo '---'

rpmbuild -v -bb $(pwd)/rpmbuild/SPECS/librewolf.spec
echo '--- [debug] Copying output files to /artifacts'


#Wrote: /root/rpmbuild/RPMS/x86_64/librewolf-94.0.2-1.fc35.x86_64.rpm
cp -v ~/rpmbuild/RPMS/x86_64/librewolf-*.rpm /work
