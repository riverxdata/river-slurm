#!/bin/bash
# CONFIG
VAGRANT_VERSION="2.4.3"
PYTHON_VERSION="3.9.13"
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <UBUNTU_VERSION> <RUN_VM>"
    exit 1
fi

UBUNTU_VERSION="${1:-20.04}"
RUN_VM="${2:-false}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
ROOT_DIR=$(realpath "${SCRIPT_DIR}/..")

# LOAD MODULES
source "${ROOT_DIR}/scripts/modules/common_setup.sh"
source "${ROOT_DIR}/scripts/modules/macos_setup.sh"
source "${ROOT_DIR}/scripts/modules/ubuntu_setup.sh"

# Check the operating system
case "$(uname)" in
    Darwin)
        echo "macOS detected."
        OS="macos"
        ;;
    Linux)
        echo "Ubuntu/Linux detected."
        export DEBIAN_FRONTEND=noninteractive
        OS="ubuntu"
        OS="${OS}_${UBUNTU_VERSION}"
        ;;
    *)
        echo "Unsupported operating system."
        exit 1
        ;;
esac

install_python_venv
ansible_galaxy_install

if [ "${OS}" == "macos" ]; then
    setup_macos
elif [ "${OS}" == "ubuntu" ]; then
    setup_ubuntu
fi

if [ "${RUN_VM}" == true ]; then
    up_vm_and_inventory
    setup_cluster
fi
