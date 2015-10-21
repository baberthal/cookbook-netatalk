default['netatalk']['jessie']['pkg_base_url'] =
  'https://daniel-lange.com/software/netatalk/gcrypt'

default['netatalk']['jessie']['packages'] = [
  {
    name: 'libatalk16_3.1.7-1_amd64.deb',
    checksum: 'd813a8851e42f645cc5ed9ab94c329b4f3254fd87798af9b2eceb7708ad0591e'
  },
  {
    name: 'libatalk-dev_3.1.7-1_amd64.deb',
    checksum: '047c5dcee3f47e36e6bb8c8f2d23086cc6c0eddd85311b84544369ee10256232'
  },
  {
    name: 'netatalk_3.1.7-1_amd64.deb',
    checksum: 'd3b6b44371348b07fb7a61d1c1dff477d718b8fa3ce2f1f526032de22616f11f'
  }
]

default['netatalk']['jessie']['dependencies'] = %w(libcrack2
                                                   libmysqlclient18
                                                   libavahi-client3
                                                   libdbus-glib-1-2
                                                   avahi-daemon)
