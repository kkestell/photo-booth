# Raspberry Pi Setup Instructions

This guide assumes the following hardware:

* Raspberry Pi 3
* Nikon D610
* Canon Selphy CP1200

## Operating System Installation

Install Raspbian Lite on an SD card.

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
iface eth0 inet static
  address 10.0.0.2
  netmask 255.0.0.0

allow-hotplug wlan0
auto wlan0
iface wlan0 inet dhcp
  wpa-ssid "YOUR SSID"
  wpa-psk "YOUR PASSWORD"

dns-nameservers 8.8.8.8

iface default inet dhcp
```

## Enable Auto-Login

Edit `/lib/systemd/system/getty@.service` and change:

```
ExecStart=-/sbin/agetty --noclear %I $TERM
```

to

```
ExecStart=-/sbin/agetty --noclear -a pi %I $TERM
```

## Install Dependencies

Install the following packages:

```
$ sudo apt install autotools cups git gphoto2 libexif-dev libjpeg-dev libtool ruby ruby-dev
```

## Install `epeg`

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

## Enable SSH

Use `$ sudo raspi-config` to enable SSH.

## Configure Printer

```
$ sudo usermod -a -G lpadmin pi
$ cupsctl --remote-admin
```

Connect the printer via USB.

Visit `https://192.168.0.104:631/admin/` in your browser (replacing the IP as necessary) and click "Add Printer". You should see the Selphy listed under Local Printers as "Canon SELPHY CP1200 (Canon SELPHY CP1200)". Select it and click Continue.

On the following screen, accept the default options and press Continue again.

On the following screen, select the "Canon SELPHY DS910 - CUPS+Gutenprint v5.2.11 (en)" model. This isn't quite right, but the version of Cups that ships with Raspbian doesn't seem to have a driver for the CP1200. This is close enough and seems to work fine, however. Click Add Printer.

On the final screen, default options, set Borderless to Yes and click Set Default Options.

## Install

```
$ cd ~/
$ git clone https://github.com/kkestell/photo-booth.git
$ cd photo-booth
$ bundle install
```

## Configure Services

```
$ sudo nano /lib/systemd/system/photo-booth-server.service
```

```
[Unit]
Description=Photo Booth Server
After=multi-user.target

[Service]
Type=idle
ExecStart=/usr/bin/ruby /home/pi/photo-booth/server.rb > /home/pi/photo-booth/logs/server.log 2>&1

[Install]
WantedBy=multi-user.target
```

```
$ sudo nano /lib/systemd/system/photo-booth-preview-stream.service
```

```
[Unit]
Description=Photo Booth Preview Stream
After=multi-user.target

[Service]
Type=idle
ExecStart=/bin/sh /home/pi/photo-booth/preview.sh > /home/pi/photo-booth/logs/preview.log 2>&1

[Install]
WantedBy=multi-user.target
```

```
$ sudo chmod 644 /lib/systemd/system/photo-booth-server.service
$ sudo chmod 644 /lib/systemd/system/photo-booth-preview-stream.service
$ sudo systemctl daemon-reload
$ sudo systemctl enable photo-booth-server.service
$ sudo systemctl enable photo-booth-preview-stream.service
$ sudo reboot
```

### Starting, Stopping, and Restarting Services

```
$ sudo systemctl [start|stop|restart] [photo-booth-server|photo-booth-preview-stream]
```