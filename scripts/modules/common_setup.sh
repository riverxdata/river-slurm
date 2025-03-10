# 1. Install the ansible dependencies
# Function to check if Python3 is installed
install_python_venv(){
    # Check if Python3 is installed
    if command -v python3 &>/dev/null; then
        echo "Python3 is installed"
    else
        echo "Python3 is not installed. Please install Python3."
        exit 1
    fi

    # Create a virtual environment if not exists
    if [ ! -d "${ROOT_DIR}/env" ]; then
        echo "Creating virtual environment..."
        python3 -m venv ${ROOT_DIR}/env
    fi

    # Activate the virtual environment
    echo "Activating virtual environment..."
    source ${ROOT_DIR}/env/bin/activate

    # Check if requirements.txt exists
    if [ -f "requirements.txt" ]; then
        echo "Installing requirements..."
        pip3 install -r requirements.txt
    else
        echo "requirements.txt file not found."
        deactivate
        exit 1
    fi

}
# Collect the ansible roles
ansible_galaxy_install(){
    # Check if requirements.yml exists
    if [ -f "requirements.yml" ]; then
        echo "Installing Ansible roles..."
        ansible-galaxy install -r requirements.yml -p ${ROOT_DIR}/roles
    else
        echo "requirements.yml file not found."
        exit 1
    fi
}


create_ssh_key(){
    # CREATE SSH KEY
    yes n | ssh-keygen -q -t rsa -f ~/.ssh/id_rsa -C "" -N "" || echo "key exists"
}

up_vm_and_inventory(){
    # CREATE VIRTUAL MACHINE and INVENTORY
    cp ${ROOT_DIR}/inventories/hosts.examples ${ROOT_DIR}/inventories/hosts
    cp ${ROOT_DIR}/scripts/virtual/Vagrantfile_${OS} ${ROOT_DIR}/scripts/virtual/Vagrantfile
    cd ${ROOT_DIR}/scripts/virtual && vagrant up
    cd ${ROOT_DIR}
}

setup_cluster(){
    ansible-playbook -i ${ROOT_DIR}/inventories/hosts ${ROOT_DIR}/river_cluster.yml
}