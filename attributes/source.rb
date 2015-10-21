default['libtracker']['version'] = value_for_platform(
  'ubuntu' => {
    '< 15.04' => '0.16',
    '>= 15.04' => '1.0'
  },
  'default' => '1.0'
)

default['netatalk']['source']['version'] = '3.1.7'
default['netatalk']['source']['dependencies'] = value_for_platform_family(
  'rhel' => %w(rpm-build gcc make avahi-devel bison cracklib-devel dbus-devel
               dbus-glib-devel docbook-style-xsl flex libacl-devel libattr-devel
               libdb-devel libevent-devel libgcrypt-devel libxslt krb5-devel
               dconf mariadb-devel openldap-devel openssl-devel pam-devel
               quota-devel systemtap-sdt-devel tcp_wrappers-devel libtdb-devel
               tracker-devel),
  'debian' => %W(build-essential libevent-dev libssl-dev libgcrypt11-dev
                 libkrb5-dev libpam0g-dev libwrap0-dev libdb-dev libtdb-dev
                 libmysqlclient-dev libavahi-client-dev libacl1-dev libldap2-dev
                 libcrack2-dev systemtap-sdt-dev libdbus-1-dev
                 libdbus-glib-1-dev libglib2.0-dev tracker avahi-daemon
                 libtracker-sparql-#{node['libtracker']['version']}-dev
                 libtracker-miner-#{node['libtracker']['version']}-dev)
)

default['netatalk']['rpm_source']['url'] =
  'http://www003.upp.so-net.ne.jp/hat/files/netatalk-3.1.7-1.2.fc24.src.rpm'
default['netatalk']['rpm_source']['checksum'] =
  '368ff8543e4b06a1df991d4b6b3035f9e590790ab19a911dcc366cfab8aba231'

default['netatalk']['source']['url'] =
  'http://downloads.sourceforge.net/project/netatalk/netatalk/3.1.7/netatalk-3.1.7.tar.bz2' # rubocop:disable Metrics/LineLength
default['netatalk']['source']['checksum'] =
  'e4049399e4e7d477f843a9ec4bd64f70eb7c7af946e890311140fd8fbd4bc071'

default['netatalk']['source']['init_style'] = value_for_platform(
  'debian' => {
    '< 8.0' => 'debian-sysv',
    '>= 8.0' => 'debian-systemd'
  },
  'ubuntu' => {
    '< 15.04' => 'debian-sysv',
    '>= 15.04' => 'debian-systemd'
  }
)

default['netatalk']['source']['configuration'] = value_for_platform_family(
  'rhel' => [],
  'debian' => <<-EOCONF.chomp.gsub(/\n+/, ' ')
--with-init-style=#{node['netatalk']['source']['init_style']}
--without-libevent --without-tdb --with-cracklib --enable-krbV-uam
--with-pam-confdir=/etc/pam.d --with-dbus-sysconf-dir=/etc/dbus-1/system.d
--with-tracker-pkgconfig-version=#{node['libtracker']['version']}
  EOCONF
)
