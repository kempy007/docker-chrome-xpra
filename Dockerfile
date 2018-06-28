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
RUN apt-get install -y xpra xvfb

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

CMD xpra start --bind-tcp=0.0.0.0:10000 :1 --html=on --start-child=/usr/local/bin/chrome-sandbox --exit-with-children --daemon=no \
 --xvfb="/usr/bin/Xvfb +extension  Composite -screen 0 1920x1080x24+32 -nolisten tcp -noreset" \
 --pulseaudio=no --notifications=no --bell=no


# Expose the xpra port
EXPOSE 10000
