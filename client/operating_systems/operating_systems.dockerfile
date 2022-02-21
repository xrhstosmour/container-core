FROM ubuntu:latest

# Disable the OS dialogs.
ENV DEBIAN_FRONTEND=noninteractive

# Enable WSL and executables access via Docker in Windows.
# RUN export PATH="$PATH:/mnt/c/Windows/System32/WindowsPowerShell/v1.0"
# RUN export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"
# RUN export PATH="$PATH:/mnt/c/Windows/System32"

# Update, install the needed packages and clean not needed ones.
RUN apt-get update -y
RUN apt-get install -y gcc libvirt-daemon-system qemu-kvm libvirt-dev make rdesktop linux-image-generic curl net-tools jq
RUN apt-get autoclean
RUN apt-get autoremove

RUN curl -O https://releases.hashicorp.com/vagrant/$(curl -s https://checkpoint-api.hashicorp.com/v1/check/vagrant  | jq -r -M '.current_version')/vagrant_$(curl -s https://checkpoint-api.hashicorp.com/v1/check/vagrant  | jq -r -M '.current_version')_x86_64.deb
RUN dpkg -i vagrant_$(curl -s https://checkpoint-api.hashicorp.com/v1/check/vagrant  | jq -r -M '.current_version')_x86_64.deb
RUN vagrant plugin install vagrant-libvirt
RUN vagrant box add --provider libvirt peru/windows-10-enterprise-x64-eval
RUN vagrant init peru/windows-10-enterprise-x64-eval
COPY /scripts/startup.sh /

# Enable again OS dialogs, after updating it.
ENV DEBIAN_FRONTEND=dialog

ENTRYPOINT ["/startup.sh"]