class { 'tungsten': installSSHKeys => true, installMysql=> true, disableFirewall=> false, skipHostConfig=> true ,mySQLSetAutoIncrement=>true ,docker => true   }
