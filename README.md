# Proper CICD with Openshift, ArgoCD & Gitlab in Vsphere


# OS Templates

To provide repeatable OS Creation, the following steps are suggested to produce a golden image.

Either Vsphere/Hyperv/RHV will do

In this example we leverage the terraform and vsphere
2vCPU, 4GB ram, 100 GB harddisk(thin provisioning)

## CENTOS 8 (For Gitlab Server)

1. Install CENTOS
2. dnf update
3. disable SELINUX
4. setup ansible account, ssh-genkey, copy the key
5. setup ansible account as sudoer
6. convert the VM to template (URL needed)

## Ubuntu 20.4 (For Gitlab Runner)

1. Install Ubuntu
2. apt-get Update
3. Install Docker Engine
    sudo apt install docker.io
    sudo systemctl enable --now docker
    docker run hello-world

    sudo usermod -aG docker ansible
    sudo usermod -aG docker <your user>

4. setup ansible account, ssh-genkey, copy the key
    ssh-keygen
    copy secret key and public key
5. setup ansible account as sudoer
    sudo usermod -aG sudo ansible

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

### Enable Gitlab Container Registry behind reverse proxy

```
server {
    listen 443 http2 ssl;
    server_name gl.serveradmin.ru;
    access_log /var/log/nginx/gl.serveradmin.ru-access.log full;
    error_log /var/log/nginx/gl.serveradmin.ru-error.log;

    ssl_certificate /etc/letsencrypt/live/gl.serveradmin.ru/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/gl.serveradmin.ru/privkey.pem;

    limit_conn perip 50;

    location /.well-known {
    root /tmp;
    }

    location / {
    proxy_pass http://10.20.50.8:80;
    proxy_read_timeout      300;
    proxy_connect_timeout   300;
    proxy_redirect          off;
    proxy_set_header        X-Forwarded-Proto https;
    proxy_set_header        Host              $http_host;
    proxy_set_header        X-Real-IP         $remote_addr;
    proxy_set_header        X-Forwarded-For   $proxy_add_x_forwarded_for;
    proxy_set_header        X-Forwarded-Ssl   on;
    }
}

server {
    listen 80;
    server_name gl.serveradmin.ru;
    return 301 https://gl.serveradmin.ru$request_uri;
}

server {
    listen 443 http2 ssl;
    server_name rg.serveradmin.ru;
    access_log /var/log/nginx/rg.serveradmin.ru-access.log full;
    error_log /var/log/nginx/rg.serveradmin.ru-error.log;

    ssl_certificate /etc/letsencrypt/live/rg.serveradmin.ru/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/rg.serveradmin.ru/privkey.pem;

    limit_conn perip 50;

    location /.well-known {
    root /tmp;
    }

    location / {
    proxy_pass http://10.20.50.8:80;
    proxy_read_timeout      300;
    proxy_connect_timeout   300;
    proxy_redirect          off;
    proxy_set_header        X-Forwarded-Proto https;
    proxy_set_header        Host              $http_host;
    proxy_set_header        X-Real-IP         $remote_addr;
    proxy_set_header        X-Forwarded-For   $proxy_add_x_forwarded_for;
    proxy_set_header        X-Forwarded-Ssl   on;
    proxy_set_header        X-Frame-Options   SAMEORIGIN;
    proxy_cache off;
    proxy_buffering off;
    proxy_request_buffering off;
    proxy_http_version 1.1;
    }
}

server {
    listen 80;
    server_name rg.serveradmin.ru;
    return 301 https://rg.serveradmin.ru$request_uri;
}
```

```
external_url 'https://gl.serveradmin.ru'
nginx['listen_port'] = 80
nginx['listen_https'] = false

registry_external_url 'https://rg.serveradmin.ru'
gitlab_rails['registry_enabled'] = true
registry['enable'] = true
registry_nginx['enable'] = true
registry_nginx['proxy_set_headers'] = {
 "Host" => "$http_host",
 "X-Real-IP" => "$remote_addr",
 "X-Forwarded-For" => "$proxy_add_x_forwarded_for",
 "X-Forwarded-Proto" => "https",
 "X-Forwarded-Ssl" => "on"
 }
registry_nginx['listen_port'] = 80
registry_nginx['listen_https'] = false
```

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
```


## Install with Ansible
(To be completed)


# Install Gitlab runner