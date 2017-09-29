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
$ sudo apt install autotools cups git gphoto2 gstreamer1.0-tools libexif-dev libjpeg-dev libtool ruby ruby-dev
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
$ bundle install
```

## Configure Services

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
ExecStart=/usr/bin/ruby /home/pi/photo-booth/server.rb > /home/pi/photo-booth/logs/server.log 2>&1

[Install]
WantedBy=multi-user.target
```

Set permissions:

```
$ sudo chmod 644 /lib/systemd/system/photo-booth-server.service
```

### Preview Stream

Create a new systemd service:

```
$ sudo nano /lib/systemd/system/photo-booth-preview-stream.service
```

And add the following:

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

Set permissions:

```
$ sudo chmod 644 /lib/systemd/system/photo-booth-preview-stream.service
```

### Register, Enable, and Start New Services

```
$ sudo systemctl daemon-reload
$ sudo systemctl enable photo-booth-server
$ sudo systemctl enable photo-booth-preview-stream
$ sudo systemctl start photo-booth-server
$ sudo systemctl start photo-preview-stream
```

#### Starting, Stopping, and Restarting Services

```
$ sudo systemctl [start|stop|restart] [photo-booth-server|photo-booth-preview-stream]
```