# Proper CICD with Openshift, ArgoCD & Gitlab in Vsphere


# OS Templates

To provide repeatable OS Creation, the following steps are suggested to produce a golden image.

Either Vsphere/Hyperv/RHV will do

In this example we leverage the terraform and vsphere
2vCPU, 4GB ram, 100 GB harddisk(thin provisioning)

## CENTOS 8

1. Install CENTOS
2. dnf update
3. disable SELINUX
4. setup ansible account, ssh-genkey, copy the key
5. setup ansible account as sudoer
6. convert the VM to template (URL needed)

# Create VMs
There are several way to achieve the VM creation

Create Vsphere role for Terraform Provisioning
Terraform:
(GithubURL)

Reference: https://medium.com/@gmusumeci/deploying-vmware-vsphere-virtual-machines-with-packer-terraform-d0211f72b7f5

# Install Gitlab on CentOS8

## Manual Installation

  

### Install and configure the necessary dependencies

>On CentOS 8 (and RedHat 8), the commands below will also open HTTP, HTTPS and SSH access in the system firewall.

    sudo dnf install -y curl policycoreutils openssh-server
    
    sudo systemctl enable sshd
    
    sudo systemctl start sshd

> Check if opening the firewall is needed with: sudo systemctl status firewalld

    sudo firewall-cmd --permanent --add-service=http
    
    sudo firewall-cmd --permanent --add-service=https
    
    sudo systemctl reload firewalld

>Next, install Postfix to send notification emails. If you want to use another solution to send emails please skip this step and configure an external SMTP server after GitLab has been installed.

    sudo dnf install postfix
    
    sudo systemctl enable postfix
    
    sudo systemctl start postfix

> During Postfix installation a configuration screen may appear. Select 'Internet Site' and press enter. Use your server's external DNS for 'mail name' and press enter. If additional screens appear, continue to press enter to accept the defaults.

 

### Add the GitLab package repository and install the package

Add the GitLab package repository.

      
    curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh | sudo bash

Next, install the GitLab package. Make sure you have correctly set up your DNS, and change https://gitlab.example.com to the URL at which you want to access your GitLab instance. Installation will automatically configure and start GitLab at that URL.
 

 For https:// URLs GitLab will automatically request a certificate with Let's Encrypt, which requires inbound HTTP access and a valid hostname. You can also use your own certificate or just use http://.

    sudo EXTERNAL_URL="https://gitlab.example.com" dnf install -y gitlab-ee

  ### (Optional) Additional Settings to run gitlab behind reverse proxy

      In /etc/gitlab/gitlab.rb
      external_url 'https://ci.yoursite.com'

      nginx['listen_port'] = 80
      nginx['listen_https'] = false
      
By default, NGINX and GitLab will log the IP address of the connected client.

If your GitLab is behind a reverse proxy, you may not want the IP address of the proxy to show up as the client address.

You can have NGINX look for a different address to use by adding your reverse proxy to the  `real_ip_trusted_addresses`  list:

```
# Each address is added to the the NGINX config as 'set_real_ip_from <address>;'
nginx['real_ip_trusted_addresses'] = [ '192.168.1.0/24', '192.168.2.1', '2001:0db8::/32' ]
# other real_ip config options
nginx['real_ip_header'] = 'X-Forwarded-For'
nginx['real_ip_recursive'] = 'on'

## Install with Ansible
(To be completed)