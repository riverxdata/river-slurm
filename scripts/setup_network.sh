# this one is manually to set up for the slurm cluster in a single workstation with 2 virtual machines using libvirt
# enable port forward
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# confifg
sudo iptables -A INPUT -p tcp --dport 9022 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
sudo iptables -t nat -A PREROUTING -p tcp --dport 9022 -j DNAT --to-destination 192.168.58.10:22
sudo iptables -t nat -A PREROUTING -p tcp --dport 9080 -j DNAT --to-destination 192.168.58.10:80
sudo iptables -t nat -A PREROUTING -p tcp --dport 9443 -j DNAT --to-destination 192.168.58.10:443
# Allow forwarding traffic to the VM
sudo iptables -A FORWARD -p tcp -d 192.168.58.10 --dport 22 -j ACCEPT
sudo iptables -A FORWARD -p tcp -d 192.168.58.10 --dport 80 -j ACCEPT
sudo iptables -A FORWARD -p tcp -d 192.168.58.10 --dport 443 -j ACCEPT
# Enable NAT for outgoing packets from the VM
sudo iptables -t nat -A POSTROUTING -j MASQUERADE

# Save and enable when reload
sudo iptables-save | sudo tee /etc/iptables.rules
sudo iptables-restore < /etc/iptables.rules
sudo mv iptables-restore.service /etc/systemd/system/iptables-restore.service
sudo systemctl enable iptables-restore


# reset
sudo iptables -F          
sudo iptables -t nat -F  
sudo iptables -t mangle -F 
sudo iptables -X 
sudo iptables -Z


# check
sudo iptables -L -n -v
sudo iptables -t nat -L -n -v