# Vagrant Locomotive Engine
A [Vagrant](https://www.vagrantup.com/) configuration to run [Locomotive Engine](https://github.com/locomotivecms/engine). The provision (setup.sh) file may also be used to get locomotive engine running on servers outside of Vagrant.

## Getting Started

Vagrant Locomotive Engine requires recent versions of both [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/) to be installed.

Once Vagrant and VirtualBox are installed, download or clone this repository. You should then configure the provider settings in the `Vagrantfile` to match your environment and run `vagrant up` to automatically build and provision a virtualized Ubuntu server running nginx & locomotive engine.

## Provisioning

The setup.sh file will be used to set up and install all the required dependancies to run Locomotive Engine, It may be edited to suit preferences or the environment. setup.sh will automatically be run on the first `vagrant up`.

### Re-provision

If you wish to change the provision after already using `vagrant up` you may use `vagrant reload --provision` to run setup.sh once again.

### External Server (non vagrant)

As mentioned above the provision (setup.sh) file can be used outside of vagrant. If you wish to use this for a production environment it is recommended that you...

1. Review the contents of the setup.sh file
2. Set your own secret keys
3. Set the number of workers to match your servers cpu cores
4. Change mentions of the vagrant user to your own user
5. Run the commands under your own user manually one by one to make sure to fix any individual errors specific to your system as they appear.

### Common issues

#### Upstart
If you get the error “Unable to connect to Upstart: Failed to connect to socket /com/ubuntu/upstart: Connection refused“ when running `start puma-manager` it likely means you're running Ubuntu 15.04 or higher which uses systemd instead of upstart. To return to using upstart you can run
```
sudo apt-get install upstart-sysv
sudo update-initramfs -u
reboot
```

### nokogiri
If nokogiri isn't installing try `gem install nokogiri -v 1.6.8.1 -- --use-system-libraries`

### ExecJS
If you get the error `ExecJS::RuntimeError: (execjs):1 during assets:precompile` try running `node -v`. If this returns "The program 'node' is currently not installed." then run:
```
sudo apt-get install python-software-properties
curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash -
sudo apt-get install nodejs
```
`node -v` should then return your node version.

If there's still issues try using sudo i.e. `RAILS_ENV=production sudo bundle exec rake assets:precompile`

### Assets failing to load
In config/environments/production.rb set `config.serve_static_files` to true.

### Site not found \\[Domain]
If setting up a site with a domain remove the backslashes from the virtual host at /etc/nginx/sites-available/default
