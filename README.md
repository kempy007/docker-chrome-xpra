Docker! Chrome! mitmproxy! wee bit of memory!
=============================================

Run Google Chrome inside an isolated [Docker](http://www.docker.io) container
on your Linux desktop with a wee bit of RAM, useful for developing hybrid
mobile apps.  Get Chrome Developer Tools with the memory constraints of an
iPad.  Use mitmproxy to help debug.


Instructions
============

1. [Install Docker](http://docs.docker.io/en/latest/installation/) if you haven't already

        sudo apt-get install docker.io

2. [Install mitmproxy](http://mitmproxy.org/doc/install.html)

        sudo apt-get install mitmproxy

3. Clone this repository

        git clone https://github.com/cwarden/docker-chrome.git && cd docker-chrome

4. Copy your SSH public key into place

        cp ~/.ssh/id_rsa.pub authorized_keys

5. Copy your mitmproxy CA cert into place

        cp ~/.mitmproxy/mitmproxy-ca-cert.pem .

6. Build the container

        sudo docker.io build -t chrome .

7. Create an entry in your .ssh/config file for easy access. It should look like this:
        
        Host docker-chrome
          User      chrome
          Port      2223
          HostName  127.0.0.1
          # mitmproxy
          RemoteForward 8899 localhost:8899
          # local web server
          RemoteForward 8000 localhost:8000
          ForwardX11 yes

8. Run the container with a wee bit of RAM and forward the ssh port

        sudo docker.io run -d -p 127.0.0.1:2223:22 -m 256m chrome

9. Start mitmproxy

        mitmproxy -p 8899

10. Connect via SSH and launch Chrome using the provided wrapper script

        ssh docker-chrome chrome-sandbox http://localhost:8000/


Frequently Asked Questions
==========================

Why would I want to do this?
----------------------------
So you can crash your browser when you use too much RAM, just like when you run
your bad code in a [Cordova](http://cordova.apache.org/) app on an iPad.

Why do you disable Chrome's sandbox using the `--no-sandbox` flag?
------------------------------------------------------------------
Chrome does a bunch of crazy stuff using SUID wrappers and several other techniques to try to keep Flash under control and to enhance its own internal security. Unfortunately, these techniques don't work inside a Docker container unless the container is run with the `-privileged` flag. So what's the problem with that? Well, here's what [Docker's documentation](http://docs.docker.io/en/latest/commandline/cli/#run) has to say about it: 

> The -privileged flag gives all capabilities to the container, and it also lifts all the limitations enforced by the device cgroup controller. In other words, the container can then do almost everything that the host can do. This flag exists to allow special use-cases, like running Docker within Docker.

It sounds like a decidedly awful idea to give Chrome and Flash the ability to do "almost everything that the host can do." And even though it makes my inner [Xzibit](http://knowyourmeme.com/memes/xzibit-yo-dawg) very sad, we are not running Docker inside of Docker. If you disagree with this choice, feel free to run the container with Docker's `-privileged` flag enabled and to strip the `--no-sandbox` flag from the launch wrapper in the Dockerfile. This will remove the "You are using an unsupported command-line flag..." warning that otherwise appears every time you start Chrome.


Author Information
==================

Based on [docker-chrome-pulseaudio](https://github.com/jlund/docker-chrome-pulseaudio) from Joshua Lund.

Updated by [Christian G. Warden](http://xn.pinkhamster.net).
