##### 安装 nginx

安装依赖包

```
yum install -y gcc gcc-c++ pcre pcre-devel zlib zlib-devel openssl openssl-devel wget net-tools lrzsz vim
```

安装

```
# 下载安装包
cd /usr/local/src
wget http://nginx.org/download/nginx-1.22.0.tar.gz
tar zxvf nginx-1.22.0.tar.gz
cd nginx-1.22.0

useradd -s /sbin/nologin www
mkdir /var/cache/nginx

#生成makefile文件
./configure \
--prefix=/usr/local/nginx \
--error-log-path=/data/log/nginx/error.log \
--http-log-path=/data/log/nginx/access.log \
--pid-path=/var/run/nginx.pid \
--lock-path=/var/run/nginx.lock \
--user=www \
--group=www \
--with-file-aio \
--with-threads \
--with-http_addition_module \
--with-http_auth_request_module \
--with-http_dav_module \
--with-http_flv_module \
--with-http_gunzip_module \
--with-http_gzip_static_module \
--with-http_mp4_module \
--with-http_random_index_module \
--with-http_realip_module \
--with-http_secure_link_module \
--with-http_slice_module \
--with-http_ssl_module \
--with-http_stub_status_module \
--with-http_sub_module \
--with-http_v2_module \
--with-mail \
--with-mail_ssl_module \
--with-stream \
--with-stream_realip_module \
--with-stream_ssl_module \
--with-stream_ssl_preread_module

make && make install
```

修改配置 user 改为 www

```
user  www;
```

创建 vhost

```	
server {
    listen       80;
    server_name  zabbix.example.com;

    root /data/html/zabbix;

    location / {
        index index.php;
    }

    location ~ \.php$ {
        try_files $uri = 404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }
}
```

创建 /usr/lib/systemd/system/nginx.service

```
[Unit]
Description=nginx
After=network.target
  
[Service]
Type=forking
ExecStart=/usr/local/nginx/sbin/nginx
ExecReload=/usr/local/nginx/sbin/nginx -s reload
ExecStop=/usr/local/nginx/sbin/nginx -s quit
PrivateTmp=true
  
[Install]
WantedBy=multi-user.target	
```

启动

```
systemctl start nginx
systemctl enable nginx
```

##### 安装 php

安装依赖

```
yum install -y epel-release
yum install -y libxml2 libxml2-devel openssl openssl-devel bzip2 bzip2-devel libcurl libcurl-devel libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel gmp gmp-devel libmcrypt libmcrypt-devel readline readline-devel libxslt libxslt-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel ncurses curl gdbm-devel db4-devel libXpm-devel libX11-devel gd-devel gmp-devel expat-devel xmlrpc-c xmlrpc-c-devel libicu-devel libmcrypt-devel libmemcached-devel sqlite-devel oniguruma oniguruma-devel
```

编译

> 不要更改 php 版本

```
cd /usr/local/src
wget https://www.php.net/distributions/php-7.2.34.tar.gz
tar zxvf php-7.2.34.tar.gz
cd php-7.2.34

./configure \
--prefix=/usr/local/php \
--with-config-file-path=/etc \
--enable-fpm \
--enable-inline-optimization \
--disable-debug \
--disable-rpath \
--enable-shared \
--enable-soap \
--with-libxml-dir \
--with-xmlrpc \
--with-openssl \
--with-mcrypt \
--with-mhash \
--with-pcre-regex \
--with-zlib \
--enable-bcmath \
--with-iconv \
--with-bz2 \
--enable-calendar \
--with-curl \
--with-cdb \
--enable-dom \
--enable-exif \
--enable-fileinfo \
--enable-filter \
--with-pcre-dir \
--enable-ftp \
--with-gd \
--with-openssl-dir \
--with-jpeg-dir \
--with-png-dir \
--with-zlib-dir \
--with-freetype-dir \
--enable-gd-native-ttf \
--enable-gd-jis-conv \
--with-gettext \
--with-gmp \
--with-mhash \
--enable-json \
--enable-mbstring \
--enable-mbregex \
--enable-mbregex-backtrack \
--with-libmbfl \
--with-onig \
--enable-pdo \
--with-mysqli=mysqlnd \
--with-pdo-mysql=mysqlnd \
--with-zlib-dir \
--with-readline \
--enable-session \
--enable-shmop \
--enable-simplexml \
--enable-sockets \
--enable-sysvmsg \
--enable-sysvsem \
--enable-sysvshm \
--enable-wddx \
--with-libxml-dir \
--with-xsl \
--enable-zip \
--enable-mysqlnd-compression-support \
--with-pear \
--enable-opcache

make && make install

cp php.ini-production /etc/php.ini
cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
cp /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf
cp sapi/fpm/php-fpm.service /usr/lib/systemd/system/php-fpm.service
```

设置环境变量  .bash_profile

```
PATH=$PATH:/usr/local/php/bin
export PATH
```

修改启动用户 /usr/local/php/etc/php-fpm.d/www.conf

```
user = www
group = www
```

修改 /etc/php.ini

```
post_max_size = 16M
max_execution_time = 300
max_input_time = 300
```

systemctl 启动

```
systemctl start php-fpm
systemctl enable php-fpm
```

命令启动

```
/usr/local/php/sbin/php-fpm
```

##### 安装 MySQL

解压安装包

```
cd /usr/local/src
wget https://cdn.mysql.com/Downloads/MySQL-8.0/mysql-8.0.29-1.el7.x86_64.rpm-bundle.tar
tar xvf mysql-8.0.29-1.el7.x86_64.rpm-bundle.tar
```

安装

```
# 删除 mariadb-libs
rpm -e --nodeps mariadb-libs

# 安装
rpm -ivh mysql-community-devel-8.0.29-1.el7.x86_64.rpm
rpm -ivh mysql-community-libs-compat-8.0.29-1.el7.x86_64.rpm
rpm -ivh mysql-community-common-8.0.29-1.el7.x86_64.rpm
rpm -ivh mysql-community-client-plugins-8.0.29-1.el7.x86_64.rpm
rpm -ivh mysql-community-libs-8.0.29-1.el7.x86_64.rpm
rpm -ivh mysql-community-client-8.0.29-1.el7.x86_64.rpm
rpm -ivh mysql-community-icu-data-files-8.0.29-1.el7.x86_64.rpm
rpm -ivh mysql-community-server-8.0.29-1.el7.x86_64.rpm
```

启动

```
systemctl start mysqld
systemctl enable mysqld
```

查看临时密码

```
grep pass /var/log/mysqld.log
```

修改密码

```
ALTER USER root@'localhost' IDENTIFIED BY 'MySQL8.0';
```

##### 安装 zabbix

安装依赖

```
yum install -y gcc gcc-c++ make unixODBC-devel net-snmp-devel libssh2-devel OpenIPMI-devel libevent-devel pcre-devel libcurl-devel curl-* net-snmp* libxml2-* wget tar 
```

编译

```
cd /usr/local/src/
wget https://cdn.zabbix.com/zabbix/sources/stable/6.0/zabbix-6.0.5.tar.gz
tar zxvf zabbix-6.0.5.tar.gz 
cd zabbix-6.0.5
mkdir -p /usr/local/zabbix
./configure --prefix=/usr/local/zabbix --enable-server --enable-agent --enable-agent2 --with-mysql --enable-ipv6 --with-net-snmp --with-libcurl --with-libxml2
make && make install
```

创建用户

```
groupadd --system zabbix
useradd --system -g zabbix -d /usr/lib/zabbix -s /sbin/nologin -c "Zabbix Monitoring System" zabbix
```

创建数据库

> 数据库字符集要正确

```
create user zabbix@'%' identified WITH mysql_native_password by 'MySQL8.0';
create database zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
grant all on zabbix.* to zabbix@'%';
flush privileges;
```

导入数据

```
mysql -u zabbix -p'MySQL8.0' zabbix < /usr/local/src/zabbix-6.0.5/database/mysql/schema.sql
mysql -u zabbix -p'MySQL8.0' zabbix < /usr/local/src/zabbix-6.0.5/database/mysql/images.sql
mysql -u zabbix -p'MySQL8.0' zabbix < /usr/local/src/zabbix-6.0.5/database/mysql/data.sql
```

修改 server 配置文件 zabbix_server.conf

```
DBHost=192.168.1.200
DBName=zabbix
DBUser=zabbix
DBPassword=MySQL8.0
```

修改 agent 配置文件 zabbix_agentd.conf

> hosts 添加主机名解析: 192.168.1.202	node02
>
> Hostnane 与 Dashboard 的 Host name 一致
>
> Interfaces -> IP address 写真实 IP 192.168.1.202

```
Server=192.168.1.202
ServerActive=192.168.1.202
Hostname=node02
```

创建 /usr/lib/systemd/system/zabbix_server.service

> 注意 PIDFile文件路径

```
[Unit]
Description=Zabbix Server
After=syslog.target
After=network.target
 
[Service]
Environment="CONFFILE=/usr/local/zabbix/etc/zabbix_server.conf"
Type=forking
PIDFile=/tmp/zabbix_server.pid
Restart=on-failure
KillMode=control-group
ExecStart=/usr/local/zabbix/sbin/zabbix_server -c $CONFFILE
ExecStop=/bin/kill -SIGTERM $MAINPID
RestartSec=10s
 
[Install]
WantedBy=multi-user.target                      
```

systemctl 启动 zabbix_server

```
systemctl start zabbix_server
systemctl enable zabbix_server
```

创建 /usr/lib/systemd/system/zabbix_agentd.service

> 注意 PIDFile文件路径

```
[Unit]
Description=Zabbix Agent
After=syslog.target
After=network.target

[Service]
Environment="CONFFILE=/usr/local/zabbix/etc/zabbix_agentd.conf"
Type=forking
PIDFile=/tmp/zabbix_agentd.pid
Restart=on-failure
KillMode=control-group
ExecStart=/usr/local/zabbix/sbin/zabbix_agentd -c $CONFFILE
ExecStop=/bin/kill -SIGTERM $MAINPID
RestartSec=10s

[Install]
WantedBy=multi-user.target
```

创建 /usr/lib/systemd/system/zabbix-agent2.service

> 注意 PIDFile文件路径

```
[Unit]
Description=Zabbix Agent 2
After=syslog.target
After=network.target

[Service]
Environment="CONFFILE=/usr/local/zabbix/etc/zabbix_agent2.conf"
EnvironmentFile=-/etc/sysconfig/zabbix-agent2
Type=simple
Restart=on-failure
PIDFile=/run/zabbix/zabbix_agent2.pid
KillMode=control-group
ExecStart=/usr/local/zabbix/sbin/zabbix_agent2 -c $CONFFILE
ExecStop=/bin/kill -SIGTERM $MAINPID
RestartSec=10s
User=zabbix
Group=zabbix

[Install]
WantedBy=multi-user.target
```

systemctl 启动 zabbix_agentd

```
systemctl start zabbix_agentd
systemctl enable zabbix_agentd
```

命令启动

```
# server
/usr/local/zabbix/sbin/zabbix_server -c /usr/local/zabbix/etc/zabbix_server.conf
# agent
/usr/local/zabbix/sbin/zabbix_agentd
```

拷贝 ui

```
mkdir /data/html
cp -R /usr/local/src/zabbix-6.0.5/ui /data/html/zabbix
chown -R www.www /data/html/zabbix
```


