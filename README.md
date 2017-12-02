Factory Test Configuration for Love-to-Code Chibi Chip
======================================================

This configuration directory describes the factory test procedure used
by the Love-to-Code Chibi Chip.  It is a configuration directory designed
to be used with Exclave (nee. Jig-20).

Usage
-----

To run, specify this directory by passing "-c" to exclave.  For example:

    exclave -c /mnt/disk/jig-20-config-ltc

Exclave via systemd
-------------------

You can set up a systemd service to run exclave.  It might look like:

    [Unit]
    Description=Launcher for Jig-20
     
    [Service]
    Type=simple
    ExecStart=/usr/bin/cargo run -- -c /home/pi/Code/jig-20-config-ltc/
    User=root
    WorkingDirectory=/home/pi/Code/jig-20
     
    [Install]
    WantedBy=getty.target

Recompiling
-----------

The repo ships with precompiled binaries, but includes a Makefile to
rebuild them for you:

    make

If you're cross-compiling, specify the toolchain prefix in the CROSS\_COMPILE
variable:

    make CROSS\_COMPILE=arm-linux-gnueabihf-
