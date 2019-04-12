FROM debian:stretch-slim

# Install some core libraries (build-essentials, sudo, python, curl)
RUN apt-get update && \
    apt-get install -y apt-transport-https && \
    apt-get install -y gnupg gnupg2 gnupg1 && \
    apt-get install -y build-essential && \
    apt-get install -y sudo && \
    apt-get install -y python && \
    apt-get install -y curl

# Configure sudoers so that sudo can be used without a password
RUN chmod u+w /etc/sudoers && echo "%sudo   ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Create devops user
RUN groupadd -g 10000 devops && \
    useradd -u 10000 -g 10000 -G sudo -d /home/devops -m devops && \
    usermod --password $(echo password | openssl passwd -1 -stdin) devops

USER devops
WORKDIR /home/devops

# Install the ibmcloud cli
RUN curl -sL https://ibm.biz/idt-installer | bash && \
    ibmcloud config --check-version=false

# Add the devops user to the docker group
RUN sudo usermod -aG docker devops

# Install nvm
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash

RUN echo 'echo "Initializing environment..."' > /home/devops/.bashrc-ni && \
    echo 'export NVM_DIR="${HOME}/.nvm"' >> /home/devops/.bashrc-ni && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> /home/devops/.bashrc-ni

# Set the BASH_ENV to /home/devops/.bashrc-ni so that it is executed in a
# non-interactive shell
ENV BASH_ENV /home/devops/.bashrc-ni

# Pre-install node v11.12.0
RUN . /home/devops/.bashrc-ni && nvm install v11.12.0 && nvm use v11.12.0
