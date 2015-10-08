<?php


//bash script will tar up the plugin and then execute magento-tar-to-connect.php

$home = getenv("HOME");
$plugin = getenv("PLUGIN") ? getenv("PLUGIN") : "plugin.tar";
$buildpath = getenv("BUILDPATH") ? getenv("BUILDPATH") : '/tmp/';

echo "\n - home = "  . $home;
echo  "\n - plugin name = " .$plugin;
echo  "\n - buildpath = " . $buildpath;
echo "\n";


return array(

//The base_dir and archive_file path are combined to point to your tar archive
//The basic idea is a seperate process builds the tar file, then this finds it

'base_dir'               => $buildpath,
'archive_files'          => $plugin,

//The Magento Connect extension name.  Must be unique on Magento Connect
//Has no relation to your code module name.  Will be the Connect extension name
'extension_name'         => 'codistoconnect',

//Your extension version.  By default, if you're creating an extension from a
//single Magento module, the tar-to-connect script will look to make sure this
//matches the module version.  You can skip this check by setting the
//skip_version_compare value to true
'extension_version'      => '1.1.26',
'skip_version_compare'   => true, //confirm this

//You can also have the package script use the version in the module you
//are packaging with.
'auto_detect_version'   => true,

//Where on your local system you'd like to build the files to
'path_output'            => $buildpath,

//Magento Connect license value.
'stability'              => 'stable',

//Magento Connect license value
'license'                => 'OSL-3.0',

//Magento Connect channel value.  This should almost always (always?) be community
'channel'                => 'community',

//Magento Connect information fields.
'summary'                => 'Fastest, Easiest eBay listing',
'description'            => 'CodistoConnect enables you to list on eBay in the simplest way possible with maximum performance',
'notes'                  => '',

//Magento Connect author information. If author_email is foo@example.com, script will
//prompt you for the correct name.  Should match your http://www.magentocommerce.com/
//login email address
'author_name'            => 'Codisto',
'author_user'            => 'Codisto', // confirm all this with James
'author_email'           => 'hello@codisto.com',

//PHP min/max fields for Connect.
'php_min'                => '5.2.0',
'php_max'                => '6.0.0',

//PHP extension dependencies. An array containing one or more of either:
//  - a single string (the name of the extension dependency); use this if the
//    extension version does not matter
//  - an associative array with 'name', 'min', and 'max' keys which correspond
//    to the extension's name and min/max required versions
//Example:
//    array('json', array('name' => 'mongo', 'min' => '$PLUGINVERSION', 'max' => '$PLUGINVERSION'))
'extensions'             => array()  // confirm
);
