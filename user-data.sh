#!/bin/bash
# Action file
REPO_URL=RESERVED_FOR_REPO_URL
ACCESS_TOKEN=RESERVED_FOR_REPO_ACCESS_TOKEN
USER=ubuntu

# Update and upgrade packages as root
apt update -y
apt upgrade -y

# Install prerequisites as root
apt install -y curl git ca-certificates gnupg unzip 

# Create docker groups and add ubuntu to it
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker

# Download the GitHub Actions runner
cd /home/$USER
sudo -u $USER mkdir actions-runner && cd actions-runner
sudo -u $USER curl -O -L "$(curl -s https://api.github.com/repos/actions/runner/releases/latest | grep url | cut -d\" -f4 | grep 'actions-runner-linux-x64-[0-9.]\+tar.gz')"
sudo -u $USER tar xzf ./actions-runner-linux-x64*.tar.gz
sudo -u $USER rm ./actions-runner-linux-x64*.tar.gz

# Configure the runner using the environment variables as ubuntu
sudo -u $USER ./config.sh --url $REPO_URL --token $ACCESS_TOKEN --unattended
#Config Options:
# --unattended           Disable interactive prompts for missing arguments. Defaults will be used for missing options
# --url string           Repository to add the runner to. Required if unattended
# --token string         Registration token. Required if unattended
# --name string          Name of the runner to configure (default ip-172-31-44-33)
# --runnergroup string   Name of the runner group to add this runner to (defaults to the default runner group)
# --labels string        Custom labels that will be added to the runner. This option is mandatory if --no-default-labels is used.
# --no-default-labels    Disables adding the default labels: 'self-hosted,Linux,X64'
# --local                Removes the runner config files from your local machine. Used as an option to the remove command
# --work string          Relative runner work directory (default _work)
# --replace              Replace any existing runner with the same name (default false)
# --pat                  GitHub personal access token with repo scope. Used for checking network connectivity when executing `./run.sh --check`
# --disableupdate        Disable self-hosted runner automatic update to the latest released version`
# --ephemeral            Configure the runner to only take one job and then let the service un-configure the runner after the job finishes (default false)

# Install the runner as a service as ubuntu
./svc.sh install
./svc.sh start

# Add the runner to autostart on boot as ubuntu
systemctl enable actions-runner

# Install docker -- https://docs.docker.com/engine/install/ubuntu/
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 

# Install aws-cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

rm -r awscliv2.zip aws