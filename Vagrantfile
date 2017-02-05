# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrant Locomotive Engine.
# 1: configure the provider settings below
# 2: run `vagrant up` to create the machine and vagrant will automatically run setup.sh to
# provision it with all dependencies required to run our version of locomotive engine.
# 3: If you wish to change the provision after already using `vagrant up` you may use
# `vagrant reload --provision` to run setup.sh once again.

Vagrant.configure(2) do |config|
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  config.vm.box = "ubuntu/trusty64"
  config.vm.provision :shell, path: "setup.sh"
  config.vm.network :forwarded_port, guest: 80, host: 8080
  config.vm.network :private_network, ip: "192.168.68.8"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant.
  config.vm.provider "virtualbox" do |vb|
      vb.name = "locomotive_engine"
      vb.memory = "1024"
      vb.cpus = 1
      # Display the VirtualBox GUI when booting the machine
      vb.gui = true
  end
  # View the documentation for the provider you are using
  # for more information on available options.
end
