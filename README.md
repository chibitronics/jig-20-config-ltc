Service file:

 [Unit]
 Description=Launcher for Jig-20
 
 [Service]
 Type=simple
 ExecStart=/usr/bin/cargo run -- -c /home/pi/Code/jig-20-config-ltc/
 User=root
 WorkingDirectory=/home/pi/Code/jig-20
 
 [Install]
 WantedBy=getty.target
