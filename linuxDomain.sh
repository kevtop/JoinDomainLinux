#!/bin/bash
linea_switch='		files dns myhostname'
linea_resolv=' 10.5.0.100'
read nombreEquipo
dominio='penn-elcom.local'
usuarioAdmin='kevin.velasco'
nombresCompletos='False'
sed -i "s/^hosts:.*/hosts: ${linea_switch}/" /etc/nsswitch.conf
sed -i "s/^nameserver.*/nameserver ${linea_resolv}/" /etc/resolv.conf
echo 'final'
hostnamectl set-hostname $nombreEquipo
apt -y install realmd libnss-sss libpam-sss sssd sssd-tools adcli samba-common-bin oddjob oddjob-mkhomedir packagekit 
realm join -U $usuarioAdmin  $dominio
echo 'listo'
bash -c "cat > /usr/share/pam-configs/mkhomedir" <<EOF
Name: activate mkhomedir
Default: yes
Priority: 900
Session-Type: Additional
Session:
        required                        pam_mkhomedir.so umask=0022 skel=/etc/skel
EOF
pam-auth-update
service sssd restart
sed -i "s/^use_fully_qualified_names = .*/use_fully_qualified_names = ${nombresCompletos}/" /etc/sssd/sssd.conf
service sssd restart
apt -y install openssh-server
echo 'listo'
