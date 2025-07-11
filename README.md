# Home-Server
Repo will contain what i have in/on my home server (steps and docker-compose files).



## Set up home server first
1. First need to install Ubuntu Server LTS version from here: https://ubuntu.com/download/server
     - Remember to **uncheck** "Set up this drive as an LVM group" else it will partition your drive into many partitions.
     - You also need to reverse a static IP address (internal: meaning on your home network and not with your ISP or whatever) for your home server to make accessing it later on much easier (optional). Using this YT video as a reference: https://www.youtube.com/watch?v=IuRWqzfX1ik
2. Once that's done or when going through the installation process, install ***docker*** and ***docker-compose*** or check steps later down where to install docker if it was not installed during installation of ubuntu server.
3. Once installation is completed, you can then SSH into the server by opening a command prompt and typing:<br/>
   `ssh <your-username>@<your-ip-address>`
4. Then, the first thing to do is disabling your sleep, suspend, hibernate functions on the server so it stays always on.
   - From this article: https://linux-tips.us/how-to-disable-sleep-and-hibernation-on-ubuntu-server/, run the commands:<br/>
     `sudo systemctl mask sleep.target`<br/>
     `sudo systemctl mask suspend.target`<br/>
     `sudo systemctl mask hibernate.target`<br/>
     `sudo systemctl mask hybrid-sleep.target`<br/>
   - For laptops, run this command:<br/>
     `sudo nano /etc/systemd/logind.conf` Make sure to have `nano` installed first, it is a text editing application or use something else you are familiar with.<br/>
     Then, uncomment the following lines: `HandleSuspendKey`, `HandleLidSwitch`, `HandleLidSwitchDocked` and change their values to `ignore`. Save the file and exit the file.



## Setting up services
