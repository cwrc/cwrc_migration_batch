
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

-To run the migration script enter the command in the command line
-Enable the cwrcmigration module and then run 

drush -u 1 cwrc_migration_batch_ingest path_to_directory name_of_mods_directory name_of_orlando_directory


USAGE
-----

use the entity_to_DC.xslt from the cwrc_entities module

