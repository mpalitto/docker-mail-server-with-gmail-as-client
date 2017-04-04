touch /etc/ssl/private/smtpd.key
chmod 600 /etc/ssl/smtpd.key
openssl genrsa 1024 > /etc/ssl/private/smtpd.key
