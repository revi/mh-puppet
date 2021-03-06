# class: irc::irclogbot
class irc::irclogbot {
    include ::irc

    file { '/etc/irclogbot':
        ensure => directory,
    }

    git::clone { 'mwclient':
        ensure    => present,
        directory => '/etc/irclogbot/mwclient',
        origin    => 'https://github.com/mwclient/mwclient',
        require   => File['/etc/irclogbot'],
    }

    $mirahezebots_password = hiera('passwords::irc::mirahezebots')
    $mirahezelogbot_password = hiera('passwords::mediawiki::mirahezelogbot')

    file { '/etc/irclogbot/adminlog.py':
        ensure => present,
        source => 'puppet:///modules/irc/logbot/adminlog.py',
        notify => Service['adminbot'],
    }

    file { '/etc/irclogbot/adminlogbot.py':
        ensure => present,
        source => 'puppet:///modules/irc/logbot/adminlogbot.py',
        mode   => '0755',
        notify => Service['adminbot'],
    }

    file { '/etc/irclogbot/config.py':
        ensure  => present,
        content => template('irc/logbot/config.py'),
        notify  => Service['adminbot'],
    }

    exec { 'IRCLogbot reload systemd':
        command     => '/bin/systemctl daemon-reload',
        refreshonly => true,
    }

    file { '/etc/systemd/system/adminbot.service':
        ensure => present,
        source => 'puppet:///modules/irc/logbot/adminbot.systemd',
        notify => Exec['IRCLogbot reload systemd'],
    }

    service { 'adminbot':
        ensure  => 'running',
        require => File['/etc/systemd/system/adminbot.service'],
    }

    icinga2::custom::services { 'IRC Log Bot':
        check_command => 'nrpe',
        vars          => {
            nrpe_command => 'check_irc_logbot',
        },
    }
}
