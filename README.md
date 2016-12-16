
CONTENTS OF THIS FILE
---------------------

 * summary
 * requirements
 * installation
 * configuration
 * troubleshooting

SUMMARY
-------

This drush script migrates orlando objects to cwrc objects and injests them into fedora.


REQUIREMENTS
------------

Islandora Module

INSTALLATION
------------

Download the CWRC Migration Batch module to sites/all/modules/

* To run the migration script enter the command in the command line
* Enable the cwrcmigration module and then run 

drush -u 1 cwrc_migration_batch_ingest path_to_directory name_of_mods_directory name_of_orlando_directory

* For Orlando Migration - install a XSLT v2.0 processor
  * Saxon-c: http://www.saxonica.com/saxon-c/index.xml
    * Follow instructions in "PHP extension" (make sure source proper php)
        http://www.saxonica.com/saxon-c/index.xml#installing
    * for XSLT Version: Saxon/C 1.0.2 running with Saxon-HE 9.6.0.9J from Saxonica may need :
      * Compile if not using PHP 5.5 and add additional libraries
        * yum install libgcj-devel.x86_64 glibc-devel.i686
      * https://saxonica.plan.io/issues/2907
        * sudo ln -s /usr/lib64/libsaxonhec.so /usr/lib64/libsaxonhec.
     


USAGE
-----

use the entity_to_DC.xslt from the cwrc_entities module

