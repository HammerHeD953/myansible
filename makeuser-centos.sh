#!/bin/bash
username=ansible
sshkey="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDtoAkmqoycQyhaS46/VK+UnwQgwffOnbPH9V08b8PXUF2IGdEAMW4Vc0cXdGz9XH5RBfRZT96OKdfb8hzcM8B66Xd7b4fIHBUt+koT8lso+oBZf5+qKaQUoWR3HlC005UyLJPeddsWOjkhl1Cx/0lptVtyDsGChLZpEM6AOVZbEBfMJit1prkCS1EnQsdLUDbtnVB110AMNF5DhzVrBB5KRRfmHur8dg0b6/G1UIVnUeVCHOIh+6P8skyMo7snfP3AvffPXEza8h0YW5kYtLgE317X/UQvArCPPW7bkqxtFDcFxHP9g1esZNX2Etx05s6dUqFKObITQMTVqlYI9NJoXxn6LHQgrQUOrjt7dL0C8A2MvK9innBxNH5Bm7xAjOulZp7zY28obNKyTzigizA0PayOB35cpRUkLdseWSa3W7iDQBlxMIUgkON8EO6MnTbAEZ2r2LMolEW+FTZaLQgOizKTRS6KHx9M2szuvTRQS7UwWBeWzUdfiIW+0laM2yc= zero@Zero-pc"
# useradd -m -d /home/$username -s /bin/bash $username
adduser $username
gpasswd -a $username wheel
mkdir -p /home/$username/.ssh && touch /home/$username/.ssh/authorized_keys
chown -R $username:$username /home/$username/.ssh
chmod 700 /home/$username/.ssh
chmod 600 /home/$username/.ssh/authorized_keys
echo $sshkey > /home/$username/.ssh/authorized_keys
echo "%wheel ALL=(ALL)  ALL" > /etc/sudoers.d/$username
echo "$username ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$username
