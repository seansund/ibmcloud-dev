FROM debian:stretch-slim

# Install some core libraries (build-essentials, sudo, python, curl)
RUN apt-get update && \
    apt-get install -y apt-transport-https && \
    apt-get install -y gnupg gnupg2 gnupg1 && \
    apt-get install -y build-essential && \
    apt-get install -y sudo && \
    apt-get install -y python && \
    apt-get install -y curl

# Install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends yarn && \
    apt-get clean

# Install the ibmcloud cli
RUN curl -sL https://ibm.biz/idt-installer | bash && \
    ibmcloud config --check-version=false

# Move the ibmcloud plugins from /root to /usr/local/ibmcloud-plugins and
# set them up so all users can access the plugins
RUN groupadd ibmcloud && \
    usermod -aG docker,ibmcloud root && \
    mv /root/.bluemix/plugins /usr/local/ibmcloud-plugins && \
    ln -s /usr/local/ibmcloud-plugins /root/.bluemix/plugins && \
    chown -R :ibmcloud /usr/local/ibmcloud-plugins && \
    chmod -R g+rwxs /usr/local/ibmcloud-plugins && \
    mkdir /etc/skel/.bluemix && \
    ln -s /usr/local/ibmcloud-plugins /etc/skel/.bluemix/plugins

# Install nvm into /opt/nvm under the nvm group
RUN groupadd nvm && \
    usermod -aG nvm root && \
    mkdir /opt/nvm && \
    git clone https://github.com/creationix/nvm.git /opt/nvm && \
    mkdir -p /opt/nvm/.cache && \
    mkdir -p /opt/nvm/versions && \
    mkdir -p /opt/nvm/alias && \
    chown -R :nvm /opt/nvm && \
    chmod -R g+ws /opt/nvm

RUN echo 'export NVM_DIR="/opt/nvm"' > /etc/profile.d/nvm-home.sh && \
    echo '[ -s "${NVM_DIR}/nvm.sh" ] && . "${NVM_DIR}/nvm.sh"' >> /etc/profile.d/nvm-home.sh && \
    echo '[ -s "${NVM_DIR}/bash_completion" ] && . "${NVM_DIR}/bash_completion"' >> /etc/profile.d/nvm-home.sh

RUN . /etc/profile.d/nvm-home.sh && nvm install 11.12.0 && nvm use 11.12.0

# Create a new version of /etc/bash.bashrc with nvm setup at the top (so that it is
# executed in non-login shell)
RUN cat /etc/profile.d/nvm-home.sh > ./bash.bashrc.tmp && \
    cat /etc/bash.bashrc >> ./bash.bashrc.tmp && \
    rm /etc/bash.bashrc && \
    mv ./bash.bashrc.tmp /etc/bash.bashrc

# Set the BASH_ENV to /etc/bash.bashrc so that it is executed in a non-interactive
# shell
ENV BASH_ENV /etc/bash.bashrc

# Create devops and pipeline users
RUN groupadd -g 10000 devops && \
    useradd -u 10000 -g 10000 -G sudo,nvm,docker,ibmcloud -d /home/devops -m devops && \
    usermod --password $(echo password | openssl passwd -1 -stdin) devops
RUN useradd -u 1000 -G sudo,nvm,docker,ibmcloud -d /home/pipeline -m pipeline && \
    usermod --password $(echo password | openssl passwd -1 -stdin) pipeline

# Configure sudoers so that sudo can be used without a password
RUN chmod u+w /etc/sudoers && echo "%sudo   ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER devops
WORKDIR /home/devops
