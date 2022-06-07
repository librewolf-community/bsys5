set -e

echo ""
echo "---> Starting build script."
echo ""


echo ""

ls -lad /root
ls -la /root
ls -lad /root/.mozbuild
ls -la /root/.mozbuild

echo ""




# MACH_BUILD_PYTHON_NATIVE_PACKAGE_SOURCE=none
# MOZBUILD_STATE_PATH=$HOME/.mozbuild

pip install winregistry

./mach --no-interactive bootstrap "--application-choice=browser"

/root/.cargo/bin/cargo install cbindgen
# 	x86_64-pc-windows-gnu
#	x86_64-pc-windows-msvc
/root/.cargo/bin/rustup target add x86_64-pc-windows-gnu



# MACH_BUILD_PYTHON_NATIVE_PACKAGE_SOURCE=none MOZBUILD_STATE_PATH=/root/.mozbuild ./mach build
./mach build

cat browser/locales/shipped-locales | xargs ./mach package-multi-locale --locales > /dev/null
