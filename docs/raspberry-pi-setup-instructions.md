# Raspberry Pi Setup Instructions

This guide assumes the following hardware:

* Raspberry Pi 3
* Nikon D610
* Canon Selphy CP1200

## Operating System Installation

Install Raspbian Lite on an SD card. You'll want to have your Pi plugged into a keyboard, monitor, and ethernet.

Boot from the SD card and log in as `pi` / `raspberry`.

## Network Configuration

```
$ sudo nano /etc/network/interfaces
```

```
source-directory /etc/network/interfaces.d

auto lo

iface lo inet loopback

auto eth0
iface eth0 inet dhcp

auto wlan0
iface wlan0 inet static
  address 10.0.0.1
  netmask 255.0.0.0
```

### Configure HostAPD

Create `/etc/hostapd/hostapd.conf` with the following contents:

```
interface=wlan0
driver=nl80211
ssid=Photo Booth
hw_mode=n
channel=6
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=00000000
wpa_key_mgmt=WPA-PSK
rsn_pairwise=CCMP
ieee80211n=1
wmm_enabled=1
ht_capab=[HT40][SHORT-GI-20][DSSS_CCK-40]
```

Edit the file `/etc/default/hostapd` and change the line:

```
#DAEMON_CONF=""
```

to

```
DAEMON_CONF="/etc/hostapd/hostapd.conf"
```

Finally, start HostAPD and configure it to start on boot:

```
$ sudo service hostapd start
$ sudo update-rc.d hostapd enable
```

## Enable SSH and Raspberry Pi Camera

Use `$ sudo raspi-config` to enable SSH and the Raspberry Pi camera.

## Reboot and Connect via SSH

You should now be able to reboot your Raspberry Pi and log in via SSH, e.g.

```
$ ssh pi@10.0.0.2
```

You should be able to perform the rest of this setup process via SSH.

## Install Dependencies

Install the following packages:

```
$ sudo apt install autotools cups git gphoto2 gstreamer1.0-tools hostapd libexif-dev libjpeg-dev libtool ruby ruby-dev
```

### Compile and Install `epeg`

```
$ cd ~/
$ sudo apt install
$ git clone https://github.com/mattes/epeg.git
$ cd epeg
$ sh autogen.sh
$ make
$ sudo make install
$ ldconfig
```

## Configure Printer

```
$ sudo usermod -a -G lpadmin pi
$ cupsctl --remote-admin
```

Connect the printer via USB.

Visit `https://10.0.0.2:631/admin/` in your browser (replacing the IP as necessary) and click "Add Printer". You should see the Selphy listed under Local Printers as "Canon SELPHY CP1200 (Canon SELPHY CP1200)". Select it and click Continue.

On the following screen, accept the default options and press Continue again.

On the following screen, select the "Canon SELPHY DS910 - CUPS+Gutenprint v5.2.11 (en)" model. This isn't quite right, but the version of Cups that ships with Raspbian doesn't seem to have a driver for the CP1200. This is close enough and seems to work fine, however. Click Add Printer.

On the final screen, default options, set Borderless to Yes and click Set Default Options.

## Install Photo Booth Software

```
$ cd ~/
$ git clone https://github.com/kkestell/photo-booth.git
$ cd photo-booth
$ gem install bundler
$ bundle install
```

## Configure Service

### Server

Create a new systemd service:

```
$ sudo nano /lib/systemd/system/photo-booth-server.service
```

And add the following:

```
[Unit]
Description=Photo Booth Server
After=multi-user.target

[Service]
Type=idle
ExecStart=/usr/bin/ruby /home/pi/photo-booth/server.rb > /home/pi/photo-booth/logs/server.log

[Install]
WantedBy=multi-user.target
```

Set permissions:

```
$ sudo chmod 644 /lib/systemd/system/photo-booth-server.service
```

### Register, Enable, and Start Service

```
$ sudo systemctl daemon-reload
$ sudo systemctl enable photo-booth-server
$ sudo systemctl start photo-booth-server
```

#### Starting, Stopping, and Restarting Services

```
$ sudo systemctl start photo-booth-server
$ sudo systemctl stop photo-booth-server
$ sudo systemctl restart photo-booth-server
```