#!/bin/sh

raspivid -o - -t 0 -n -w 640 -h 480 -fps 30 | gst-launch-1.0 -v fdsrc ! h264parse ! rtph264pay config-interval=10 pt=96 ! udpsink host=10.0.0.100 port=5006
