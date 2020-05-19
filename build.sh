#!/bin/bash
set -e

BZIP2_VER=1.0.6
CURL_VER=7.68.0
ICU_VER=58.3  # Version 59 has major breaking changes
LIBLZMA_VER=5.2.4
SWIG_VER=4.0.1
SWORD_VER=1.8.1

mkdir -p ./build ./dist
cd ./build

# Download and run VSWhere
if [ ! -f "vswhere.exe" ]; then
  curl -LOJR https://github.com/microsoft/vswhere/releases/latest/download/vswhere.exe
fi

vcvars32Bat=`./vswhere -products '*' -version '[15.0,16.0)' -find 'VC/Auxiliary/Build/vcvars32.bat'`

function vsDevCmd {
  cmd //Q //C call "$vcvars32Bat" "&&" "$@"
}

# Download and build cURL
curlFile=curl-${CURL_VER}.zip
if [ ! -f "$curlFile" ]; then
  curl -LOJR https://curl.haxx.se/download/${curlFile}
  unzip $curlFile
  mv ./curl-${CURL_VER} ./curl

  cd ./curl/winbuild
  vsDevCmd nmake -f Makefile.vc mode=static DEBUG=no
  cd ../..
fi

# Download and build ICU
ICU_VER=${ICU_VER/./_}
icu4cFile=icu4c-${ICU_VER}-src.zip
if [ ! -f "$icu4cFile" ]; then
  curl -LOJR https://github.com/unicode-org/icu/releases/download/release-${ICU_VER/_/-}/${icu4cFile}
  unzip $icu4cFile

  find ./icu/source -type f -name '*.vcxproj' -exec sed -i 's|ToolsVersion="14.0"|ToolsVersion="15.0"|g;
    s|<PlatformToolset>v140</PlatformToolset>|<PlatformToolset>v141</PlatformToolset>|g' {} +

  cd ./icu
  vsDevCmd msbuild -t:Build -p:Configuration=Release -p:Platform=Win32 source/allinone/allinone.sln
  cd ..
fi

# TODO Download and build zlib

# Download and build bzip2
bzip2File=bzip2-${BZIP2_VER}.tar.gz
if [ ! -f "$bzip2File" ]; then
  curl -LOJR https://sourceforge.net/projects/bzip2/files/${bzip2File}/download
  tar -xf $bzip2File
  mv ./bzip2-${BZIP2_VER} ./bzip2

  cd ./bzip2
  vsDevCmd nmake -f makefile.msc
  cd ..
fi

# Download and build liblzma
xzFile=xz-${LIBLZMA_VER}-windows.zip
if [ ! -f "$xzFile" ]; then
  curl -LOJR https://tukaani.org/xz/${xzFile}
  unzip $xzFile -d ./xz

  cd ./xz/bin_i686
  vsDevCmd lib -def:../doc/liblzma.def -out:liblzma.lib -machine:x86
  cd ../..
fi

# TODO Download and build CLucene

# Download and patch libsword
swordFile=sword-${SWORD_VER}.tar.gz
if [ ! -f "$swordFile" ]; then
  swordShortVer=`echo $SWORD_VER | cut -c1-3`
  curl -LOJR http://crosswire.org/ftpmirror/pub/sword/source/v${swordShortVer}/${swordFile}
  tar -xf $swordFile
  mv ./sword-${SWORD_VER} ./sword

  cp ./sword/lib/vcppmake/libsword.{vcxproj,vcxproj.bak}
  patch ./sword/lib/vcppmake/libsword.vcxproj ../libsword.vcxproj.patch

  cp ./sword/bindings/swig/sword.{i,i.bak}
  patch ./sword/bindings/swig/sword.i ../sword.i.patch
fi

# Build libsword
cd ./sword
vsDevCmd msbuild -t:Build -p:Configuration=Release -p:Platform=Win32 lib/vcppmake/libsword.sln
cd ..

# Download SWIG
swigwinFile=swigwin-${SWIG_VER}.zip
if [ ! -f "$swigwinFile" ]; then
  curl -LOJR https://sourceforge.net/projects/swig/files/swigwin/swigwin-${SWIG_VER}/${swigwinFile}/download
  unzip $swigwinFile
  mv ./swigwin-${SWIG_VER} ./swig
fi

# Build Python bindings
pythonPath="${PYTHONHOME:-`which python | xargs dirname`}"
export PYTHON_INCLUDE="${pythonPath}/include"
export PYTHON_LIB="${pythonPath}/libs/python38.lib"

cd sword/bindings/swig
../../../swig/swig.exe -w451,402 -shadow -c++ -python -o python/Sword.cxx -I./ -I../../include \
  -I../../include/internal/regex -I../../../icu/include -I../../src/utilfuns/win32 -I../../../curl/include ./sword.i

cd python
echo "#!/usr/bin/env python3

from distutils.core import setup, Extension
setup(name='sword',version='${SWORD_VER}',
maintainer='Sword Developers',
maintainer_email='sword-devel@crosswire.org',
url='http://www.crosswire.org/sword',
py_modules=['Sword'],
include_dirs=['../', '../../../include', '../../', '../../../'],
ext_modules = [Extension('_Sword',['Sword.cxx'],
libraries=[('libsword')],
library_dirs=[('../../../lib/vcppmake/Release')],
define_macros=[('SWUSINGDLL', None)],
)]
,)" > setup.py
"${pythonPath}/python.exe" setup.py build
cd ../../../../..

# Copy Python module, libsword DLL, and dependencies to dist folder
icuShortVer=`echo $ICU_VER | cut -c1-2`
cp ./build/icu/bin/icu{dt,in,uc}${icuShortVer}.dll ./dist/
cp ./build/xz/bin_i686/liblzma.dll ./dist/
cp ./build/sword/lib/vcppmake/Release/libsword.dll ./dist/
cp ./build/sword/bindings/swig/python/build/lib.win32-3.8/* ./dist/
