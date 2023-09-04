#!/bin/bash
REPO_URL=RESERVED_FOR_REPO_URL
ACCESS_TOKEN=RESERVED_FOR_REPO_ACCESS_TOKEN

# Update and upgrade packages as root
sudo apt update -y
sudo apt upgrade -y

# Install prerequisites as root
sudo apt install -y curl git

# Download the GitHub Actions runner

cd /home/ubuntu
mkdir actions-runner && cd actions-runner
sudo -u ubuntu curl -O -L "$(curl -s https://api.github.com/repos/actions/runner/releases/latest | grep url | cut -d\" -f4 | grep 'actions-runner-linux-x64-[0-9.]\+tar.gz')"
sudo -u ubuntu tar xzf ./actions-runner-linux-x64*.tar.gz

# Configure the runner using the environment variables as ubuntu
sudo -u ubuntu ./config.sh --url "$REPO_URL" --token "$ACCESS_TOKEN"

# Install the runner as a service as ubuntu
sudo -u ubuntu ./svc.sh install
sudo -u ubuntu ./svc.sh start

# Add the runner to autostart on boot as ubuntu
sudo -u ubuntu systemctl enable actions-runner