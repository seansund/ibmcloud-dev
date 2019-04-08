FROM debian:stretch-slim

RUN apt-get update && \
    apt-get install -y apt-utils && \
    apt-get install -y apt-transport-https && \
    apt-get install -y gnupg gnupg2 gnupg1 && \
    apt-get install -y build-essential && \
    apt-get install -y sudo && \
    apt-get install -y python && \
    apt-get install -y curl && \
    apt-get install -y --no-install-recommends yarn && \
    apt-get clean

RUN groupadd -g 10000 devops && useradd -u 10000 -g 10000 -G sudo -d /home/devops -m devops
RUN usermod --password $(echo password | openssl passwd -1 -stdin) devops
RUN chmod u+w /etc/sudoers && echo "%sudo   ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER devops
WORKDIR /home/devops

RUN curl -sL https://ibm.biz/idt-installer | bash && ibmcloud config --check-version=false

RUN sudo usermod -aG docker devops

RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash && \
    echo 'export NVM_DIR="${HOME}/.nvm"; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"' >> ~/.bash_profile

RUN . ~/.bash_profile && nvm install 11.12.0 && nvm use 11.12.0

