set -e

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
echo "==> Script finished"
echo ""
