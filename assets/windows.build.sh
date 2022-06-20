set -e

echo ""
echo "==> Starting: mach bootstrap"
echo ""

# MACH_BUILD_PYTHON_NATIVE_PACKAGE_SOURCE=none
# MOZBUILD_STATE_PATH=$HOME/.mozbuild
#./mach --no-interactive bootstrap "--application-choice=browser"

echo ""
echo "==> Installing additional dependencies and packages"
echo ""

#./mach artifact toolchain --from-build linux64-mingw32
#./mach artifact toolchain --from-build linux64-nsis
#./mach artifact toolchain --from-build linux64-fxc2

# x86_64-pc-windows-gnu
# x86_64-pc-windows-msvc
/root/.cargo/bin/rustup target add x86_64-pc-windows-gnu
/root/.cargo/bin/cargo install cbindgen

echo ""
echo "==> Starting: ./mach build"
echo ""

# MACH_BUILD_PYTHON_NATIVE_PACKAGE_SOURCE=none
# MOZBUILD_STATE_PATH=/root/.mozbuild ./mach build
./mach build

echo ""
echo "==> Starting: ./mach package-multi-locale"
echo ""

cat browser/locales/shipped-locales | xargs ./mach package-multi-locale --locales > /dev/null

echo ""
echo "==> Script finished! woot."
echo ""
