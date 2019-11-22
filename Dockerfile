FROM debian:stable
MAINTAINER Christian G. Warden <cwarden@xerus.org>

# Tell debconf to run in non-interactive mode
ENV DEBIAN_FRONTEND noninteractive

# Set up the launch wrapper
ADD chrome-sandbox /usr/local/bin/chrome-sandbox

####################################################
## RUN 01
####################################################
RUN echo "Begin Docker RUN" && \
apt-get update && \
apt-get install -y ca-certificates wget gnupg2 curl pulseaudio xpra xvfb && \

wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -P /tmp/ && \
sh -c "dpkg -i /tmp/google-chrome-stable_current_amd64.deb || exit 0" && \
apt-get install -y -f && \
sh -c "dpkg -i /tmp/google-chrome-stable_current_amd64.deb || exit 0" && \

adduser --disabled-password --gecos "Chrome User" --uid 5001 chrome && \

chown root:root /usr/local/bin/chrome-sandbox && \
chmod 755 /usr/local/bin/chrome-sandbox && \

echo "Finished our RUN script"
###################################################
## End of RUN 01
###################################################

RUN apt-get update && apt-get install -y libxkbfile-dev npm libavcodec-extra x264 ffmpeg pkg-config python-pip python-dev build-essential 
#&& apt-get remove -y xpra websockify
RUN npm install --global uglifyjs && pip install websockify cython websocket
RUN pip install yuicompressor  numpy ffmpeg 

#xpra pyv4l2

# Start SSH so we are ready to make a tunnel
# CMD /usr/sbin/sshd -D
USER chrome
ENV HOME /home/chrome
#CMD xpra start --bind-tcp=0.0.0.0:10000 :1 --start-child=/usr/local/bin/chrome-sandbox --exit-with-children --no-daemon 

ENV DISPLAY=:100
#CMD xpra start --bind-tcp=0.0.0.0:10000 --html=on --start-child=/usr/local/bin/chrome-sandbox --exit-with-children --daemon=no \
# --xvfb="/usr/bin/Xvfb +extension  Composite -screen 0 1280x720x24+32 -nolisten tcp -noreset" 
CMD xpra start --bind-ws=0.0.0.0:10000 --html=no --dbus-proxy=no --dbus-control=no --webcam=no --mdns=no --notifications=no --start-child=/usr/local/bin/chrome-sandbox --exit-with-children --daemon=no  --xvfb="/usr/bin/Xvfb +extension  Composite -screen 0 1280x720x24+32 -nolisten tcp -noreset"

#−−pulseaudio=yes


# Expose the xpra port
EXPOSE 10000
