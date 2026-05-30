#!/bin/sh
set -e

# Apple pre-compiled XcFrameworks, defined in xcfs/Package.swift, with checksum control:
swift run --package-path xcfs

# Python frameworks and files: 
curl -OL https://github.com/holzschu/a-shell/releases/download/cpython_05_22/pythonInstall.tar.gz
tar xzf pythonInstall.tar.gz

# Fix openssl: the zip is openssl-dynamic.xcframework.zip but project expects openssl.xcframework
if [ -d "xcfs/.build/artifacts/xcfs/openssl" ] && [ ! -f "xcfs/.build/artifacts/xcfs/openssl/openssl.xcframework/Info.plist" ]; then
    echo "Fixing openssl xcframework..."
    rm -rf xcfs/.build/artifacts/xcfs/openssl
    curl -OL https://github.com/holzschu/openssl-apple/releases/download/v1.1.1w/openssl-dynamic.xcframework.zip
    unzip -qo openssl-dynamic.xcframework.zip -d /tmp/openssl-extract/
    mkdir -p xcfs/.build/artifacts/xcfs/openssl
    mv /tmp/openssl-extract/openssl-dynamic.xcframework xcfs/.build/artifacts/xcfs/openssl/openssl.xcframework
    rm -rf /tmp/openssl-extract openssl-dynamic.xcframework.zip
fi

# Stub xcframeworks for ones without public releases:
for stub in blink ssh_agent ssh_cmdA openrsync openrsyncA; do
    if [ ! -d "xcfs/.build/artifacts/xcfs/$stub/$stub.xcframework" ]; then
        echo "Creating stub xcframework for $stub..."
        rm -rf "xcfs/.build/artifacts/xcfs/$stub"
        mkdir -p "xcfs/.build/artifacts/xcfs/$stub/$stub.xcframework/ios-arm64/$stub.framework"
        cat > "xcfs/.build/artifacts/xcfs/$stub/$stub.xcframework/Info.plist" << 'STUBEOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>CFBundlePackageType</key><string>XFWK</string>
<key>XCFrameworkFormatVersion</key><string>1.0</string>
<key>AvailableLibraries</key>
<array>
<dict>
<key>LibraryIdentifier</key><string>ios-arm64</string>
<key>LibraryPath</key><string>STUBNAME.framework</string>
<key>SupportedArchitectures</key><array><string>arm64</string></array>
<key>SupportedPlatform</key><string>ios</string>
</dict>
</array>
</dict>
</plist>
STUBEOF
        sed -i '' "s/STUBNAME/$stub/g" "xcfs/.build/artifacts/xcfs/$stub/$stub.xcframework/Info.plist"
    fi
done

# Stub standalone frameworks (pico, multimarkdown are regular .framework, not xcframework)
for stub in pico multimarkdown; do
    fwpath="xcfs/.build/artifacts/xcfs/$stub.framework"
    if [ ! -d "$fwpath" ]; then
        echo "Creating stub framework for $stub..."
        mkdir -p "$fwpath"
        touch "$fwpath/$stub"
        chmod +x "$fwpath/$stub"
        cat > "$fwpath/Info.plist" << 'STUBEOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>CFBundleDevelopmentRegion</key><string>en</string>
<key>CFBundleExecutable</key><string>STUBNAME</string>
<key>CFBundleIdentifier</key><string>Nicolas-Holzschuch.STUBNAME</string>
<key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
<key>CFBundleName</key><string>STUBNAME</string>
<key>CFBundlePackageType</key><string>FMWK</string>
<key>CFBundleShortVersionString</key><string>1.0</string>
<key>CFBundleVersion</key><string>1</string>
<key>MinimumOSVersion</key><string>12.0</string>
</dict>
</plist>
STUBEOF
        sed -i '' "s/STUBNAME/$stub/g" "$fwpath/Info.plist"
    fi
done

# Copy xcfs frameworks to cpython/Python-aux/ where project expects them:
mkdir -p cpython/Python-aux
for fw in freetype harfbuzz; do
    if [ -d "xcfs/.build/artifacts/xcfs/$fw/$fw.xcframework" ] && [ ! -d "cpython/Python-aux/$fw.xcframework" ]; then
        echo "Copying $fw.xcframework to cpython/Python-aux/..."
        cp -r "xcfs/.build/artifacts/xcfs/$fw/$fw.xcframework" "cpython/Python-aux/$fw.xcframework"
    fi
done

# Stub for libpng xcframework (no public release):
if [ ! -d "cpython/Python-aux/libpng.xcframework" ]; then
    echo "Creating stub libpng.xcframework..."
    mkdir -p cpython/Python-aux/libpng.xcframework/ios-arm64/libpng.framework
    cat > cpython/Python-aux/libpng.xcframework/Info.plist << 'STUBEOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>CFBundlePackageType</key><string>XFWK</string>
<key>XCFrameworkFormatVersion</key><string>1.0</string>
<key>AvailableLibraries</key>
<array>
<dict>
<key>LibraryIdentifier</key><string>ios-arm64</string>
<key>LibraryPath</key><string>libpng.framework</string>
<key>SupportedArchitectures</key><array><string>arm64</string></array>
<key>SupportedPlatform</key><string>ios</string>
</dict>
</array>
</dict>
</plist>
STUBEOF
fi

# ---------------------------------------------------------------------------
# Create stub Python dynamic frameworks for Resources_mini/Frameworks/
# Python frameworks are embedded in the app bundle (not linked at build time),
# so stubs are sufficient for a successful build. Python wont work at runtime.
# ---------------------------------------------------------------------------

create_python_stub() {
    local dir=$1
    local name=$2
    local fwdir="$dir/$name.framework"
    if [ -f "$fwdir/$name" ]; then
        return 0
    fi
    mkdir -p "$fwdir"
    touch "$fwdir/$name"
    chmod +x "$fwdir/$name"
    cat > "$fwdir/Info.plist" << 'STUBEOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>CFBundleDevelopmentRegion</key><string>en</string>
<key>CFBundleExecutable</key><string>STUBNAME</string>
<key>CFBundleIdentifier</key><string>Nicolas-Holzschuch.STUBNAME</string>
<key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
<key>CFBundleName</key><string>STUBNAME</string>
<key>CFBundlePackageType</key><string>FMWK</string>
<key>CFBundleShortVersionString</key><string>1.0</string>
<key>CFBundleVersion</key><string>1</string>
<key>MinimumOSVersion</key><string>12.0</string>
</dict>
</plist>
STUBEOF
    sed -i '' "s/STUBNAME/$name/g" "$fwdir/Info.plist"
}

duplicate_as_pythonA() {
    local src=$1
    local dst=$2
    if [ -d "Resources_mini/Frameworks/$dst.framework" ]; then
        return 0
    fi
    cp -r "Resources_mini/Frameworks/$src.framework" "Resources_mini/Frameworks/$dst.framework"
    mv "Resources_mini/Frameworks/$dst.framework/$src" "Resources_mini/Frameworks/$dst.framework/$dst"
    plutil -replace CFBundleExecutable -string "$dst" "Resources_mini/Frameworks/$dst.framework/Info.plist"
    plutil -replace CFBundleName -string "$dst" "Resources_mini/Frameworks/$dst.framework/Info.plist"
    plutil -replace CFBundleIdentifier -string "Nicolas-Holzschuch.$dst" "Resources_mini/Frameworks/$dst.framework/Info.plist"
}

echo "Creating Python stub frameworks..."
mkdir -p Resources_mini/Frameworks

# Base Python.framework
create_python_stub "Resources_mini/Frameworks" "Python"
create_python_stub "Resources_mini/Frameworks" "Python-_cffi_backend"
create_python_stub "Resources_mini/Frameworks" "Python-_ctypes_test"
create_python_stub "Resources_mini/Frameworks" "Python-_testexternalinspection"
create_python_stub "Resources_mini/Frameworks" "Python-_testimportmultiple"
create_python_stub "Resources_mini/Frameworks" "Python-_testmultiphase"
create_python_stub "Resources_mini/Frameworks" "Python-_testsinglephase"
create_python_stub "Resources_mini/Frameworks" "Python-cryptography.hazmat.bindings._openssl"
create_python_stub "Resources_mini/Frameworks" "Python-cryptography.hazmat.bindings._padding"
create_python_stub "Resources_mini/Frameworks" "Python-lxml.lxml"
create_python_stub "Resources_mini/Frameworks" "Python-regex._regex"
create_python_stub "Resources_mini/Frameworks" "Python-xxlimited"
create_python_stub "Resources_mini/Frameworks" "Python-xxlimited_35"

# Python-Crypto sub-packages:
for sub in \
    "Crypto.Cipher._ARC4" "Crypto.Cipher._chacha20" "Crypto.Cipher._pkcs1_decode" \
    "Crypto.Cipher._raw_aes" "Crypto.Cipher._raw_arc2" "Crypto.Cipher._raw_blowfish" \
    "Crypto.Cipher._raw_cast" "Crypto.Cipher._raw_cbc" "Crypto.Cipher._raw_cfb" \
    "Crypto.Cipher._raw_ctr" "Crypto.Cipher._raw_des" "Crypto.Cipher._raw_des3" \
    "Crypto.Cipher._raw_ecb" "Crypto.Cipher._raw_eksblowfish" "Crypto.Cipher._raw_ocb" \
    "Crypto.Cipher._raw_ofb" "Crypto.Cipher._Salsa20" \
    "Crypto.Hash._BLAKE2b" "Crypto.Hash._BLAKE2s" "Crypto.Hash._ghash_portable" \
    "Crypto.Hash._keccak" "Crypto.Hash._MD2" "Crypto.Hash._MD4" "Crypto.Hash._MD5" \
    "Crypto.Hash._poly1305" "Crypto.Hash._RIPEMD160" \
    "Crypto.Hash._SHA1" "Crypto.Hash._SHA224" "Crypto.Hash._SHA256" \
    "Crypto.Hash._SHA384" "Crypto.Hash._SHA512" \
    "Crypto.Math._modexp" "Crypto.Protocol._scrypt" \
    "Crypto.PublicKey._curve448" "Crypto.PublicKey._curve25519" \
    "Crypto.PublicKey._ec_ws" "Crypto.PublicKey._ed448" "Crypto.PublicKey._ed25519" \
    "Crypto.Util._cpuid_c" "Crypto.Util._strxor"; do
    create_python_stub "Resources_mini/Frameworks" "Python-$sub"
done

# Python-Cryptodome sub-packages (same list with Cryptodome instead of Crypto):
for sub in \
    "Cryptodome.Cipher._ARC4" "Cryptodome.Cipher._chacha20" "Cryptodome.Cipher._pkcs1_decode" \
    "Cryptodome.Cipher._raw_aes" "Cryptodome.Cipher._raw_arc2" "Cryptodome.Cipher._raw_blowfish" \
    "Cryptodome.Cipher._raw_cast" "Cryptodome.Cipher._raw_cbc" "Cryptodome.Cipher._raw_cfb" \
    "Cryptodome.Cipher._raw_ctr" "Cryptodome.Cipher._raw_des" "Cryptodome.Cipher._raw_des3" \
    "Cryptodome.Cipher._raw_ecb" "Cryptodome.Cipher._raw_eksblowfish" "Cryptodome.Cipher._raw_ocb" \
    "Cryptodome.Cipher._raw_ofb" "Cryptodome.Cipher._Salsa20" \
    "Cryptodome.Hash._BLAKE2b" "Cryptodome.Hash._BLAKE2s" "Cryptodome.Hash._ghash_portable" \
    "Cryptodome.Hash._keccak" "Cryptodome.Hash._MD2" "Cryptodome.Hash._MD4" "Cryptodome.Hash._MD5" \
    "Cryptodome.Hash._poly1305" "Cryptodome.Hash._RIPEMD160" \
    "Cryptodome.Hash._SHA1" "Cryptodome.Hash._SHA224" "Cryptodome.Hash._SHA256" \
    "Cryptodome.Hash._SHA384" "Cryptodome.Hash._SHA512" \
    "Cryptodome.Math._modexp" "Cryptodome.Protocol._scrypt" \
    "Cryptodome.PublicKey._curve448" "Cryptodome.PublicKey._curve25519" \
    "Cryptodome.PublicKey._ec_ws" "Cryptodome.PublicKey._ed448" "Cryptodome.PublicKey._ed25519" \
    "Cryptodome.Util._cpuid_c" "Cryptodome.Util._strxor"; do
    create_python_stub "Resources_mini/Frameworks" "Python-$sub"
done

# pythonA.framework (Python interpreter variant)
if [ ! -f "Resources_mini/Frameworks/pythonA.framework/pythonA" ]; then
    create_python_stub "Resources_mini/Frameworks" "pythonA"
fi

# Duplicate as PythonA variants:
echo "Creating PythonA framework variants..."
for base in $(ls Resources_mini/Frameworks/ | grep '^Python-' | sed 's/\.framework$//'); do
    anode=$(echo "$base" | sed 's/Python-/PythonA-/')
    if [ "$base" != "$anode" ]; then
        duplicate_as_pythonA "$base" "$anode"
    fi
done

# Special case: PythonA_cffi_backend (note: no dash after PythonA)
if [ ! -d "Resources_mini/Frameworks/PythonA_cffi_backend.framework" ]; then
    duplicate_as_pythonA "Python-_cffi_backend" "PythonA_cffi_backend"
fi

# PythonA variants of _ctypes_test, _test* etc:
for base in Python-_ctypes_test Python-_testexternalinspection Python-_testimportmultiple \
    Python-_testmultiphase Python-_testsinglephase; do
    anode="PythonA${base#Python-}"
    if [ ! -d "Resources_mini/Frameworks/$anode.framework" ]; then
        duplicate_as_pythonA "$base" "$anode"
    fi
done

# Fix cpython submodule URL for GitHub Actions:
git config --local submodule.cpython.url https://github.com/holzschu/cpython.git 2>/dev/null || true

# Create Resources/bin if needed:
mkdir -p Resources/bin

echo "Done downloading frameworks."
