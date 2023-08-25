class baseconfig {
  
  exec { 'apt-get update':
    command => '/usr/bin/apt-get update',
  }

  package { 'nodejs':
    ensure => 'installed',
  }

  package { 'npm':
    ensure => 'installed',
  }

  package { 'net-tools':
    ensure => 'installed',
  }

  package { 'consul':
    ensure => 'installed',
  }

  exec { 'run_consul_agent':
    command     => "/usr/bin/sudo consul agent -ui -dev -bind=${private_ip} -client=0.0.0.0 -data-dir=. -retry-join=193.168.100.3 -retry-join=193.168.100.5 -retry-join=193.168.100.6 > /var/log/consul.log 2>&1 &",
    onlyif      => "/usr/bin/pgrep consul > /dev/null || true",
    require     => Package['consul'],
  }

  package { 'python3-pip':
    ensure => 'installed',
  }

  exec { 'pip3 install jupyter':
    command     => '/usr/bin/pip3 install jupyter',
    path        => '/usr/local/bin:/usr/bin',
    refreshonly => true,
    subscribe   => Package['python3-pip'],
  }

  file { '/home/vagrant/consulService':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/home/vagrant/consulService/app':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/home/vagrant/consulService/app/index.js':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/baseconfig/index.js',
  }

  exec { 'npm_install_consul':
    command     => '/usr/bin/npm install consul',
    cwd         => '/home/vagrant/consulService/app',
    require     => [Package['nodejs'], Package['npm']],
  }

  exec { 'npm_install_express':
    command     => '/usr/bin/npm install express',
    cwd         => '/home/vagrant/consulService/app',
    require     => [Package['nodejs'], Package['npm']],
  }

  exec { 'install_lxd_installer':
    command => '/usr/bin/apt-get install lxd-installer -y',
    path    => ['/usr/local/bin', '/usr/bin'],
  }

  exec { 'login_to_lxd_group':
    command => 'newgrp lxd',
    path    => ['/usr/local/bin', '/usr/bin'],
    require => Exec['install_lxd_installer'],
  }

  exec { 'initialize_lxd':
    command => '/usr/sbin/lxd init --auto',
    path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    require => Exec['login_to_lxd_group'],
    before  => Exec['start_service_instances'],
  }

  package { 'haproxy':
    ensure => 'installed',
  }

  file { '/etc/haproxy/haproxy.cfg':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/baseconfig/haproxy.cfg',
    require => Package['haproxy'],
  }

  service { 'haproxy':
    ensure  => 'running',
    enable  => true,
    require => Package['haproxy'],
  }

  # Instalar screen para simular consolas
  package { 'screen':
    ensure => 'installed',
  }

  exec { 'start_service_instances':
    command => 'screen -d -m /bin/bash -c "cd /home/vagrant/consulService/app && node index.js 3000"',
    path    => ['/usr/local/bin', '/usr/bin'],
    require => [Package['nodejs'], Package['npm']],
  }

  # Repetir el comando para cada instancia adicional
  exec { 'start_service_instance_3001':
    command => 'screen -d -m /bin/bash -c "cd /home/vagrant/consulService/app && node index.js 3001"',
    path    => ['/usr/local/bin', '/usr/bin'],
    require => [Package['nodejs'], Package['npm']],
  }

  exec { 'start_service_instance_3002':
    command => 'screen -d -m /bin/bash -c "cd /home/vagrant/consulService/app && node index.js 3002"',
    path    => ['/usr/local/bin', '/usr/bin'],
    require => [Package['nodejs'], Package['npm']],
  }

}