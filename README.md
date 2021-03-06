vagrant-1024-dev
================

Base LAMP (PHP) stack with vagrant that includes remote debugging, profiling with xhprof and composer for PHP package management.

## Spec

* __Apache httpd__
    * mod_rewrite  
    * mod_php  
    * Main virtualhost set up  
        * Document root /var/www/ (synced VM folder to $vagrantdir/dev)
        * Name ttf.dev
        * port 80
    * xhprof virtualhost  
        * Document root /var/xhprof/ 
        * Name xhprof
        * port 8000
* __MySQL__
* __PHP__
	* Composer
    * APC op-code cache  
    * XDebug - setup for remote debugging
    * __xhprof__ - PHP profiler, auto enabled for all PHP files served from /vagrant/www/
* __Basic utilities__  
    * git-core (for composer)
    * curl  
    * vim
* __Development Tools__
    * Apache ant - used for building projects' build targets
* __Networking__
    * VM Port 22 (ssh) traffic forwarded to port 2222 on host - ssh to localhost:2222 
    * VM Port 80 (http) traffic forwarded to port 8080 on host - point your browser at localhost:8080
    * VM Port 8000 (http) traffic forwarded to port 8000 on host - point your browser at localhost:8000


## Quick Guide

__Pre-requisites:__  
__1.__ Install VirtualBox  
__2.__ Install vagrant  

You can use an alternative base box if you wish otherwise it will default to tentwentyfour's Debian Wheezy (7.1) AMD64 box

Then ...
    
    # Clone the Vagrant LAMP stack configuration
    git clone --recursive https://github.com/tentwentyfour/vagrant-1024-dev.git
    # enter the cloned directory
    cd vagrant-1024-dev
    # Build the VM using vagrant
    vagrant up


## Attributions

* Forked from [pipe-devnull/vagrant-dev-lamp](https://github.com/pipe-devnull/vagrant-dev-lamp)
* Uses puppet modules from the [PuPHPet](https://puphpet.com/) project
* Uses the xhprof package from [packagist](https://packagist.org/packages/facebook/xhprof)
* Includes maestrodev's [puppet-ant](https://github.com/maestrodev/puppet-ant) and [puppet-wget](https://github.com/maestrodev/puppet-wget) modules