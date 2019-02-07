From ubuntu
MAINTAINER Matteo Palitto

ARG maildomain
ARG hostname
ARG users
ARG gmailIDs
ARG defaultPWD
ARG cert_data
 
# Set noninteractive mode for apt-get
ENV DEBIAN_FRONTEND noninteractive

# Update
RUN apt-get update

# Add users: for each mail user there is a linux account with default password
ADD root/* /root/
RUN /root/setupUserAccounts.sh "$defaultPWD" "$users" "$gmailIDs" "$maildomain"

# Start editing
# Install package here for cache
# RUN apt-get -y install supervisor postfix sasl2-bin opendkim opendkim-tools
RUN apt-get install -y rsyslog postfix

# Add files
# ADD assets/install.sh /opt/install.sh
ADD etc-postfix/master.cf /etc/postfix/master.cf
ADD etc-postfix/main.cf /etc/postfix/main.cf
RUN /root/config-postfix-for-sasl.sh
RUN /root/config-postfix-for-tsl.sh
RUN postconf -e mydomain=$maildomain
RUN postconf -e myhostname=$hostname
# RUN postconf -F '*/*/chroot = n'

RUN touch /etc/postfix/vmail_domains
# RUN sed "s/mydomain/$maildomain/g" /root/sender_canonical > /etc/postfix/sender_canonical
# RUN sed "s/mydomain/$maildomain/g" /root/vmail_mailbox > /etc/postfix/vmail_mailbox
# RUN sed "s/mydomain/$maildomain/g" /root/vmail_aliases > /etc/postfix/vmail_aliases
RUN cp /root/sender_canonical /etc/postfix/sender_canonical
RUN cp /root/vmail_mailbox /etc/postfix/vmail_mailbox
RUN cp /root/vmail_aliases /etc/postfix/vmail_aliases
RUN postmap /etc/postfix/vmail_aliases
RUN postmap /etc/postfix/sender_canonical
RUN postmap /etc/postfix/vmail_mailbox
RUN postmap /etc/postfix/vmail_domains

# install DOVECOT
RUN apt-get install -y dovecot-core
RUN rm -r /etc/dovecot
ADD etc-dovecot /etc/dovecot
ADD usr-share-dovecot/* /usr/share/dovecot/
RUN rm /etc/dovecot/private/dovecot.pem; rm /etc/dovecot/dovecot.pem
RUN cd /usr/share/dovecot/; ./mkcert.sh
RUN /root/genCerts.sh
RUN openssl req -new -key /etc/ssl/private/smtpd.key -nodes -x509 -subj "$cert_data" -days 3650 -out /etc/ssl/certs/smtpd.crt
RUN openssl req -new -newkey rsa:2048 -nodes -x509 -subj "$cert_data" -keyout /etc/ssl/private/cakey.pem -out /etc/ssl/certs/cacert.pem -days 3650

# RUN echo "$users" > /tmp/users
# RUN echo "$gmail" > /tmp/gmail
# RUN echo "$defaultPWD" > /tmp/defaultPWD

# Run
# CMD /opt/install.sh;/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
CMD service rsyslog start; service postfix start; service dovecot start; bash

EXPOSE 25 587
