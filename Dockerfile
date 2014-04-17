FROM debian:stable
MAINTAINER Christian G. Warden "cwarden@xerus.org"

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

# Install OpenSSH
RUN apt-get install -y openssh-server

# Create OpenSSH privilege separation directory
RUN mkdir /var/run/sshd

# Add the Chrome user that will run the browser
RUN adduser --disabled-password --gecos "Chrome User" --uid 5001 chrome

# Install mitmproxy cert
RUN apt-get install -y libnss3-tools
ADD mitmproxy-ca-cert.pem /tmp/mitmproxy-ca-cert.crt
RUN mkdir -p /home/chrome/.pki/nssdb
RUN certutil -d sql:/home/chrome/.pki/nssdb -N
RUN certutil -d sql:/home/chrome/.pki/nssdb -A -t "C,," -n mitmproxy -i /tmp/mitmproxy-ca-cert.crt
RUN chown -R chrome:chrome /home/chrome/.pki

# Add SSH public key for the chrome user
RUN mkdir /home/chrome/.ssh
ADD authorized_keys /home/chrome/.ssh/authorized_keys
RUN chown -R chrome:chrome /home/chrome/.ssh

# Add SSH public key for the root user
RUN mkdir /root/.ssh
ADD authorized_keys /root/.ssh/authorized_keys
RUN chown -R root:root /root/.ssh

# Set up the launch wrapper
ADD chrome-sandbox /usr/local/bin/chrome-sandbox
RUN chown root:root /usr/local/bin/chrome-sandbox
RUN chmod 755 /usr/local/bin/chrome-sandbox

# Start SSH so we are ready to make a tunnel
CMD /usr/sbin/sshd -D

# Expose the SSH port
EXPOSE 22
