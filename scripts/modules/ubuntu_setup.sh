# Function to install Vagrant on Ubuntu
install_vagrant_ubuntu() {
  # Check if Vagrant is already installed
  if command -v vagrant &>/dev/null; then
    echo "Vagrant is already installed."
    return
  fi

  # Ensure curl is installed
  if ! command -v curl &>/dev/null; then
    echo "curl is not installed. Please install curl first."
    exit 1
  fi

  # Download and install Vagrant
  echo "Downloading Vagrant..."
  curl -O https://releases.hashicorp.com/vagrant/2.4.3/vagrant_2.4.3-1_amd64.deb

  echo "Installing Vagrant..."
  sudo dpkg -i vagrant_2.4.3-1_amd64.deb

  # Clean up
  echo "Cleaning up..."
  rm vagrant_2.4.3-1_amd64.deb
  echo "Vagrant installation completed."
}

# Function to install and configure virtual machine management on Ubuntu
install_virtual_machine_ubuntu() {
  # Run the setup commands
  sudo apt-get update -y 
  sudo apt-get install -y libvirt-daemon-system build-essential sshpass qemu-kvm libvirt-dev bridge-utils libguestfs-tools qemu ovmf virt-manager firewalld

  local LIBVIRT_GROUP="libvirt"
  if ! getent group "${LIBVIRT_GROUP}" > /dev/null; then
    echo "Group ${LIBVIRT_GROUP} does not exist. Creating it."
    sudo groupadd "${LIBVIRT_GROUP}"
  fi
  # Add user to the appropriate libvirt group
  if ! groups "$(whoami)" | grep -q "${LIBVIRT_GROUP}"; then
    echo "Adding your user to ${LIBVIRT_GROUP} group for VM management."
    sudo usermod -a -G "${LIBVIRT_GROUP}" "$(whoami)"
    echo "You may need to start a new shell to use Vagrant interactively."
  fi
  vagrant plugin install vagrant-libvirt
}

export VAGRANT_DEFAULT_PROVIDER=libvirt

# Full setup for Ubuntu
setup_ubuntu() {
  install_vagrant_ubuntu
  install_virtual_machine_ubuntu
}