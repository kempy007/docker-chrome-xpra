FROM debian:stable
MAINTAINER Christian G. Warden <cwarden@xerus.org>

# Tell debconf to run in non-interactive mode
ENV DEBIAN_FRONTEND noninteractive

# Make sure the repository information is up to date
RUN apt-get update

# Install Chrome
RUN apt-get install -y ca-certificates wget
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -P /tmp/
RUN sh -c "dpkg -i /tmp/google-chrome-stable_current_amd64.deb || exit 0"
# Finish installing Chrome with dependencies
RUN apt-get install -y -f

# Install xpra
RUN apt-get install -y gnupg2 curl pulseaudio
#RUN wget -q -O - https://xpra.org/dists/stretch/Release.gpg | sudo apt-key add -
#RUN cd /etc/apt/sources.list.d/ && wget https://xpra.org/repos/stretch/xpra.list
RUN curl https://winswitch.org/gpg.asc | apt-key add -
RUN echo "deb http://winswitch.org/ stretch main" > /etc/apt/sources.list.d/winswitch.list
RUN curl https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN apt-get update
RUN wget http://ftp.br.debian.org/debian/pool/main/x/x264/libx264-148_0.148.2748+git97eaef2-1_amd64.deb -P /tmp/ && \
sh -c "dpkg -i /tmp/libx264-148_0.148.2748+git97eaef2-1_amd64.deb || exit 0" && \
wget http://ftp.br.debian.org/debian/pool/main/libv/libvpx/libvpx4_1.6.1-3+deb9u1_amd64.deb -P /tmp/ && \
sh -c "dpkg -i /tmp/libvpx4_1.6.1-3+deb9u1_amd64.deb || exit 0" && \
RUN apt-get install -y xpra xvfb python3-xpra ffmpeg-xpra

# Add the Chrome user that will run the browser
RUN adduser --disabled-password --gecos "Chrome User" --uid 5001 chrome

# Set up the launch wrapper
ADD chrome-sandbox /usr/local/bin/chrome-sandbox
RUN chown root:root /usr/local/bin/chrome-sandbox
RUN chmod 755 /usr/local/bin/chrome-sandbox

# Start SSH so we are ready to make a tunnel
# CMD /usr/sbin/sshd -D
USER chrome
ENV HOME /home/chrome
#CMD xpra start --bind-tcp=0.0.0.0:10000 :1 --start-child=/usr/local/bin/chrome-sandbox --exit-with-children --no-daemon 

ENV DISPLAY=:100
CMD xpra start --bind-tcp=0.0.0.0:10000 --html=on --start-child=/usr/local/bin/chrome-sandbox --exit-with-children --daemon=no \
 --xvfb="/usr/bin/Xvfb +extension  Composite -screen 0 1280x720x24+32 -nolisten tcp -noreset" −−pulseaudio=yes


# Expose the xpra port
EXPOSE 10000
