# == Define: icinga2::object::checkresultreader
#
# Manage Icinga 2 CheckResultReader objects.
#
# === Parameters
#
# [*ensure*]
#   Set to present enables the object, absent disables it. Defaults to present.
#
# [ceckresultreader_name*]
#   Set the Icinga 2 name of the ceckresultreader object. Defaults to title of the define resource.
#
# [*spool_dir*]
#   The directory which contains the check result files. Defaults to LocalStateDir + "/lib/icinga2/spool/checkresults/".
#
# [*target*]
#   Destination config file to store in this object. File will be declared the
#   first time.
#
# [*order*]
#   String or integer to set the position in the target file, sorted alpha numeric. Defaults to 10.
#
#
define icinga2::object::checkresultreader (
  Stdlib::Absolutepath               $target,
  Enum['absent', 'present']          $ensure                 = present,
  String                             $checkresultreader_name = $title,
  Optional[Stdlib::Absolutepath]     $spool_dir              = undef,
  Variant[String, Integer]           $order                  = '05',
){

  # compose the attributes
  $attrs = {
    'spool_dir'   => $spool_dir,
  }

  # create object
  icinga2::object { "icinga2::object::CheckResultReader::${title}":
    ensure      => $ensure,
    object_name => $checkresultreader_name,
    object_type => 'CheckResultReader',
    attrs       => delete_undef_values($attrs),
    attrs_list  => keys($attrs),
    target      => $target,
    order       => $order,
    notify      => Class['::icinga2::service'],
  }

  # import library
  concat::fragment { "icinga2::object::CheckResultReader::${title}-library":
    target  => $target,
    content => "library \"compat\"\n\n",
    order   => $order,
  }
}
