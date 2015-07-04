#!/bin/bash

set -e
set +h

export XORG_PREFIX="/usr"
export XORG_CONFIG="--prefix=$XORG_PREFIX --sysconfdir=/etc \
    --localstatedir=/var --disable-static"

. /etc/alps/alps.conf

#DEP:x7lib


cd $SOURCE_DIR

wget -nc http://xorg.freedesktop.org/releases/individual/app/xclock-1.0.7.tar.bz2
wget -nc ftp://ftp.x.org/pub/individual/app/xclock-1.0.7.tar.bz2


TARBALL=xclock-1.0.7.tar.bz2
DIRECTORY=`tar -tf $TARBALL | sed -e 's@/.*@@' | uniq `

tar -xf $TARBALL

cd $DIRECTORY

./configure $XORG_CONFIG &&
make

cat > 1434987998792.sh << "ENDOFFILE"
make install
ENDOFFILE
chmod a+x 1434987998792.sh
sudo ./1434987998792.sh
sudo rm -rf 1434987998792.sh


 
cd $SOURCE_DIR
sudo rm -rf $DIRECTORY
 
echo "xclock=>`date`" | sudo tee -a $INSTALLED_LIST