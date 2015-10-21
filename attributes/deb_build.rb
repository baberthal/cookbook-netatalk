default['netatalk']['deb_build'] = {
  'source' => 'https://github.com/adiknoth/netatalk-debian.git',
  'user' => {
    'username' => 'builder',
    'home' => '/home/builder',
    'group' => 'builder'
  },
  'dependencies' => %w(build-essential
                       devscripts
                       debhelper
                       cdbs
                       autotools-dev
                       git
                       dh-buildinfo
                       libdb-dev
                       libwrap0-dev
                       libpam0g-dev
                       libcups2-dev
                       libkrb5-dev
                       libltdl3-dev
                       libgcrypt11-dev
                       libcrack2-dev
                       libavahi-client-dev
                       libldap2-dev
                       libacl1-dev
                       libevent-dev
                       d-shlibs
                       dh-systemd)
}
