puppet apply /mnt/base.pp --modulepath=/mnt/modules

service ssh start
service mysql start
sleep 600
dpkg -i /mnt/rpm/ct.deb
