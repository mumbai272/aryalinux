#!/bin/bash

set -e
set +h

export XORG_PREFIX="/usr"
export XORG_CONFIG="--prefix=$XORG_PREFIX --sysconfdir=/etc \
    --localstatedir=/var --disable-static"

. /etc/alps/alps.conf

#DEP:itstool
#DEP:libgcrypt


cd $SOURCE_DIR

wget -nc https://launchpad.net/lightdm/1.8/1.8.5/+download/lightdm-1.8.5.tar.xz
wget -nc https://launchpad.net/lightdm-gtk-greeter/1.8/1.8.5/+download/lightdm-gtk-greeter-1.8.5.tar.gz


TARBALL=lightdm-1.8.5.tar.xz
DIRECTORY=lightdm-1.8.5

tar -xf $TARBALL

cd $DIRECTORY

export MOC4=moc-qt4

CFLAGS="-march=native -mtune=native -O3"   \
CXXFLAGS="-march=native -mtune=native -O3" \
CPPLAGS="-march=native -mtune=native -O3"  \
./configure --prefix=/usr \
            --sysconfdir=/etc \
            --localstatedir=/var \
            --libexecdir=/usr/lib \
            --with-greeter-user=lightdm \
            --with-greeter-session=lightdm-gtk-greeter \
            --disable-static \
            --disable-tests

make "-j`nproc`"

cat > 1434987998845.sh << "ENDOFFILE"
make install
ENDOFFILE
chmod a+x 1434987998845.sh
sudo ./1434987998845.sh
sudo rm -rf 1434987998845.sh

cat > 1434987998845.sh << "ENDOFFILE"
rm -rf /etc/apparmor.d /etc/init
install -dm770 /var/lib/lightdm
install -dm711 /var/log/lightdm

chmod +t /var/lib/lightdm

echo "GDK_CORE_DEVICE_EVENTS=true" > /var/lib/lightdm/.pam_environment

chmod 644 /var/lib/lightdm/.pam_environment

install -dm755 /etc/lightdm

ENDOFFILE
chmod a+x 1434987998845.sh
sudo ./1434987998845.sh
sudo rm -rf 1434987998845.sh

cat > 1434987998845.sh << "ENDOFFILE"
cat > /etc/lightdm/lightdm.conf << "EOF"
#
# General configuration
#
# start-default-seat = True to always start one seat if none are defined in the configuration
# greeter-user = User to run greeter as
# minimum-display-number = Minimum display number to use for X servers
# minimum-vt = First VT to run displays on
# lock-memory = True to prevent memory from being paged to disk
# user-authority-in-system-dir = True if session authority should be in the system location
# guest-account-script = Script to be run to setup guest account
# log-directory = Directory to log information to
# run-directory = Directory to put running state in
# cache-directory = Directory to cache to
# sessions-directory = Directory to find sessions
# remote-sessions-directory = Directory to find remote sessions
# greeters-directory = Directory to find greeters
#
[LightDM]
#start-default-seat=true
greeter-user=lightdm
#minimum-display-number=0
minimum-vt=1
#lock-memory=true
#user-authority-in-system-dir=false
#guest-account-script=guest-account
log-directory=/var/log/lightdm
run-directory=/run/lightdm
#cache-directory=/var/cache/lightdm
#sessions-directory=/usr/share/lightdm/sessions:/usr/share/xsessions
#remote-sessions-directory=/usr/share/lightdm/remote-sessions
#greeters-directory=/usr/share/lightdm/greeters:/usr/share/xgreeters

#
# Seat defaults
#
# type = Seat type (xlocal, xremote)
# xdg-seat = Seat name to set pam_systemd XDG_SEAT variable and name to pass to X server
# xserver-command = X server command to run (can also contain arguments e.g. X -special-option)
# xserver-layout = Layout to pass to X server
# xserver-config = Config file to pass to X server
# xserver-allow-tcp = True if TCP/IP connections are allowed to this X server
# xserver-share = True if the X server is shared for both greeter and session
# xserver-hostname = Hostname of X server (only for type=xremote)
# xserver-display-number = Display number of X server (only for type=xremote)
# xdmcp-manager = XDMCP manager to connect to (implies xserver-allow-tcp=true)
# xdmcp-port = XDMCP UDP/IP port to communicate on
# xdmcp-key = Authentication key to use for XDM-AUTHENTICATION-1 (stored in keys.conf)
# unity-compositor-command = Unity compositor command to run (can also contain arguments e.g. unity-system-compositor -special-option)
# unity-compositor-timeout = Number of seconds to wait for compositor to start
# greeter-session = Session to load for greeter
# greeter-hide-users = True to hide the user list
# greeter-allow-guest = True if the greeter should show a guest login option
# greeter-show-manual-login = True if the greeter should offer a manual login option
# greeter-show-remote-login = True if the greeter should offer a remote login option
# user-session = Session to load for users
# allow-guest = True if guest login is allowed
# guest-session = Session to load for guests (overrides user-session)
# session-wrapper = Wrapper script to run session with
# greeter-wrapper = Wrapper script to run greeter with
# guest-wrapper = Wrapper script to run guest sessions with
# display-setup-script = Script to run when starting a greeter session (runs as root)
# greeter-setup-script = Script to run when starting a greeter (runs as root)
# session-setup-script = Script to run when starting a user session (runs as root)
# session-cleanup-script = Script to run when quitting a user session (runs as root)
# autologin-guest = True to log in as guest by default
# autologin-user = User to log in with by default (overrides autologin-guest)
# autologin-user-timeout = Number of seconds to wait before loading default user
# autologin-session = Session to load for automatic login (overrides user-session)
# autologin-in-background = True if autologin session should not be immediately activated
# exit-on-failure = True if the daemon should exit if this seat fails
#
[SeatDefaults]
#type=xlocal
#xdg-seat=seat0
#xserver-command=X
#xserver-layout=
#xserver-config=
#xserver-allow-tcp=false
#xserver-share=true
#xserver-hostname=
#xserver-display-number=
#xdmcp-manager=
#xdmcp-port=177
#xdmcp-key=
#unity-compositor-command=unity-system-compositor
#unity-compositor-timeout=60
greeter-session=lightdm-gtk-greeter
#greeter-hide-users=false
#greeter-allow-guest=true
#greeter-show-manual-login=false
#greeter-show-remote-login=true
#user-session=default
#allow-guest=true
#guest-session=UNIMPLEMENTED
session-wrapper=/etc/lightdm/Xsession
#greeter-wrapper=
#guest-wrapper=
#display-setup-script=
#greeter-setup-script=
#session-setup-script=
#session-cleanup-script=
#autologin-guest=false
#autologin-user=
#autologin-user-timeout=0
#autologin-in-background=false
#autologin-session=UNIMPLEMENTED
pam-service=lightdm-autologin
#exit-on-failure=false

#
# Seat configuration
#
# Each seat must start with "Seat:".
# Uses settings from [SeatDefaults], any of these can be overriden by setting them in this section.
#
#[Seat:0]

#
# XDMCP Server configuration
#
# enabled = True if XDMCP connections should be allowed
# port = UDP/IP port to listen for connections on
# key = Authentication key to use for XDM-AUTHENTICATION-1 or blank to not use authentication (stored in keys.conf)
#
# The authentication key is a 56 bit DES key specified in hex as 0xnnnnnnnnnnnnnn.  Alternatively
# it can be a word and the first 7 characters are used as the key.
#
[XDMCPServer]
#enabled=false
#port=177
#key=

#
# VNC Server configuration
#
# enabled = True if VNC connections should be allowed
# command = Command to run Xvnc server with
# port = TCP/IP port to listen for connections on
# width = Width of display to use
# height = Height of display to use
# depth = Color depth of display to use
#
[VNCServer]
#enabled=false
#command=Xvnc
#port=5900
#width=1024
#height=768
#depth=8
EOF
ENDOFFILE
chmod a+x 1434987998845.sh
sudo ./1434987998845.sh
sudo rm -rf 1434987998845.sh

cat > 1434987998845.sh << "ENDOFFILE"
cat > /etc/lightdm/users.conf << "EOF"
#
# User accounts configuration
#
# NOTE: If you have AccountsService installed on your system, then LightDM will
# use this instead and these settings will be ignored
#
# minimum-uid = Minimum UID required to be shown in greeter
# hidden-users = Users that are not shown to the user
# hidden-shells = Shells that indicate a user cannot login
#
[UserAccounts]
minimum-uid=1000
hidden-users=nobody nobody4 noaccess
hidden-shells=/bin/false /sbin/nologin
EOF

cat > ${DEST}/etc/lightdm/Xsession << "EOF"
#!/bin/sh
#
# LightDM wrapper to run around X sessions.

echo "Running X session wrapper"

# Load profile
for file in "/etc/profile" "$HOME/.profile" "/etc/xprofile" "$HOME/.xprofile"; do
    if [ -f "$file" ]; then
        echo "Loading profile from $file";
        . "$file"
    fi
done

# Load resources
for file in "/etc/X11/Xresources" "$HOME/.Xresources"; do
    if [ -f "$file" ]; then
        echo "Loading resource: $file"
        xrdb -nocpp -merge "$file"
    fi
done

# Load keymaps
for file in "/etc/X11/Xkbmap" "$HOME/.Xkbmap"; do
    if [ -f "$file" ]; then
        echo "Loading keymap: $file"
        setxkbmap `cat "$file"`
        XKB_IN_USE=yes
    fi
done

# Load xmodmap if not using XKB
if [ -z "$XKB_IN_USE" ]; then
    for file in "/etc/X11/Xmodmap" "$HOME/.Xmodmap"; do
        if [ -f "$file" ]; then
           echo "Loading modmap: $file"
           xmodmap "$file"
        fi
    done
fi

unset XKB_IN_USE

# Run all system xinitrc shell scripts.
xinitdir="/etc/X11/xinit/xinitrc.d"
if [ -d "$xinitdir" ]; then
    for script in $xinitdir/*; do
        echo "Loading xinit script $script"
        if [ -x "$script" -a ! -d "$script" ]; then
            . "$script"
        fi
    done
fi

echo "X session wrapper complete, running session $@"

exec $@
EOF

ENDOFFILE
chmod a+x 1434987998845.sh
sudo ./1434987998845.sh
sudo rm -rf 1434987998845.sh

cat > 1434987998845.sh << "ENDOFFILE"
chmod 755 /etc/lightdm/Xsession

install -dm755 /etc/pam.d

cat > /etc/pam.d/lightdm << "EOF"
# Begin /etc/pam.d/lightdm

auth     requisite      pam_nologin.so
auth     required       pam_env.so

auth     required       pam_succeed_if.so uid >= 1000 quiet
auth     include        system-auth
auth     optional       pam_gnome_keyring.so

account  include        system-account
password include        system-password

session  required       pam_limits.so
session  include        system-session
session  optional       pam_gnome_keyring.so auto_start

# End /etc/pam.d/lightdm
EOF

cat > /etc/pam.d/lightdm-autologin << "EOF"
# Begin /etc/pam.d/lightdm-autologin

auth     requisite      pam_nologin.so
auth     required       pam_env.so

auth     required       pam_succeed_if.so uid >= 1000 quiet
auth     required       pam_permit.so

account  include        system-account

password required       pam_deny.so

session  required       pam_limits.so
session  include        system-session

# End /etc/pam.d/lightdm-autologin
EOF

cat > /etc/pam.d/lightdm-greeter << "EOF"
# Begin /etc/pam.d/lightdm-greeter

auth     required       pam_env.so
auth     required       pam_permit.so

account  required       pam_permit.so
password required       pam_deny.so
session  required       pam_unix.so

# End /etc/pam.d/lightdm-greeter
EOF
ENDOFFILE
chmod a+x 1434987998845.sh
sudo ./1434987998845.sh
sudo rm -rf 1434987998845.sh

cat > 1434987998845.sh << "ENDOFFILE"
install -dm700 /usr/share/polkit-1/rules.d

cat > /usr/share/polkit-1/rules.d/lightdm.rules << "EOF"
polkit.addRule(function(action, subject) {
    if (subject.user == "lightdm") {
        polkit.log("action=" + action);
        polkit.log("subject=" + subject);
        if (action.id.indexOf("org.freedesktop.login1.") == 0) {
            return polkit.Result.YES;
        }
        if (action.id.indexOf("org.freedesktop.consolekit.system.") == 0) {
            return polkit.Result.YES;
        }
        if (action.id.indexOf("org.freedesktop.upower.") == 0) {
            return polkit.Result.YES;
        }
    }
});
EOF

chmod 600 /usr/share/polkit-1/rules.d/lightdm.rules

install -dm755 /etc/tmpfiles.d /lib/systemd/system

cat > /etc/tmpfiles.d/lightdm.conf << "EOF"
d /run/lightdm 0711 lightdm lightdm
EOF

cat > /lib/systemd/system/lightdm.service << "EOF"
[Unit]
Description=Light Display Manager
Documentation=man:lightdm(1)
Conflicts=getty at tty1.service
After=systemd-user-sessions.service getty at tty1.service plymouth-quit.service

[Service]
ExecStart=/usr/sbin/lightdm
Restart=always
IgnoreSIGPIPE=no
BusName=org.freedesktop.DisplayManager

[Install]
Alias=display-manager.service
EOF

ENDOFFILE
chmod a+x 1434987998845.sh
sudo ./1434987998845.sh
sudo rm -rf 1434987998845.sh

cat > 1434987998845.sh << "ENDOFFILE"
getent group lightdm > /dev/null || groupadd -g 63 lightdm
getent passwd lightdm > /dev/null || useradd -c "Light Display Manager" -u 63 -g lightdm -d /var/lib/lightdm -s /sbin/nologin lightdm

chown -R lightdm:lightdm /var/lib/lightdm /var/log/lightdm

chmod 700 /usr/share/polkit-1/rules.d
chmod 600 /usr/share/polkit-1/rules.d/*
chown -R polkitd:polkitd /usr/share/polkit-1/rules.d

ENDOFFILE
chmod a+x 1434987998845.sh
sudo ./1434987998845.sh
sudo rm -rf 1434987998845.sh


 
cd $SOURCE_DIR
sudo rm -rf $DIRECTORY
 
echo "lightdm=>`date`" | sudo tee -a $INSTALLED_LIST