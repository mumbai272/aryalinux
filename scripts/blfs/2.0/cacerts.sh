#!/bin/bash

set -e
set +h

export XORG_PREFIX="/usr"
export XORG_CONFIG="--prefix=$XORG_PREFIX --sysconfdir=/etc \
    --localstatedir=/var --disable-static"

. /etc/alps/alps.conf

#DEP:openssl
#DEP:wget


cd $SOURCE_DIR






cat > 1434987998745.sh << "ENDOFFILE"
cat > /usr/bin/make-cert.pl << "EOF"
#!/usr/bin/perl -w

# Used to generate PEM encoded files from Mozilla certdata.txt.
# Run as ./make-cert.pl > certificate.crt
#
# Parts of this script courtesy of RedHat (mkcabundle.pl)
#
# This script modified for use with single file data (tempfile.cer) extracted
# from certdata.txt, taken from the latest version in the Mozilla NSS source.
# mozilla/security/nss/lib/ckfw/builtins/certdata.txt
#
# Authors: DJ Lucas
# Bruce Dubbs
#
# Version 20120211

my $certdata = './tempfile.cer';

open( IN, "cat $certdata|" )
 || die "could not open $certdata";

my $incert = 0;

while ( <IN> )
{
 if ( /^CKA_VALUE MULTILINE_OCTAL/ )
 {
 $incert = 1;
 open( OUT, "|openssl x509 -text -inform DER -fingerprint" )
 || die "could not pipe to openssl x509";
 }

 elsif ( /^END/ && $incert )
 {
 close( OUT );
 $incert = 0;
 print "\n\n";
 }

 elsif ($incert)
 {
 my @bs = split( /\\/ );
 foreach my $b (@bs)
 {
 chomp $b;
 printf( OUT "%c", oct($b) ) unless $b eq '';
 }
 }
}
EOF

chmod +x /usr/bin/make-cert.pl
ENDOFFILE
chmod a+x 1434987998745.sh
sudo ./1434987998745.sh
sudo rm -rf 1434987998745.sh

cat > 1434987998745.sh << "ENDOFFILE"
cat > /usr/bin/make-ca.sh << "EOF"
#!/bin/sh
# Begin make-ca.sh
# Script to populate OpenSSL's CApath from a bundle of PEM formatted CAs
#
# The file certdata.txt must exist in the local directory
# Version number is obtained from the version of the data.
#
# Authors: DJ Lucas
# Bruce Dubbs
#
# Version 20120211

certdata="certdata.txt"

if [ ! -r $certdata ]; then
 echo "$certdata must be in the local directory"
 exit 1
fi

REVISION=$(grep CVS_ID $certdata | cut -f4 -d'$')

if [ -z "${REVISION}" ]; then
 echo "$certfile has no 'Revision' in CVS_ID"
 exit 1
fi

VERSION=$(echo $REVISION | cut -f2 -d" ")

TEMPDIR=$(mktemp -d)
TRUSTATTRIBUTES="CKA_TRUST_SERVER_AUTH"
BUNDLE="BLFS-ca-bundle-${VERSION}.crt"
CONVERTSCRIPT="/usr/bin/make-cert.pl"
SSLDIR="/etc/ssl"

mkdir "${TEMPDIR}/certs"

# Get a list of starting lines for each cert
CERTBEGINLIST=$(grep -n "^# Certificate" "${certdata}" | cut -d ":" -f1)

# Get a list of ending lines for each cert
CERTENDLIST=`grep -n "^CKA_TRUST_STEP_UP_APPROVED" "${certdata}" | cut -d ":" -f 1`

# Start a loop
for certbegin in ${CERTBEGINLIST}; do
 for certend in ${CERTENDLIST}; do
 if test "${certend}" -gt "${certbegin}"; then
 break
 fi
 done

 # Dump to a temp file with the name of the file as the beginning line number
 sed -n "${certbegin},${certend}p" "${certdata}" > "${TEMPDIR}/certs/${certbegin}.tmp"
done

unset CERTBEGINLIST CERTDATA CERTENDLIST certbegin certend

mkdir -p certs
rm -f certs/* # Make sure the directory is clean

for tempfile in ${TEMPDIR}/certs/*.tmp; do
 # Make sure that the cert is trusted...
 grep "CKA_TRUST_SERVER_AUTH" "${tempfile}" | \
 egrep "TRUST_UNKNOWN|NOT_TRUSTED" > /dev/null

 if test "${?}" = "0"; then
 # Throw a meaningful error and remove the file
 cp "${tempfile}" tempfile.cer
 perl ${CONVERTSCRIPT} > tempfile.crt
 keyhash=$(openssl x509 -noout -in tempfile.crt -hash)
 echo "Certificate ${keyhash} is not trusted! Removing..."
 rm -f tempfile.cer tempfile.crt "${tempfile}"
 continue
 fi

 # If execution made it to here in the loop, the temp cert is trusted
 # Find the cert data and generate a cert file for it

 cp "${tempfile}" tempfile.cer
 perl ${CONVERTSCRIPT} > tempfile.crt
 keyhash=$(openssl x509 -noout -in tempfile.crt -hash)
 mv tempfile.crt "certs/${keyhash}.pem"
 rm -f tempfile.cer "${tempfile}"
 echo "Created ${keyhash}.pem"
done

# Remove blacklisted files
# MD5 Collision Proof of Concept CA
if test -f certs/8f111d69.pem; then
 echo "Certificate 8f111d69 is not trusted! Removing..."
 rm -f certs/8f111d69.pem
fi

# Finally, generate the bundle and clean up.
cat certs/*.pem > ${BUNDLE}
rm -r "${TEMPDIR}"
EOF

chmod +x /usr/bin/make-ca.sh
ENDOFFILE
chmod a+x 1434987998745.sh
sudo ./1434987998745.sh
sudo rm -rf 1434987998745.sh

cat > 1434987998745.sh << "ENDOFFILE"
cat > /usr/bin/remove-expired-certs.sh << "EOF"
#!/bin/sh
# Begin /usr/bin/remove-expired-certs.sh
#
# Version 20120211

# Make sure the date is parsed correctly on all systems
mydate()
{
 local y=$( echo $1 | cut -d" " -f4 )
 local M=$( echo $1 | cut -d" " -f1 )
 local d=$( echo $1 | cut -d" " -f2 )
 local m

 if [ ${d} -lt 10 ]; then d="0${d}"; fi

 case $M in
 Jan) m="01";;
 Feb) m="02";;
 Mar) m="03";;
 Apr) m="04";;
 May) m="05";;
 Jun) m="06";;
 Jul) m="07";;
 Aug) m="08";;
 Sep) m="09";;
 Oct) m="10";;
 Nov) m="11";;
 Dec) m="12";;
 esac

 certdate="${y}${m}${d}"
}

OPENSSL=/usr/bin/openssl
DIR=/etc/ssl/certs

if [ $# -gt 0 ]; then
 DIR="$1"
fi

certs=$( find ${DIR} -type f -name "*.pem" -o -name "*.crt" )
today=$( date +%Y%m%d )

for cert in $certs; do
 notafter=$( $OPENSSL x509 -enddate -in "${cert}" -noout )
 date=$( echo ${notafter} | sed 's/^notAfter=//' )
 mydate "$date"

 if [ ${certdate} -lt ${today} ]; then
 echo "${cert} expired on ${certdate}! Removing..."
 rm -f "${cert}"
 fi
done
EOF

chmod +x /usr/bin/remove-expired-certs.sh
ENDOFFILE
chmod a+x 1434987998745.sh
sudo ./1434987998745.sh
sudo rm -rf 1434987998745.sh

# cd $SOURCE_DIR

URL=http://anduin.linuxfromscratch.org/sources/other/certdata.txt &&
# rm -f certdata.txt &&
wget -nc $URL          &&
make-ca.sh         &&
remove-expired-certs.sh certs &&
unset URL

cat > 1434987998745.sh << "ENDOFFILE"
SSLDIR=/etc/ssl                                              &&
install -d ${SSLDIR}/certs                                   &&
cp -v certs/*.pem ${SSLDIR}/certs                            &&
c_rehash                                                     &&
install BLFS-ca-bundle*.crt ${SSLDIR}/ca-bundle.crt          &&
ln -sfv ../ca-bundle.crt ${SSLDIR}/certs/ca-certificates.crt &&
unset SSLDIR
ENDOFFILE
chmod a+x 1434987998745.sh
sudo ./1434987998745.sh
sudo rm -rf 1434987998745.sh

rm -rfv certs BLFS-ca-bundle*


 
cd $SOURCE_DIR
 
echo "cacerts=>`date`" | sudo tee -a $INSTALLED_LIST
