#!/bin/bash

set -e
set +h

export XORG_PREFIX="/usr"
export XORG_CONFIG="--prefix=$XORG_PREFIX --sysconfdir=/etc \
    --localstatedir=/var --disable-static"

. /etc/alps/alps.conf

#DEP:dbus-glib
#DEP:libxslt
#DEP:gobject-introspection
#DEP:vala


cd $SOURCE_DIR

wget -nc http://telepathy.freedesktop.org/releases/telepathy-glib/telepathy-glib-0.24.1.tar.gz


TARBALL=telepathy-glib-0.24.1.tar.gz
DIRECTORY=`tar -tf $TARBALL | sed -e 's@/.*@@' | uniq `

tar -xf $TARBALL

cd $DIRECTORY

./configure --prefix=/usr \
            --enable-vala-bindings \
            --disable-static &&
make

cat > 1434987998815.sh << "ENDOFFILE"
make install
ENDOFFILE
chmod a+x 1434987998815.sh
sudo ./1434987998815.sh
sudo rm -rf 1434987998815.sh


 
cd $SOURCE_DIR
sudo rm -rf $DIRECTORY
 
echo "telepathy-glib=>`date`" | sudo tee -a $INSTALLED_LIST