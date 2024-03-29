#!/bin/bash

set -e
set +h

export XORG_PREFIX="/usr"
export XORG_CONFIG="--prefix=$XORG_PREFIX --sysconfdir=/etc \
    --localstatedir=/var --disable-static"

. /etc/alps/alps.conf

#DEP:fontconfig
#DEP:libxcb


cd $SOURCE_DIR






cat > lib-7.7.md5 << "EOF"
c5ba432dd1514d858053ffe9f4737dd8 xtrans-1.3.5.tar.bz2
c35d6ad95b06635a524579e88622fdb5 libX11-1.6.2.tar.bz2
52df7c4c1f0badd9f82ab124fb32eb97 libXext-1.3.3.tar.bz2
a8a0dbd2299b2568d8c919883f5c8501 libFS-1.0.6.tar.bz2
addfb1e897ca8079531669c7c7711726 libICE-1.0.9.tar.bz2
499a7773c65aba513609fe651853c5f3 libSM-1.2.2.tar.bz2
7a773b16165e39e938650bcc9027c1d5 libXScrnSaver-1.2.2.tar.bz2
03149823ae57bb02d0cec90d5b97d56c libXt-1.1.4.tar.bz2
41d92ab627dfa06568076043f3e089e4 libXmu-1.1.2.tar.bz2
769ee12a43611cdebd38094eaf83f3f0 libXpm-3.5.11.tar.bz2
7446f5fba888672aad068b29c0928ba3 libXaw-1.0.12.tar.bz2
b985b85f8b9386c85ddcfe1073906b4d libXfixes-5.0.1.tar.bz2
f7a218dcbf6f0848599c6c36fc65c51a libXcomposite-0.4.4.tar.bz2
2bd9a15fcf64d216e63b8d129e4f1f1c libXrender-0.9.8.tar.bz2
1e7c17afbbce83e2215917047c57d1b3 libXcursor-1.1.14.tar.bz2
0cf292de2a9fa2e9a939aefde68fd34f libXdamage-1.1.4.tar.bz2
ad2919764933e075bb0361ad5caa3d19 libfontenc-1.1.2.tar.bz2
664629bfa7cdf8b984155019fd395dcb libXfont-1.5.0.tar.bz2
331b3a2a3a1a78b5b44cfbd43f86fcfe libXft-2.3.2.tar.bz2
9c4a69c34b19ec1e4212e849549544cb libXi-1.7.4.tar.bz2
9336dc46ae3bf5f81c247f7131461efd libXinerama-1.1.3.tar.bz2
210ed9499a3d9c96e3a221629b7d39b0 libXrandr-1.4.2.tar.bz2
45ef29206a6b58254c81bea28ec6c95f libXres-1.0.7.tar.bz2
25c6b366ac3dc7a12c5d79816ce96a59 libXtst-1.2.2.tar.bz2
e0af49d7d758b990e6fef629722d4aca libXv-1.0.10.tar.bz2
2e4014e9d55c430e307999a6b3dd256d libXvMC-1.0.8.tar.bz2
d7dd9b9df336b7dd4028b6b56542ff2c libXxf86dga-1.1.4.tar.bz2
e46f6ee4f4567349a3189044fe1bb712 libXxf86vm-1.1.3.tar.bz2
ba983eba5a9f05d152a0725b8e863151 libdmx-1.1.3.tar.bz2
19e6533ae64abba0773816a23f2b9507 libxkbfile-1.0.8.tar.bz2
66662e76899112c0f99e22f2fc775a7e libxshmfence-1.2.tar.bz2
EOF

mkdir -pv lib &&
cd lib &&
grep -v '^#' ../lib-7.7.md5 | awk '{print $2}' | wget -i- -nc \
    -B http://xorg.freedesktop.org/releases/individual/lib/ &&
md5sum -c ../lib-7.7.md5

as_root()
{
  if   [ $EUID = 0 ];        then $*
  elif [ -x /usr/bin/sudo ]; then sudo $*
  else                            su -c \\"$*\\"
  fi
}

export -f as_root

for package in $(grep -v '^#' ../lib-7.7.md5 | awk '{print $2}')
do
  packagedir=${package%.tar.bz2}
  tar -xf $package
  pushd $packagedir
  case $packagedir in
    libXfont-[0-9]* )
      ./configure $XORG_CONFIG --disable-devel-docs
    ;;
    libXt-[0-9]* )
      ./configure $XORG_CONFIG \
                  --with-appdefaultdir=/etc/X11/app-defaults
    ;;
    * )
      ./configure $XORG_CONFIG
    ;;
  esac
  make
  #make check 2>&1 | tee ../$packagedir-make_check.log
  as_root make install
  popd
  rm -rf $packagedir
  as_root /sbin/ldconfig
done


 
cd $SOURCE_DIR
 
echo "x7lib=>`date`" | sudo tee -a $INSTALLED_LIST