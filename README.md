# Home-Server
Repo will contain what i have in/on my home server (steps and docker-compose files).



## Set up home server first
1. First need to install Ubuntu Server LTS version from here: https://ubuntu.com/download/server
     - Remember to **uncheck** "Set up this drive as an LVM group" else it will partition your drive into many partitions.
     - You also need to reverse a static IP address (internal: meaning on your home network and not with your ISP or whatever) for your home server to make accessing it later on much easier (optional). Using this YT video as a reference: https://www.youtube.com/watch?v=IuRWqzfX1ik
2. Once that's done or when going through the installation process, install ***docker*** and ***docker-compose*** or check steps later down where to install docker if it was not installed during installation of ubuntu server.
3. Once installation is completed, you can then SSH into the server by opening a command prompt and typing: <br/>
   ```ssh <your-username>@<your-ip-address>```
4. Then, the first thing to do is disabling your sleep, suspend, hibernate functions on the server so it stays always on.
   - From this article: https://linux-tips.us/how-to-disable-sleep-and-hibernation-on-ubuntu-server/, run the commands:
     ```
     sudo systemctl mask sleep.target
     sudo systemctl mask suspend.target
     sudo systemctl mask hibernate.target
     sudo systemctl mask hybrid-sleep.target
     ```
   - For laptops, run this command: <br/>
     ```sudo nano /etc/systemd/logind.conf```
     Make sure to have `nano` installed first, it is a text editing application or use something else you are familiar with.<br/>
     Then, uncomment the following lines: `HandleSuspendKey`, `HandleLidSwitch`, `HandleLidSwitchDocked` and change their values to `ignore`. Save the file and exit the file.



## Setting up services
Below will be the services installation procedures for the home server.


### SMB / Samba
Following the YT tutorial mentioned above: https://www.youtube.com/watch?v=IuRWqzfX1ik <br/>
- On your server, install the SMB daemon with the following command: <br/>
```sudo apt install samba```
- Once that’s completed, you need a directory to store the files you will be sharing on the network. You may choose to create a folder in the `/home/$USER/shared` (replace $USER with your username) directory using the command: <br/>
```sudo mkdir /home/$USER/shared```
- Since this folder will likely be accessed by other utilities, like Jellyfin, it is best to give your user all permissions to avoid issues later on using the command: <br/>
```sudo chown $USER: /home/$USER/shared```
- Configuring Samba:
  - Edit it with ```sudo nano /etc/samba/smb.conf```
  - Change the line `map to guest = bad user` to `map to guest = never` <br/>
  - Add the folder you just created to the shares by adding these lines at the end of the file:
    ```
    [shared]
       path = /home/$USER/shared
       writeable=yes
       public=no
    ```
  - Save file by pressing Ctrl + X and then Y then Enter
  - Run `sudo smbpasswd -a youruser` ("youruser" needs to be replaced with your username) and set a password for samba
  - Restart Samba with : ```sudo systemctl restart smbd```
  - Next, follow the steps in this guide to setup your shared storage on Windows, Mac: https://chriskalos.notion.site/5d5ff30f9bdd4dfbb9ce68f0d914f1f6?pvs=25


 ### Domain Name + Nginx Proxy Manager / NPM : Setting up domain names instead of remembering ip address and port numbers for each service
 Official github here: https://github.com/NginxProxyManager/nginx-proxy-manager <br/>
 Following the YT tutorial mentioned above: https://www.youtube.com/watch?v=qlcVx-k-02E <br/>
 - Go to www.duckdns.org to create a completely free domain name for your homeserver
 - Next, create the docker-compose file for the NPM container (see docker-compose file in the project)
   - create a docker network first as described in npm documentation so all your docker containers can be put on the same network: ```docker network create npm```
   - see docker-compose file to see how container is put on the network created which is basically add these lines to all other docker-compose files for other services so NPM can find/access/connect to them:
     ```
     networks:
       default:
          external: true
          name: npm
     ```
 - Navigate to the folder where you create the docker-compose.yml file and run it with the command: ```docker-compose up -d```
 - After the NPM container is created, navigate to it by opening its web UI at your-homeserver-ip:81, get the default login credentials on NPM documentation or github
 - Up next, follow up the YT video tutorial to create your SSL certificate and then your first proxy host which is the NPM web UI itself


### Jellyfin : Media Player
- Just create the docker-compose.yml file and where your movies and shows folders will be located and then just run the command: `docker compose up -d` in the folder where the docker-compose.yml file is. (see docker-compose.yml file in repo)
- Then, login into NPM and create another proxy host and point it to the jellyfin container and to the port `8096`
- Access your jellyfin web UI on the domain name you created for it in NPM.
