#!/bin/bash

# Script for setting up Docker, kubectl, eksctl, and kubens on a CentOS system

# Initialize user ID, color codes for messages, architecture, and platform variables
ID=$(id -u)            # Get the current user ID to check if script is run as root
R="\e[31m"             # Red color for error messages
G="\e[32m"             # Green color for success messages
Y="\e[33m"             # Yellow color for warnings
N="\e[0m"              # Reset color
ARCH=amd64             # Define architecture as amd64 (can change based on target system)
PLATFORM=$(uname -s)_$ARCH # Define platform based on system type and architecture

# Define timestamp for logging purposes
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log" # Log file path based on timestamp

# Log the script start time
echo "script started executing at $TIMESTAMP" &>> $LOGFILE

# Define validation function to check command success and print status
VALIDATE(){
    if [ $1 -ne 0 ]
    then
        # If the command fails, print a failure message and exit the script
        echo -e "$2 ... $R FAILED $N"
        exit 1
    else
        # If the command succeeds, print a success message
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

# Check if the script is run as root
if [ $ID -ne 0 ]
then
    # If not root, print an error and exit
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1
else
    # If root, confirm in output
    echo "You are root user"
fi

# Install yum-utils to enable yum configuration management
yum install -y yum-utils
VALIDATE $? "Installed yum utils"

# Add Docker's official repository to yum for package management
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
VALIDATE $? "Added docker repo"

# Install Docker CE, CLI, containerd, and plugins
yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
VALIDATE $? "Installed docker components"

# Start Docker service
systemctl start docker
VALIDATE $? "Started docker"

# Enable Docker service to start on boot
systemctl enable docker
VALIDATE $? "Enabled docker"

# Add 'centos' user to Docker group for non-root Docker access
usermod -aG docker centos
VALIDATE $? "Added centos user to docker group"
echo -e "$R Logout and login again $N" # Informs user to re-login for group change to take effect

# Download the latest stable release of kubectl, make it executable, and move it to /usr/local/bin
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/kubectl
VALIDATE $? "Kubectl installation"

# Download and extract the latest eksctl binary, then move it to /usr/local/bin
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
sudo mv /tmp/eksctl /usr/local/bin
VALIDATE $? "eksctl installation"

# Clone kubectx repository for kubectx and kubens, then create a symlink for kubens
sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens
VALIDATE $? "kubens installation"
