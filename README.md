Docker! Chrome! Xpra!
=============================================

Run Google Chrome inside an isolated [Docker](http://www.docker.io) container
on your Linux desktop.

Instructions
============

1. [Install Docker](http://docs.docker.io/en/latest/installation/) if you haven't already

        sudo apt-get install docker.io

2. [Install xpra](https://www.xpra.org/)

        sudo apt-get install xpra

3. Clone this repository

        git clone https://github.com/cwarden/docker-chrome-xpra.git && cd docker-chrome-xpra

4. Build the container

        sudo docker.io build -t chrome .

5. Run the container and forward the xpra port

        sudo docker.io run -d -p 127.0.0.1:9000:9000 chrome

6. Connect via xpra

        xpra attach tcp:localhost:9000


Frequently Asked Questions
==========================

Why do you disable Chrome's sandbox using the `--no-sandbox` flag?
------------------------------------------------------------------
Chrome does a bunch of crazy stuff using SUID wrappers and several other techniques to try to keep Flash under control and to enhance its own internal security. Unfortunately, these techniques don't work inside a Docker container unless the container is run with the `-privileged` flag. So what's the problem with that? Well, here's what [Docker's documentation](http://docs.docker.io/en/latest/commandline/cli/#run) has to say about it: 

> The -privileged flag gives all capabilities to the container, and it also lifts all the limitations enforced by the device cgroup controller. In other words, the container can then do almost everything that the host can do. This flag exists to allow special use-cases, like running Docker within Docker.

It sounds like a decidedly awful idea to give Chrome and Flash the ability to do "almost everything that the host can do." And even though it makes my inner [Xzibit](http://knowyourmeme.com/memes/xzibit-yo-dawg) very sad, we are not running Docker inside of Docker. If you disagree with this choice, feel free to run the container with Docker's `-privileged` flag enabled and to strip the `--no-sandbox` flag from the launch wrapper in the Dockerfile. This will remove the "You are using an unsupported command-line flag..." warning that otherwise appears every time you start Chrome.


Author Information
==================

Based on [docker-chrome-pulseaudio](https://github.com/jlund/docker-chrome-pulseaudio) from Joshua Lund.

Updated by [Christian G. Warden](http://xn.pinkhamster.net).
