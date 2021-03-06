###########################################
# Simple DEV lampstack
#
# - Base set up
# - Apache, Mysql, PHP (with apc) & some
#   basic utils
#
###########################################
group { 'puppet': ensure => present }
Exec { path => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ] }
File { owner => 0, group => 0, mode => 0644 }

###########################################
# Install xhprof for php profiling
# Requires composer
###########################################
class xhprof {

    # Create xhprof dir
    exec { 'xhprof_dir':
        command => '/bin/mkdir -p /var/xhprof'
    }

    # Copy xhprof composer.json
    file { '/var/xhprof/composer.json':
        source => [
            '/vagrant/conf/xhprof-composer.json',
        ],
        require => Exec['xhprof_dir'],
    }


    # Install xhprof using composer
    composer::run { 'xhprof_install':
        path => '/var/xhprof/',
        require => [
            Class['composer'],
            File['/var/xhprof/composer.json'],
        ],
        before => Exec['xhprof_so'],
    }

    # Build the module
    exec { 'xhprof_so':
        creates => '/usr/lib/php5/20100525/xhprof.so',
        cwd => '/var/xhprof/vendor/facebook/xhprof/extension',
        command => '/usr/bin/phpize && /bin/sh configure && /usr/bin/make && /usr/bin/make install',
    }

    # Install graphviz
    package { ['graphviz']:
        ensure  => installed,
        notify  => Service['apache2'],
    }

    # Symlink the xhprof HTML directory
    file { "/var/xhprof/xhprof_html":
        target =>  "/var/xhprof/vendor/facebook/xhprof/xhprof_html",
        ensure => link,
        owner  => 'vagrant',
        group  => 'vagrant',
        require => Exec['xhprof_dir'],
    }

    # Symlink the xhprof lib directory
    file { "/var/xhprof/xhprof_lib":
        target =>  "/var/xhprof/vendor/facebook/xhprof/xhprof_lib",
        ensure => link,
        owner  => 'vagrant',
        group  => 'vagrant',
        require => Exec['xhprof_dir'],
    }

    # Copy profiler header & footer files into place

    # Copy header
    file { "/var/xhprof/header.php":
        source => [
        "/vagrant/conf/xhprof/header.php",
        ],
        require => Exec['xhprof_dir'],
    }

    # Copy footer
    file { "/var/xhprof/footer.php":
        source => [
          "/vagrant/conf/xhprof/footer.php",
        ],
        require => Exec['xhprof_dir'],
    }

    # Create xhprof output tmp directory
    file { "/tmp/xhprof":
        ensure => "directory",
        owner  => "www-data",
        group  => "www-data",
        mode   => 755,
    }

    # Setup the xhprof vhost, use standard template
    apache::vhost { 'xhprof':
        docroot             => '/var/xhprof',
        port                => '8000',
        server_name         => 'xhprof',
        server_admin        => 'info@1024.lu',
        docroot_create      => true,
        priority            => '',
        template            => '/vagrant/conf/xhprof-vhost-template',
    }

    # Add xhprof ini and restart apache
    file { "/etc/php5/conf.d/xhprof.ini":
        source => [
          "/vagrant/conf/xhprof.ini",
        ],
        notify  => Service['apache2'],
    }
}


###########################################
# Some basic utils that we need or
# that could come in handy
###########################################
class util {

  package {
    [
        'curl',
        'vim',
        'tmux',
        'htop',
        'make',
        'git-core',
        'php-apc',
    ]:
    ensure  => present,
  }

}

###########################################
# Basic apache installation & VHOST setup
# using vhost template file in vagrant-dev/conf.
#
###########################################
class vhostsetup {

  apache::module { 'rewrite': }

  apache::vhost { 'ttf.dev':
    docroot             => '/var/www',
    server_name         => 'ttf.dev',
    serveraliases      => [
      'www.ttf.dev',
    ],
    server_admin        => 'info@1024.lu',
    docroot_create      => true,
    priority            => '',
    env_variables       => [
        'APP_ENV dev'
    ],
    template            => '/vagrant/conf/main-vhost-template',
  }
}

######################################
# Ensure the apt repository is up to date
######################################
class apt-get-update {

    # update package files
    exec { "apt-get-update":
        command => "/usr/bin/apt-get update",
        before => [
            Class['util'],
            Class['php'],
            Class['mysql'],
            Class['xhprof'],
            Class['apache']
        ]
    }

    # update the system, non-interactively
    exec { "apt-get-upgrade":
        command => "/usr/bin/apt-get -y upgrade",
        require => Exec['apt-get-update']
    }
}

######################################
# OK, now let's run all of the classes
# and modules
######################################

# Update the apt repository
include apt-get-update

# support all major APT repository management features,
# such as manipulating sources.list, pinning, adding keys..
#include apt

# Install common tools
include util

# Install and configure apache
class { 'apache': }

# Set a random password ( saved in /root/.my.cnf )
class { 'mysql':
    root_password => 'auto'
}

# Create a new grant and database
mysql::grant { 'db_dev':
  mysql_privileges => 'ALL',
  mysql_user     => 'dev',
  mysql_password => 'develop',
  mysql_host     => 'localhost',
  require  => Class['mysql'],
}

# Install php for apache
class { 'php' :
    service => 'apache',
}

# Install java, in order to be able to execute ant tasks that depend on it
class { "java" : }

# Install ant to be able to run tasks from the build.xml files
class { 'ant': }

# Install additional PHP modules, make sure this runs before composer installation!
php::module {
    [
        'cli',
        'dev',
        'mysql',
        'ldap',
        'json',
        'curl',
        'intl',
        'gd',
    ]:
    before => Class['composer'],
    notify => Service['apache2'],
}

# Set up xdebug
class { 'xdebug':
      service     => 'apache',
      install_cli => false
}

# Set up a default vhost for development
include vhostsetup

class { 'composer':
    install_location => '/usr/bin',
    filename => 'composer',
    require => [
        Package['curl'],
        Class['php'],   #php_modules
    ]
}

# Set up xhprof
include xhprof