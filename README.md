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
