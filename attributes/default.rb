default['arch'] = `uname -m`.strip
default['netatalk']['install_method'] = value_for_platform(
  %w(rhel centos fedora) => {
    'default' => 'rpm-src'
  },
  'debian' => {
    '>= 8.0' => 'package'
  },
  'default' => 'source'
)

default['netatalk']['package_name'] = 'netatalk'

default['netatalk']['built_rpms'] = []

case node['netatalk']['install_method']
when 'rpm-src', 'package'
  default['netatalk']['conf_file'] = '/etc/netatalk/afp.conf'
when 'source'
  default['netatalk']['conf_file'] = '/usr/local/etc/afp.conf'
end
