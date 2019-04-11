FROM debian:stretch-slim

RUN apt-get update && \
    apt-get install -y apt-transport-https && \
    apt-get install -y gnupg gnupg2 gnupg1 && \
    apt-get install -y build-essential && \
    apt-get install -y sudo && \
    apt-get install -y python && \
    apt-get install -y curl

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends yarn && \
    apt-get clean

RUN curl -sL https://ibm.biz/idt-installer | bash && \
    ibmcloud config --check-version=false

RUN groupadd ibmcloud && \
    usermod -aG docker,ibmcloud root && \
    mv /root/.bluemix/plugins /usr/local/ibmcloud-plugins && \
    ln -s /usr/local/ibmcloud-plugins /root/.bluemix/plugins && \
    chown -R :ibmcloud /usr/local/ibmcloud-plugins && \
    chmod -R g+rwxs /usr/local/ibmcloud-plugins && \
    mkdir /etc/skel/.bluemix && \
    ln -s /usr/local/ibmcloud-plugins /etc/skel/.bluemix/plugins

RUN groupadd nvm && \
    usermod -aG nvm root && \
    mkdir /opt/nvm && \
    git clone https://github.com/creationix/nvm.git /opt/nvm && \
    mkdir -p /opt/nvm/.cache && \
    mkdir -p /opt/nvm/versions && \
    mkdir -p /opt/nvm/alias && \
    chown -R :nvm /opt/nvm && \
    chmod -R g+ws /opt/nvm

COPY profile.d/* /etc/profile.d
RUN cat /etc/profile.d/nvm-home.sh >> /etc/bash.bashrc

RUN groupadd -g 10000 devops && \
    useradd -u 10000 -g 10000 -G sudo,nvm,docker,ibmcloud -d /home/devops -m devops && \
    usermod --password $(echo password | openssl passwd -1 -stdin) devops
RUN useradd -u 1000 -G sudo,nvm,docker,ibmcloud -d /home/pipeline -m pipeline && \
    usermod --password $(echo password | openssl passwd -1 -stdin) pipeline

RUN chmod u+w /etc/sudoers && echo "%sudo   ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN . /etc/profile.d/nvm-home.sh && nvm install 11.12.0 && nvm use 11.12.0

USER devops
WORKDIR /home/devops
