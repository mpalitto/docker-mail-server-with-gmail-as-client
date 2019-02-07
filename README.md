# docker-mail-server-with-gmail-as-client
a mail server able to work with gmail as a client

The idea here is to have your own mail domain (eg. example.net) but be able to use it with gmail as front-end and be able to receive and send email from user@examle.net without paying google for your domain name.

gmail allows to add accounts and connect to SMTP server over TLS connection

I have created a simple mail server using postfix + dovecot starting from the ubuntu image

# pre-requisites
you need to install docker and docker-compose on your Linux server 

# Instructions
* clone the project
* cd into the project directory
* edit docker-compose.yml and set the build arguments according to your needs(hostname, maildomain, cert_data, users, gmailIDs, defaultPWD)
* execute the following command line: ``docker-compose up -d``
* verify docker container "mail-server" is running ``docker ps``
* verify server is respondig `openssl s_client -connect yourhost:587`
* setup gmail 
NOTE: you will need to setup the MX fields of your Host Domain provider
