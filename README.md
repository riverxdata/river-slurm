# SLURM Cluster: RIVERXDATA  

## Overview

This repository provides a streamlined setup for deploying a **small to medium-scale bioinformatics computing environment** using [Slurm](https://slurm.schedmd.com/overview.html). It is designed for modern **distributed clusters**, enabling users to:  

- Easily install and configure essential tools  
- Run and manage jobs efficiently with **Conda** and Conda-based environments (**Micromamba, Mamba**)  
- Customize the infrastructure based on specific workflow requirements  

For simplified tool installation, we recommend using [**river-utils**](https://github.com/riverxdata/river-utils), which automates the setup of **Micromamba** and other essential bioinformatics tools.

### Machines
- **Monitor Server:**
    - geerlingguy.docker: Docker container
    - Prometheus: Monitoring metrics collection
    - Alertmanager: Alerts to Slack channel with specific rules (e.g., down node)
    - Grafana: Dashboard for monitoring usage

- **Slurm HPC:**
    - **Common Roles:**
        - geerlingguy.docker (only for sudo group users)
        - Alertmanager
        - Grafana
        - prometheus-slurm-exporter
        - prometheus-node-exporter
    - **Specific Nodes:**
        - **Controller Node:**
            - slurm-master: Controller and login node
            - rsyslog-server: Syslog server controller
            - nfs-server: Network file system to share files across clusters
        - **Worker Nodes:**
            - slurm-worker: Computing nodes
            - rsyslog-client: Syslog client worker
            - nfs-client: Access files on the controller

## Production
For slurm
### Install ansible and required tasks
```bash
# to show agruments
# bash scripts/setup.sh
bash scripts/setup.sh 24.04 false
```
### Prepare Inventory for Hosts
For the password, it should be configured using [**ansible vault**](https://docs.ansible.com/ansible/2.8/user_guide/vault.html) with encrypted, decrypted secret variables
Copy the example `hosts.example` file in the inventories directory. In this file, define the user and host for your setup:

```
[slurm_master]
controller-01 ansible_host=192.168.58.10

[slurm_worker]
worker-01 ansible_host=192.168.58.11

[slurm:children]
slurm_master
slurm_worker

[all:vars]
ansible_user=vagrant
slurm_password=<password for Munge to authenticate via symmetric key>
slurm_account_db_pass=<slurm account database password>
```

Optional parameters:

```
default_password=<default password for users in the cluster; first login will enforce a password change>
users=<comma-separated list of new usernames>
slack_api_url=<Slack webhook URL for cluster status notifications>
slack_channel=<Slack channel for notifications>
admin_user =<Grafana admin user>
admin_password=<Grafana admin password>
```
### Run playbook for Cluster

To set up on your cluster, ensure that the remote nodes can log in without a password. Run the following command:
```bash
ansible-playbook -i inventories/hosts river_cluster.yml
```

If a password is required, add the `--ask-become-pass` flag and run:

```bash
ansible-playbook -i inventories/hosts river_cluster.yml --ask-become-pass
```

### Run playbook for User
To set up users on the cluster, use Ansible. NIS is less secure and other methods are not well supported for Ubuntu. Simply run the following command to add users:

```bash
ansible-playbook -i inventories/hosts river_users.yml
```

### Validate setup
Submit job to validate the cluster
```bash
# get cluster info
sinfo
# get current job
squeue
# submit interactive
srun --pty bash
```

### Monitoring 
The master node should be the public network that allows users to login.
For monitoring, the admin can set up the reverse proxy and at least using ssh tunnel to view the dashboard at http://localhost:3000 at the master node
Or access via ssh tunnel
```bash
ssh -N -L 3000:localhost:3000 <user name>@<master node>
```


## Developer
Install vagrant and relative provider, for Ubuntu, it automatically install the libvirt and run the ansible playbook
```bash
bash scripts/setup.sh 24.04 true
```