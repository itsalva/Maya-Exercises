class mypuppet {
    # Include wget package for downloading later
    include ::wget
    # Install vim, curl, and git packages
    package { 'vim':
        ensure => 'installed',
    }

    package { 'curl':
        ensure => 'installed'
    }

    package { 'git':
        ensure => 'installed'
    }

    # Create the user 
    user { 'monitor':
        ensure => 'present',
        managehome => true,
    }

    # Create directory for scripts
    file { '/home/monitor/scripts':
        ensure => 'directory',
    }

    # Use wget to download memory_check.sh from githubraw
    wget::fetch { 'memory check shell script':
        source => 'https://githubraw.com/itsalva/Maya-Exercises/main/SEO%20Exercise%201-2/memory_check.sh',
        destination => '/home/monitor/scripts',
        timeout => 15,
    }

    # Create a directory for soft link
    file { '/home/monitor/src/':
        ensure => 'directory',
    }
    
    # Create soft link for memory_check.sh called my_memory_check.sh
    file { '/home/monitor/src/my_memory_check.sh':
        ensure => 'link',
        target => 'home/monitor/scripts/memory_check.sh -c 90 -w 60 -e email@mine.com',
    }

    # Cron job to run my_memory_check.sh every 10 minutes
    cron { 'memorychecker':
        command => 'home/monitor/src/my_memory_check.sh'
        minute => 10,
    }

    # Set timezone to PHT or UTC+8 using timezone module
    class { 'timezone':
        timezone => 'UTC+8',
    }

    # Use sudo to change hostname
    exec { 'change hostname':
      command => 'sudo hostnamect1 set-hostname bpx.server.local',
    }
}
