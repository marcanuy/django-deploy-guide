Provisioning a new site
=======================

Production-ready configuration for provisioning and deploying a simple Django app in a three-tier server scheme: development, staging, and production.

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-generate-toc again -->
**Table of Contents**

- [Provisioning a new site](#provisioning-a-new-site)
    - [Features](#features)
    - [Design](#design)
    - [General workflow](#general-workflow)
    - [Required packages](#required-packages)
    - [Nginx Virtual Host config](#nginx-virtual-host-config)
    - [Systemd service](#systemd-service)
    - [Folder structure](#folder-structure)
    - [Reference](#reference)

<!-- markdown-toc end -->


## Features

* Focuses in manually provisioning a server.
* Nginx and Gunicorn through [UNIX domain sockets](https://en.wikipedia.org/wiki/Unix_domain_socket). 
* [systemd](http://freedesktop.org/wiki/Software/systemd/) instead of [upstart](http://upstart.ubuntu.com/) (the default init system since Ubuntu 15.04).

## Design

- A staging site
  - To run functional tests on a similar environment as the production server
- virtualenvs
  - To have the same software versions accross multiple servers
- A [fabric](http://fabfile.org) script 
  - To deploy updates in an automated fashion to several severs.
- Nginx
- Gunicorn
  - Serve python files through a unix socket (better than serving them through a port to avoid mistakes selecting ports)
- Systemd service
  - To create a socket for local interprocess communication between the Nginx server and Gunicorn
  - Automatically starts up Gunicorn after reboot, and automatically start again if Gunicorn should stop abnormally

## General workflow

Get live site into production:

```
$ sed "s/SITENAME/mysite-staging.example.com/g" \
    deploy_tools/nginx.template.conf | sudo tee \
    /etc/nginx/sites-available/mysite-staging.example.com
```

Enable Nginx site

```
sudo ln -s ../sites-available/mysite-staging.example.com \
    /etc/nginx/sites-enabled/mysite-staging.example.com
```

Create the Systemd service

```
sed "s/SITENAME/mysite-staging.example.com/g" \
    deploy_tools/gunicorn-systemd.template.service | sudo tee \
    /lib/systemd/system/gunicorn-mysite-staging.example.com.service
```

Load the new site in Nginx and start the systemd service

```
$ sudo service nginx reload
$ sudo systemctl enable gunicorn-mysite-staging.example.com 
$ sudo systemctl start gunicorn-mysite-staging.example.com.service
```

## Required packages

* nginx
* Python 3
* Git
* pip
* virtualenv

eg, on Ubuntu:

    sudo apt-get install nginx git python3 python3-pip
    sudo pip3 install virtualenv

## Nginx Virtual Host config

* see nginx.template.conf
* replace SITENAME with, eg, staging.my-domain.com

## Systemd service

* see gunicorn-upstart.template.conf
* replace SITENAME with, eg, staging.my-domain.com

## Folder structure
Assume we have a user account at /home/myuser

```
/home/myuser
└── sites
    └── SITENAME
         ├── database
         ├── source
         ├── static
         └── virtualenv
```

## Reference

- http://www.freedesktop.org/software/systemd/man/systemd.exec.html
- https://wiki.ubuntu.com/SystemdForUpstartUsers
- https://github.com/hjwp/book-example/blob/master/deploy_tools/provisioning_notes.md

## Licence

Inspired in the deployment procedure outlined in [Test Driven Development with Python](http://chimera.labs.oreilly.com/books/1234000000754/ch08.html#_automating).

[CC BY-NC-SA 3.0](http://creativecommons.org/licenses/by-nc-sa/3.0/)
