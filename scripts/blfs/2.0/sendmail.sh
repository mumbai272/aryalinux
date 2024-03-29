#!/bin/bash

set -e
set +h

export XORG_PREFIX="/usr"
export XORG_CONFIG="--prefix=$XORG_PREFIX --sysconfdir=/etc \
    --localstatedir=/var --disable-static"

. /etc/alps/alps.conf

#DEP:openldap


cd $SOURCE_DIR

wget -nc ftp://ftp.sendmail.org/pub/sendmail/sendmail.8.15.1.tar.gz


TARBALL=sendmail.8.15.1.tar.gz
DIRECTORY=`tar -tf $TARBALL | sed -e 's@/.*@@' | uniq `

tar -xf $TARBALL

cd $DIRECTORY

cat > 1434987998787.sh << "ENDOFFILE"
groupadd -g 26 smmsp                               &&
useradd -c "Sendmail Daemon" -g smmsp -d /dev/null \
        -s /bin/false -u 26 smmsp                  &&
chmod -v 1777 /var/mail                            &&
install -v -m700 -d /var/spool/mqueue
ENDOFFILE
chmod a+x 1434987998787.sh
sudo ./1434987998787.sh
sudo rm -rf 1434987998787.sh

cat >> devtools/Site/site.config.m4 << "EOF"
APPENDDEF(`confENVDEF',`-DSTARTTLS -DSASL -DLDAPMAP')
APPENDDEF(`confLIBS', `-lssl -lcrypto -lsasl2 -lldap -llber -ldb')
APPENDDEF(`confINCDIRS', `-I/usr/include/sasl')
EOF

cat >> devtools/Site/site.config.m4 << "EOF"
define(`confMANGRP',`root')
define(`confMANOWN',`root')
define(`confSBINGRP',`root')
define(`confUBINGRP',`root')
define(`confUBINOWN',`root')
EOF

sed -i 's|/usr/man/man|/usr/share/man/man|' \
    devtools/OS/Linux           &&

sed -i -r "s/^# if (DB.*)$/# if (\1) || DB_VERSION_MAJOR >= 5/" \
    include/sm/bdb.h            &&

cd sendmail                     &&
sh Build                        &&
cd ../cf/cf                     &&
cp generic-linux.mc sendmail.mc &&
sh Build sendmail.cf

cat > 1434987998787.sh << "ENDOFFILE"
install -v -d -m755 /etc/mail &&
sh Build install-cf &&

cd ../..            &&
sh Build install    &&

install -v -m644 cf/cf/{submit,sendmail}.mc /etc/mail &&
cp -v -R cf/* /etc/mail                               &&

install -v -m755 -d /usr/share/doc/sendmail-8.15.1/{cf,sendmail} &&

install -v -m644 CACerts FAQ KNOWNBUGS LICENSE PGPKEYS README RELEASE_NOTES \
        /usr/share/doc/sendmail-8.15.1 &&

install -v -m644 sendmail/{README,SECURITY,TRACEFLAGS,TUNING} \
        /usr/share/doc/sendmail-8.15.1/sendmail &&

install -v -m644 cf/README /usr/share/doc/sendmail-8.15.1/cf &&

for manpage in sendmail editmap mailstats makemap praliases smrsh
do
    install -v -m644 $manpage/$manpage.8 /usr/share/man/man8
done &&

install -v -m644 sendmail/aliases.5    /usr/share/man/man5 &&
install -v -m644 sendmail/mailq.1      /usr/share/man/man1 &&
install -v -m644 sendmail/newaliases.1 /usr/share/man/man1 &&
install -v -m644 vacation/vacation.1   /usr/share/man/man1
ENDOFFILE
chmod a+x 1434987998787.sh
sudo ./1434987998787.sh
sudo rm -rf 1434987998787.sh

cd doc/op                                       &&
sed -i 's/groff/GROFF_NO_SGR=1 groff/' Makefile &&
make op.txt op.pdf

cat > 1434987998787.sh << "ENDOFFILE"
install -v -d -m755 /usr/share/doc/sendmail-8.15.1 &&
install -v -m644 op.ps op.txt op.pdf /usr/share/doc/sendmail-8.15.1 &&
cd ../..
ENDOFFILE
chmod a+x 1434987998787.sh
sudo ./1434987998787.sh
sudo rm -rf 1434987998787.sh

cat > 1434987998787.sh << "ENDOFFILE"
echo $(hostname) > /etc/mail/local-host-names
cat > /etc/mail/aliases << "EOF"
postmaster: root
MAILER-DAEMON: root

EOF
newaliases
ENDOFFILE
chmod a+x 1434987998787.sh
sudo ./1434987998787.sh
sudo rm -rf 1434987998787.sh

cat > 1434987998787.sh << "ENDOFFILE"
cd /etc/mail &&
m4 m4/cf.m4 sendmail.mc > sendmail.cf
ENDOFFILE
chmod a+x 1434987998787.sh
sudo ./1434987998787.sh
sudo rm -rf 1434987998787.sh

cat > 1434987998787.sh << "ENDOFFILE"
wget -nc http://www.linuxfromscratch.org/blfs/downloads/systemd/blfs-systemd-units-20150210.tar.bz2 -O ../blfs-systemd-units-20150210.tar.bz2
tar -xf ../blfs-systemd-units-20150210.tar.bz2 -C .
cd blfs-systemd-units-20150210
make install-sendmail
cd ..
ENDOFFILE
chmod a+x 1434987998787.sh
sudo ./1434987998787.sh
sudo rm -rf 1434987998787.sh


 
cd $SOURCE_DIR
sudo rm -rf $DIRECTORY
 
echo "sendmail=>`date`" | sudo tee -a $INSTALLED_LIST