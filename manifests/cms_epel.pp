# rpmrepos::cms_epel
#
#   Enable the EPEL repositories mirrored by the CMS install servers (using 
#   yumrepo) and import relevant GPG keys.
#
# == Parameters
#
#   baseurl   http://cms-install.fnal.gov/cobbler/repo_mirror
#   enabled   Gets passed to yumrepo.  Default: true
#   itb       If 'true', points at the CMS ITB EPEL mirror rather than the
#             default (the non-ITB mirror updates more often).  Default: false
#   priority  What yum priority should this repo get?  Lower is "better".  
#             Default: 90
#   proxy     Gets passed to yumrepo.  Default: 'absent'
#
# == Requirements
#
#   You must be running a RHEL variant - CentOS, RHEL, Scientific, SLF, Oracle, 
#   Ascendos, etc
#
#   puppetlabs-stdlib
#
# == Usage Usage:
#
#   class { 'rpmrepos::cms_epel': itb => true }
#     -or-
#   include rpmrepos::cms_epel
#
class rpmrepos::cms_epel (
  $baseurl  = 'http://cms-install.fnal.gov/cobbler/repo_mirror',
  $enabled  = true,
  $itb      = false,
  $priority = '90',
  $proxy    = 'absent'
) {
  validate_bool   ($enabled, $itb)
  validate_string ($baseurl, $proxy, $priority)

  if $itb { $url = "${baseurl}/uscmst1-epel${::lsbmajdistrelease}-itb" }
  else    { $url = "${baseurl}/epel${::lsbmajdistrelease}/" }
  $gpgkey = "/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-${::os_maj_version}"

  if $::osfamily == 'RedHat' and $::operatingsystem != 'Fedora' {

    yumrepo { 'epel':
      descr          => "Extra Packages for Enterprise Linux ${::os_maj_version} - ${::architecture}",
      enabled        => $enabled,
      failovermethod => 'priority',
      gpgcheck       => '1',
      gpgkey         => $gpgkey,
      proxy          => $proxy,
      url            => $baseurl,
    }

    file { $gpgkey:
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => "puppet:///modules/rpmrepos/RPM-GPG-KEY-EPEL-${::os_maj_version}",
    }

    rpmrepos::rpm_gpg_key { "EPEL-${::os_maj_version}": path => $gpgkey }
  } else {
    notice ("${::operatingsystem}: not compatible with EPEL repo")
  }
}
