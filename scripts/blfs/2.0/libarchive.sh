#!/bin/bash

set -e
set +h

export XORG_PREFIX="/usr"
export XORG_CONFIG="--prefix=$XORG_PREFIX --sysconfdir=/etc \
    --localstatedir=/var --disable-static"

. /etc/alps/alps.conf



cd $SOURCE_DIR

wget -nc http://www.libarchive.org/downloads/libarchive-3.1.2.tar.gz


TARBALL=libarchive-3.1.2.tar.gz
DIRECTORY=`tar -tf $TARBALL | sed -e 's@/.*@@' | uniq `

tar -xf $TARBALL

cd $DIRECTORY

./configure --prefix=/usr --disable-static &&
make

cat > 1434987998758.sh << "ENDOFFILE"
make install
ENDOFFILE
chmod a+x 1434987998758.sh
sudo ./1434987998758.sh
sudo rm -rf 1434987998758.sh


 
cd $SOURCE_DIR
sudo rm -rf $DIRECTORY
 
echo "libarchive=>`date`" | sudo tee -a $INSTALLED_LIST