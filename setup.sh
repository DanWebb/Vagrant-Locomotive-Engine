#!/usr/bin/env bash

# Initial setup for an nginx server containing all dependencies required to run our
# version of locomotive engine up and running:
# Nginx Server
# Ruby 2.3.1 with rvm
# Ruby on rails 4.2.6
# Puma
# Mongo db 3
# locomotive engine

echo "Updating package listing"
apt-get --assume-yes update && apt-get upgrade

echo "Installing Dependancies"
apt-get --assume-yes install language-pack-en build-essential openssl libreadline6 libreadline6-dev curl libcurl4-openssl-dev git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion nodejs imagemagick

# RUBY & RVM
# ==================
echo "Removing any currently installed ruby version"
apt-get --assume-yes remove -y ruby

echo "Installing RVM"
# download gpg signature
curl -sSL https://rvm.io/mpapis.asc | sudo gpg --import -
# install rvm
curl -L get.rvm.io | bash -s stable
# load rvm
source /etc/profile.d/rvm.sh

echo "Installing ruby version 2.3.1"
rvm install 2.3.1
# make 2.3.1 the default ruby version
rvm use 2.3.1 --default

# RUBY ON RAILS
# ==================
# install rails dependancies
rvm rubygems current
# install ruby on rails version 4.2.6
gem install rails -v 4.2.6

# MONGODB
# ==================
echo "Installing MongoDB"
# import they key for the official MongoDB repository
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
# create a list file for MongoDB
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.2.list
# update the package list to include MongoDB and install it
apt-get --assume-yes update && apt-get upgrade
apt-get --assume-yes install mongodb

# LOCOMOTIVE ENGINE
# ==================
echo "Installing locomotive engine, a directory will be created at /var/www/locomotiveengine"
cd /var
mkdir www
cd www
# create a new rails app
rails new locomotiveengine --skip-bundle --skip-active-record
cd locomotiveengine
# add locomotive to the gemfile
echo "gem 'locomotivecms', '~> 3.2.0'" >> Gemfile
# bundle
bundle install
# run Locomotive installation generator
bundle exec rails generate locomotive:install
# second bundle install to add puma which the above command added
bundle install
# add secret key !change for production environments!
sed -i "/config.secret_key/c\config.secret_key = '6d080de470b56cac69fdf1d2ccaecab9e146b1c334fe7fb2810dfaff8fc9c83538bb7379f832229a3b8db6a2d58ddffa63e20ed72afee9a7a4c9bc3016367db4'" config/initializers/devise.rb
sed -i "/secret_key_base:/c\    secret_key_base: 6d080de470b56cac69fdf1d2ccaecab9e146b1c334fe7fb2810dfaff8fc9c83538bb7379f832229a3b8db6a2d58ddffa63e20ed72afee9a7a4c9bc3016367db4" config/secrets.yml
# precompile assets
RAILS_ENV=production bundle exec rake assets:precompile

# PUMA
# ==================
# Add puma config (change workers to match your cpu count)
echo "
    # Change to match your CPU core count
    workers 1

    # Min and Max threads per worker
    threads 1, 6

    app_dir = File.expand_path(\"../..\", __FILE__)
    shared_dir = \"#{app_dir}/shared\"

    # Default to production
    rails_env = ENV['RAILS_ENV'] || \"production\"
    environment rails_env

    # Set up socket location
    bind \"unix://#{shared_dir}/sockets/puma.sock\"

    # Logging
    stdout_redirect \"#{shared_dir}/log/puma.stdout.log\", \"#{shared_dir}/log/puma.stderr.log\", true

    # Set master PID and state locations
    pidfile \"#{shared_dir}/pids/puma.pid\"
    state_path \"#{shared_dir}/pids/puma.state\"
    activate_control_app
" > config/puma.rb
# create the directories referred to in the config
mkdir -p shared/pids shared/sockets shared/log
# install init script to start on boot
cd ~
wget https://raw.githubusercontent.com/puma/puma/master/tools/jungle/upstart/puma-manager.conf
wget https://raw.githubusercontent.com/puma/puma/master/tools/jungle/upstart/puma.conf
cp puma.conf puma-manager.conf /etc/init
# add our app to the list of apps puma manages
echo "/var/www/locomotiveengine" > /etc/puma.conf
# add the vagrant user to puma manager
sed -i "/setuid apps/c\setuid vagrant" /etc/init/puma.conf
sed -i "/setgid apps/c\setgid vagrant" /etc/init/puma.conf

# NGINX
# ==================
# install nginx
apt-get --assume-yes install nginx
# add a default vhost pointing to locomotive engine for all requests
echo "
    upstream app {
        # Path to Puma SOCK file, as defined previously
        server unix:/var/www/locomotiveengine/shared/sockets/puma.sock fail_timeout=0;
    }

    server {
        listen 80 default_server;
        server_name _;

        root /var/www/locomotiveengine/public;

        try_files \$uri/locomotive \$uri @app;

        location @app {
            proxy_pass http://app;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header Host \$http_host;
            proxy_redirect off;
        }

        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log;

        error_page 500 502 503 504 /500.html;
        client_max_body_size 4G;
        keepalive_timeout 10;
    }
" > /etc/nginx/sites-available/default

# start nginx
service nginx start

# make sure the puma server is running
start puma-manager

# Give the vagrant user permission to the locomotiveengine files
chown -R vagrant:vagrant /var/www

# final restart to make sure all updates have applied
service nginx restart

echo "
    Vagrant Locomotive Engine
    =================================

    The server is now accessible at http://192.168.68.8

    To ssh into the server run:
        vagrant ssh
"
