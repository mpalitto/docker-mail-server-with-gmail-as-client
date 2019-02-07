#!/bin/bash

#the first user will be used as the sender for the whole organization
defaultPWD=$1
users=($2)
gmail=($3)
maildomain=$4

# echo "users: ${users[@]}" > /tmp/tmp
# echo "gmail: ${gmail[@]}" >> /tmp/tmp
# echo "PWD: $defaultPWD" >> /tmp/tmp

# create users linux account assinging the default password
for user in ${users[*]}
do
  useradd -m -s /bin/bash $user 
  echo $user:$defaultPWD::::: | newusers
  touch /var/mail/$user
  chown $user:$user /var/mail/$user
done

# generate the postfix sender_canonical file:
n=0; echo -n > /root/sender_canonical
for user in ${users[*]}
do
  if [ $n -eq 0 ]; then
    sender="$user@$maildomain"
  else 
    echo "$user@$maildomain $sender" >> /root/sender_canonical 
  fi
  let n++
done

# generate the postfix vmail_mailbox file:
echo -n > /root/vmail_mailbox
for user in ${users[*]}
do
  echo "$user@$maildomain $maildomain/$user" >> /root/vmail_mailbox 
done

# generate the postfix vmail_aliases file:
echo -n > /root/vmail_aliases
if [ ${#users[@]} -ne ${#gmail[@]} ]; then
  echo ERROR: users and gmailIDs must be the same number
else
  n=${#users[@]}
  m=$n
  while [ $n -gt 0 ]
  do
    let n--
    if [ "${gmail[$n]}" = "all" ]; then
      echo -n "${users[0]}@$maildomain "
      while [ $m -gt 1 ]; do let m--; echo -n "${gmail[$m]} "; done; m=-1; echo
    else
      echo ${users[$n]}@$maildomain ${gmail[$n]}
    fi
  done >> /root/vmail_aliases
fi
