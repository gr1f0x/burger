# Update apt package index
apt_update 'update' do
    action :update
  end
  
  # Install Apache
  package 'apache2' do
    action :install
  end
  
  # Install MySQL Server
  mysql_service 'default' do
    port '3306'
    version '5.7'
    initial_root_password 'root_password'
    action [:create, :start]
  end
  
  # Install PHP and required modules
  package 'php' do
    action :install
  end
  
  package 'libapache2-mod-php' do
    action :install
    notifies :restart, 'service[apache2]'
  end
  
  package 'php-mysql' do
    action :install
  end
  
  # Configure Apache to serve PHP files
  file '/var/www/html/index.php' do
    content '<?php phpinfo(); ?>'
    owner 'root'
    group 'root'
    mode '0644'
    action :create
  end
  
  # Restart Apache
  service 'apache2' do
    action :restart
  end
  
  # Secure MySQL installation and create sample database and user
  execute 'mysql_secure_installation' do
    command "mysql_secure_installation --password=#{node['mysql']['server_root_password']}"
    action :run
    sensitive true
  end
  
  mysql_database 'sample_database' do
    connection(
      :host => '127.0.0.1',
      :username => 'root',
      :password => 'root_password'
    )
    action :create
  end
  
  mysql_database_user 'sample_user' do
    connection(
      :host => '127.0.0.1',
      :username => 'root',
      :password => 'root_password'
    )
    password 'user_password'
    database_name 'sample_database'
    privileges [:all]
    action :grant
  end
  