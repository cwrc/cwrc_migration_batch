<?php

/**
 * @file
 * Custom CWRC drush scripts.
 */

/**
 * Implements hook_drush_command().
 */
function cwrc_migration_batch_drush_command() {
  $items = array();
  $items['cwrc_migration_batch_ingest_biography_writing'] = array(
    'description' => 'Ingest objects CWRC',
    'examples' => array(
      'drush -u 1 cwrc_migration_batch_ingest_biography_writing path_to_directory name_of_mods_directory name_of_orlando_directory collection_pid cModel_pid mods_to_dc_xsl default_XACML_policy_stream',
    ),
    'bootstrap' => DRUSH_BOOTSTRAP_MAX,
  );

  $items['cwrc_migration_batch_ingest_entities'] = array(
    'description' => 'Ingest objects CWRC',
    'examples' => array(
      'drush -u 1 cwrc_migration_batch_ingest_entities path_to_directory name_of_default_workflow_file collection_pid cModel_pid content_datascream_dsid content_datascream_label entity_to_dc_xslt_path',
    ),
    'bootstrap' => DRUSH_BOOTSTRAP_MAX,
  );


  $items['cwrc_migration_batch_ingest_cwrc_documents'] = array(
    'description' => 'Ingest objects - CWRC Documents',
    'examples' => array(
      'drush -u 1 cwrc_migration_batch_ingest_cwrc_documents path_to_directory name_of_default_workflow_file collection_pid cModel_pid content_datascream_dsid content_datascream_label content_to_mods_xslt_path mods_to_dc_xslt_path',
    ),
    'bootstrap' => DRUSH_BOOTSTRAP_MAX,
  );


  $items['cwrc_migration_batch_ingest_events_documentation'] = array(
    'description' => 'Ingest objects CWRC',
    'examples' => array(
      'drush -u 1 cwrc_migration_batch_ingest_events_documentation path_to_directory name_of_mods_directory name_of_orlando_directory collection_pid cModel_pid mods_to_dc_xsl default_XACML_policy_stream',
    ),
    'bootstrap' => DRUSH_BOOTSTRAP_MAX,
  );


  $items['cwrc_migration_batch_ingest_bibliography'] = array(
    'description' => 'Ingest objects CWRC',
    'examples' => array(
      'drush -u 1 cwrc_migration_batch_ingest_bibliography path_to_directory name_of_mods_directory name_of_legacy_directory collection_pid cModel_pid mods_to_dc_xsl default_XACML_policy_stream',
    ),
    'bootstrap' => DRUSH_BOOTSTRAP_MAX,
  );


  $items['cwrc_migration_batch_export_book'] = array(
    'description' => 'Export book objects objects CWRC',
    'examples' => array(
      'drush -u 1 cwrc_migration_batch_export_book path_to_list_of_book_PIDs destination_path',
    ),
    'bootstrap' => DRUSH_BOOTSTRAP_MAX,
  );

  $items['cwrc_migration_batch_reindex_list'] = array(
    'description' => 'Solr index objects',
    'examples' => array(
      'drush -u 1 cwrc_migration_batch_reindex_list path_to_list_of_book_PIDs',
    ),
    'bootstrap' => DRUSH_BOOTSTRAP_MAX,
  );



  return $items;
}


/** 
 * CWRC migration batch - entities Orlando
 *
 * @param string $path_to_file
 *   path to directory where migrated files are located.
 * @param string $collection_pid
 *   pid of the collection to add the object to 
 * @param string $cModel_pid
 *   pid of the cModel the object belongs to 
 * @param string $content_datastream_dsid
 *   id of the content datastream (dsid)
 * @param string $content_datastream_label
 *   label of the content datastream
 * @param string $entity_to_dc_xslt_path
 *   path to the cwrc_entities to DC XSLT file
 */
function drush_cwrc_migration_batch_ingest_entities(
    $path_to_file
    , $workflow_file
    , $collection_pid
    , $cModel_pid
    , $content_datastream_dsid
    , $content_datastream_label
    , $entity_to_dc_xslt_path
  ) 
{

  
  drush_print("CWRC Entities Migration batch");

  // Include modules.
  $connection = null;
  migration_init($connection);

  // Display the user.
  drush_print("User: " . $connection->connection->username);

  // Content Model.  Create the content model.
  // Collection.  Create the collection object.
  rels_setup ( $connection, $cModel_pid, $collection_pid);

  // setup XSL 
  // Get the path to the content_to_dc.xsl file.
  //$dc_xslt = "/transforms/entity_to_dc.xsl";
  // ../cwrc-entities/xslt/entity_to_dc.xml
  $dc_xslt
    = drupal_get_path('module', 'cwrc_entities') . '/' . $entity_to_dc_xslt_path;
  drush_print("XSLT DC: " . $dc_xslt);
  dc_xslt_setup($dc_xslt, $xslt_proc);

  // setup the default workflow
  // get the contents of the default workflow for an entity
  $path_to_workflow_file
      = drupal_get_path('module', 'cwrc_migration_batch') . $workflow_file
      ;
  drush_print("XSLT Workflow: " . $path_to_workflow_file);
  $workflow_xml = file_get_contents($path_to_workflow_file);


  // Set source directory for the content to ingest
  $cwrc_directory = $path_to_file;

  // Open the source direcotry and iterate through every file in the 
  // directory - one file maps to one Fedora 
  $src_dir_handle = opendir($cwrc_directory);

  // Counter for the number of files to migrate.
  $file_count = 0;
  $file_error_count = 0;
  while (FALSE !== ($file_name = readdir($src_dir_handle))) 
  {
    $pid = null;

    //PHP Fatal error:  Maximum execution time of 300 seconds exceeded
    // no effect when PHP is running in safe mode
    // http://php.net/manual/en/function.set-time-limit.php
    set_time_limit(5);

    drush_print($file_name);
    // If the file is a directory then continue to next file.
    if (is_dir($file_name)) {
      continue;
    }

    // generate an id for the object
    $pid = $connection->repository->getnextIdentifier("cwrc", TRUE);

    // load XML doc
    // Load cwrc xml from a file.
    $tmp = $cwrc_directory . $file_name;
    $cwrc_xml = file_get_contents($tmp);

    $cwrc_dom = new DOMDocument();
    $cwrc_dom->load($tmp);

    
    // build the DC content
    // Convert entity to DC.
    // Transform to DC xml.
    // Apply the stylesheet.
    $xslt_proc->setParameter( "", "PID_PARAM", $pid );
    $dc_xml = $xslt_proc->transformToXML($cwrc_dom);

    //print ("zzz " . $dc_xml);

    // set object title
    $title = get_dcTitle_from_dc($dc_xml);

    //print("dc:title extracted - \"$title\" \n");


    // We need to prepare a new object.
    $object
      = islandora_prepare_new_object(
        $pid 
        , $title
        , array()
        , array($cModel_pid)
        , array(
          array(
            'relationship' => 'isMemberOfCollection'
            , 'pid' => "$collection_pid"
          )
        )
      );


    // create content datastream
    $cwrc_ds = $object->constructDatastream($content_datastream_dsid, 'M');
    $cwrc_ds->label = $content_datastream_label;
    $cwrc_ds->mimeType = 'text/xml';
    $cwrc_ds->setContentFromString($cwrc_xml);
    $object->ingestDatastream($cwrc_ds);
 
    
    // create DC datastream
    create_DS_DC($dc_xml, $object);

    // Workflow Datastream.
    // We want to get all of the responsibilitie tags.
    // For each responsibility create a workflow element.
    // Create the MODS datastream.
    create_DS_workflow($workflow_xml, $object);

    // Create the Policy datastream.
//    if ( $policy != null && $policy!="NONE" ) 
//    {
//      create_DS_POLICY(
//        $policy 
//        , $object
//      );
//    }

    // Store the object.
    try {
      islandora_add_object($object);
      $file_count++;
      drush_print("pid=$pid title=\"$title\" was added. #{$file_count} file migrated.");
    }
    catch (Exception $e) {
      drush_print("pid=$pid title=\"$title\" was not added.");
      $file_error_count++;
      drush_print($e->getMessage());
    }

  }
  drush_print('Migration Complete');
  drush_print('Number of files migrated: ' . $file_count);
  drush_print('Number of errors: ' . $file_error_count);

}

/** 
 * CWRC migration batch - bibliography Orlando
 * assumes Orlando bibl have been converted into MODS
 * workflow is pulled from the legacy Orlando format stored in subdir
 *
 * @param string $path_to_file
 *   path to directory where migrated files are located.
 * @param string $mods_subdir
 *   sub directory where the MODS records reside
 * @param string $legacy_subdir
 *   sub directory where the legacy orlando records reside
 * @param string $collection_pid
 *   pid of the collection to add the object to 
 * @param string $cModel_pid
 *   pid of the cModel the object belongs to 
 * @param string $dc_xslt
 *   location of the DC XSLT transform 
 * @param string $policy
 *   location of the Fedora XACML policy 
 */
function drush_cwrc_migration_batch_ingest_bibliography (
    $path_to_file
    , $mods_subdir
    , $legacy_subdir 
    , $collection_pid
    , $cModel_pid
    , $dc_xslt
    , $policy 
  ) 
{
  drush_print("CWRC Bibliography Migration batch");

  // Include modules.
  $connection = null;
  migration_init($connection);

  // Display the user.
  drush_print("User: " . $connection->connection->username);

  // Content Model.  Create the content model.
  // Collection.  Create the collection object.
  rels_setup ( $connection, $cModel_pid, $collection_pid);

  // setup XSL 
  // Get the path to the content_to_dc.xsl file.
  $dc_xslt
      = drupal_get_path('module', 'cwrc_migration_batch') . '/' . $dc_xslt;
  dc_xslt_setup($dc_xslt, $xslt_proc);

  // Set source directory for the legacy Orlando content
  $legacy_dir = $path_to_file . "/" . $legacy_subdir . "/"; 

  // Set source directory for the content to ingest
  $cwrc_directory = $path_to_file . "/" . $mods_subdir . "/";

  // Open the source direcotry and iterate through every file in the 
  // directory - one file maps to one Fedora 
  $src_dir_handle = opendir($legacy_dir);

  // Counter for the number of files to migrate.
  $file_count = 0;
  $file_error_count = 0;
  while (FALSE !== ($file_name = readdir($src_dir_handle))) 
  {
    $pid = null;

    //PHP Fatal error:  Maximum execution time of 300 seconds exceeded
    // no effect when PHP is running in safe mode
    // http://php.net/manual/en/function.set-time-limit.php
    set_time_limit(5);

    drush_print($file_name);
    // If the file is a directory then continue to next file.
    if (is_dir($file_name)) {
      continue;
    }

    // generate an id for the object
    $pid = $connection->repository->getnextIdentifier("cwrc", TRUE);

    // load XML doc
    // Load cwrc xml from a file.
    $tmp = $cwrc_directory . $file_name;
    $cwrc_xml = file_get_contents($tmp);

    $cwrc_dom = new DOMDocument();
    $cwrc_dom->load($tmp);

    // load legacy XML doc
    // Load cwrc xml from a file.
    $tmp = $legacy_dir . $file_name;
    $legacy_xml = file_get_contents($tmp);

    
    // build the DC content
    // Convert entity to DC.
    // Transform to DC xml.
    // Apply the stylesheet.
    $xslt_proc->setParameter( "", "PID_PARAM", $pid );
    $dc_xml = $xslt_proc->transformToXML($cwrc_dom);

    //print ("zzz " . $dc_xml);

    // set object title
    $title = get_dcTitle_from_dc($dc_xml);

    //print("dc:title extracted - \"$title\" \n");


    // We need to prepare a new object.
    $object
      = islandora_prepare_new_object(
        $pid 
        , $title
        , array()
        , array($cModel_pid)
        , array(
          array(
            'relationship' => 'isMemberOfCollection'
            , 'pid' => "$collection_pid"
          )
        )
      );


    // create content datastream
    //$cwrc_ds = $object->constructDatastream('CWRC-CONTENT', 'M');
    $cwrc_ds = $object->constructDatastream('MODS', 'M');
    $cwrc_ds->label = $file_name;
    $cwrc_ds->mimeType = 'text/xml';
    $cwrc_ds->setContentFromString($cwrc_xml);
    $object->ingestDatastream($cwrc_ds);
 
    
    // create DC datastream
    create_DS_DC($dc_xml, $object);

    // Workflow Datastream.
    // We want to get all of the responsibilitie tags.
    // For each responsibility create a workflow element.
    // Create the MODS datastream.
    create_DS_workflow_from_Source($legacy_xml, $object);

    // Create the Policy datastream.
    if ( $policy != null && $policy!="NONE" ) 
    {
      create_DS_POLICY(
        $policy 
        , $object
      );
    }

    // Store the object.
    try {
      islandora_add_object($object);
      $file_count++;
      drush_print("pid=$pid title=\"$title\" was added. #{$file_count} file migrated.");
    }
    catch (Exception $e) {
      $file_error_count++;
      drush_print("pid=$pid title=\"$title\" was not added.");
      drush_print($e->getMessage());
    }

  }
  drush_print('Migration Complete');
  drush_print('Number of files migrated: ' . $file_count);
  drush_print('Number of errors: ' . $file_error_count);


}


/** 
 * CWRC migration batch - event / documentation Orlando
 * assumes Orlando bibl have been converted into MODS
 * workflow is pulled from the legacy Orlando format stored in subdir
 *
 * @param string $path_to_file
 *   path to directory where migrated files are located.
 * @param string $mods_subdir
 *   sub directory where the MODS records reside
 * @param string $legacy_subdir
 *   sub directory where the legacy orlando records reside
 * @param string $collection_pid
 *   pid of the collection to add the object to 
 * @param string $cModel_pid
 *   pid of the cModel the object belongs to 
 * @param string $dc_xslt
 *   location of the DC XSLT transform 
 * @param string $policy
 *   location of the Fedora XACML policy 
 */
function drush_cwrc_migration_batch_ingest_events_documentation (
    $path_to_file
    , $mods_subdir
    , $legacy_subdir 
    , $collection_pid
    , $cModel_pid
    , $dc_xslt
    , $policy 
  ) 
{
  drush_print("CWRC Event/Documentation Migration batch");

  // Include modules.
  $connection = null;
  migration_init($connection);

  // Display the user.
  drush_print("User: " . $connection->connection->username);

  // Content Model.  Create the content model.
  // Collection.  Create the collection object.
  rels_setup ( $connection, $cModel_pid, $collection_pid);

  // setup XSL 
  // Get the path to the content_to_dc.xsl file.
  $dc_xslt
      = drupal_get_path('module', 'cwrc_migration_batch') . '/' . $dc_xslt;
  dc_xslt_setup($dc_xslt, $xslt_proc);

  // Set source directory for the legacy Orlando content
  $legacy_dir = $path_to_file . "/" . $legacy_subdir . "/"; 

  // Set source directory for the content to ingest
  $mods_dir = $path_to_file . "/" . $mods_subdir . "/";

  // Open the source direcotry and iterate through every file in the 
  // directory - one file maps to one Fedora 
  $src_dir_handle = opendir($legacy_dir);

  // Counter for the number of files to migrate.
  $file_count = 0;
  $file_error_count = 0;
  while (FALSE !== ($file_name = readdir($src_dir_handle))) 
  {
    $pid = null;

    //PHP Fatal error:  Maximum execution time of 300 seconds exceeded
    // no effect when PHP is running in safe mode
    // http://php.net/manual/en/function.set-time-limit.php
    set_time_limit(5);

    drush_print($file_name);
    // If the file is a directory then continue to next file.
    if (is_dir($file_name)) {
      continue;
    }

    // generate an id for the object
    $pid = $connection->repository->getnextIdentifier("cwrc", TRUE);

    // load MODS doc
    // Load MODS xml from a file.
    $tmp = $mods_dir. $file_name;
    $mods_xml = file_get_contents($tmp);

    $mods_dom = new DOMDocument();
    $mods_dom->load($tmp);

    // load legacy XML doc
    // Load cwrc xml from a file.
    $tmp = $legacy_dir . $file_name;
    $legacy_xml = file_get_contents($tmp);

    
    // build the DC content
    // Convert MODS to DC.
    // Transform to DC xml.
    // Apply the stylesheet.
    $xslt_proc->setParameter( "", "PID_PARAM", $pid );
    $dc_xml = $xslt_proc->transformToXML($mods_dom);

    //print ("zzz " . $dc_xml);

    // set object title
    $title = get_dcTitle_from_dc($dc_xml);

    //print("dc:title extracted - \"$title\" \n");


    // We need to prepare a new object.
    $object
      = islandora_prepare_new_object(
        $pid 
        , $title
        , array()
        , array($cModel_pid)
        , array(
          array(
            'relationship' => 'isMemberOfCollection'
            , 'pid' => "$collection_pid"
          )
        )
      );


    // create content datastream
    $cwrc_ds = $object->constructDatastream('CWRC-CONTENT', 'M');
    $cwrc_ds->label = 'CWRC Event ' . $pid;
    $cwrc_ds->mimeType = 'text/xml';
    $cwrc_ds->setContentFromString($legacy_xml);
    $object->ingestDatastream($cwrc_ds);
 
    
    // create DC datastream
    create_DS_DC($dc_xml, $object);

    // create DC datastream
    create_DS_MODS($mods_xml, $object);

    // Workflow Datastream.
    // We want to get all of the responsibilitie tags.
    // For each responsibility create a workflow element.
    // Create the MODS datastream.
    create_DS_workflow_from_Source($legacy_xml, $object);

    // Create the Policy datastream.
    if ( $policy != null && $policy!="NONE" ) 
    {
      create_DS_POLICY(
        $policy 
        , $object
      );
    }

    // Store the object.
    try {
      islandora_add_object($object);
      $file_count++;
      drush_print("pid=$pid title=\"$title\" was added. #{$file_count} file migrated.");
    }
    catch (Exception $e) {
      $file_error_count++;
      drush_print("pid=$pid title=\"$title\" was not added.");
      drush_print($e->getMessage());
    }

  }
  drush_print('Migration Complete');
  drush_print('Number of files migrated: ' . $file_count);
  drush_print('Number of errors: ' . $file_error_count);

}



/** 
 * CWRC migration batch - biography / writing  Orlando
 * assumes Orlando bibl have been converted into MODS
 * workflow is pulled from the legacy Orlando format stored in subdir
 * the separate biography and writing docs for a person are
 * linked via RELS-EXT
 *
 * @param string $path_to_file
 *   path to directory where migrated files are located.
 * @param string $mods_subdir
 *   sub directory where the MODS records reside
 * @param string $legacy_subdir
 *   sub directory where the legacy orlando records reside
 * @param string $collection_pid
 *   pid of the collection to add the object to 
 * @param string $cModel_pid
 *   pid of the cModel the object belongs to 
 * @param string $dc_xslt
 *   location of the DC XSLT transform 
 * @param string $policy
 *   location of the Fedora XACML policy 
 */
function drush_cwrc_migration_batch_ingest_biography_writing (
    $path_to_file
    , $mods_subdir
    , $legacy_subdir 
    , $collection_pid
    , $cModel_pid
    , $dc_xslt
    , $policy 
  ) 
{
  drush_print("CWRC Biography / Writing Migration batch");

  // Include modules.
  $connection = null;
  migration_init($connection);

  // Display the user.
  drush_print("User: " . $connection->connection->username);

  // Content Model.  Create the content model.
  // Collection.  Create the collection object.
  rels_setup ( $connection, $cModel_pid, $collection_pid);

  // setup XSL 
  // Get the path to the content_to_dc.xsl file.
  $dc_xslt
      = drupal_get_path('module', 'cwrc_migration_batch') . '/' . $dc_xslt;
  dc_xslt_setup($dc_xslt, $xslt_proc);

  // Set source directory for the legacy Orlando content
  $legacy_dir = $path_to_file . "/" . $legacy_subdir . "/"; 

  // Set source directory for the content to ingest
  $mods_dir = $path_to_file . "/" . $mods_subdir . "/";

  // Open the source direcotry and iterate through every file in the 
  // directory - one file maps to one Fedora 
  $src_dir_handle = opendir($legacy_dir);

  // Counter for the number of files to migrate.
  $file_count = 0;
  $file_error_count = 0;
  while (FALSE !== ($file_name = readdir($src_dir_handle))) 
  {
    $pid = null;

    //PHP Fatal error:  Maximum execution time of 300 seconds exceeded
    // no effect when PHP is running in safe mode
    // http://php.net/manual/en/function.set-time-limit.php
    set_time_limit(5);

    drush_print($file_name);
    // If the file is a directory then continue to next file.
    if (is_dir($file_name)) {
      continue;
    }

    // generate an id for the object
    $pid = $connection->repository->getnextIdentifier("cwrc", TRUE);

    // Strip out the .xml from the file name and store in the variable.
    preg_match('/[a-z0-9-_]*/', $file_name, $object_name);
    // Strip out file name to get type -b(biography) or -w (writable).
    preg_match('/-[a-z]+/', $file_name, $object_type);

    $object_name = $object_name[0];
    $object_type = $object_type[0];


    $pid = "cwrc:$object_name";

    // If the object already exists then continue to next file.
    if (islandora_object_load($pid)) {
      drush_print("object $object_name is already in fedora");
      continue;
    }

    // load MODS doc
    // Load MODS xml from a file.
    $tmp = $mods_dir . $file_name;
    $mods_xml = file_get_contents($tmp);

    $mods_dom = new DOMDocument();
    $mods_dom->load($tmp);

    // load legacy XML doc
    // Load cwrc xml from a file.
    $tmp = $legacy_dir . $file_name;
    $legacy_xml = file_get_contents($tmp);

    
    // build the DC content
    // Convert MODS to DC.
    // Transform to DC xml.
    // Apply the stylesheet.
    $xslt_proc->setParameter( "", "PID_PARAM", $pid );
    $dc_xml = $xslt_proc->transformToXML($mods_dom);

    //print ("zzz " . $dc_xml);

    // set object title
    $title = get_dcTitle_from_dc($dc_xml);

    //print("dc:title extracted - \"$title\" \n");


    // We need to prepare a new object.
    $object
      = islandora_prepare_new_object(
        $pid 
        , $title
        , array()
        , array($cModel_pid)
        , array(
          array(
            'relationship' => 'isMemberOfCollection'
            , 'pid' => "$collection_pid"
          )
        )
      );


    // create content datastream
    $cwrc_ds = $object->constructDatastream('CWRC', 'M');
    $cwrc_ds->label = $file_name;
    $cwrc_ds->mimeType = 'text/xml';
    $cwrc_ds->setContentFromString($legacy_xml);
    $object->ingestDatastream($cwrc_ds);
 
    
    // create DC datastream
    create_DS_DC($dc_xml, $object);

    // create MODS datastream
    create_DS_MODS($mods_xml, $object);

    // Workflow Datastream.
    // We want to get all of the responsibilitie tags.
    // For each responsibility create a workflow element.
    // Create the MODS datastream.
    create_DS_workflow_from_Source($legacy_xml, $object);

    // Create the Policy datastream.
    if ( $policy != null && $policy!="NONE" ) 
    {
      create_DS_POLICY( $policy , $object);
    }


    // create relationships
    $object->relationships->add(FEDORA_RELS_EXT_URI, 'originalFile', $file_name);

    // We need to get the object_type and use the other type to set the
    // relationship.
    if ($object_type == '-b') {
      $other_object_type = '-w';
    }
    else {
      $other_object_type = '-b';
    }

    // Replace the file name.
    $other_pid = preg_replace('/-[a-z]+/', $other_object_type, $object_name);
    // Set the relationship to the other object type.
    $object->relationships->add(FEDORA_RELS_EXT_URI, 'isDependentOf', "cwrc:$other_pid");


    // Store the object.
    try {
      islandora_add_object($object);
      $file_count++;
      drush_print("pid=$pid title=\"$title\" was added. #{$file_count} file migrated.");
    }
    catch (Exception $e) {
      $file_error_count++;
      drush_print("pid=$pid title=\"$title\" was not added.");
      drush_print($e->getMessage());
    }

  }
  drush_print('Migration Complete');
  drush_print('Number of files migrated: ' . $file_count);
  drush_print('Number of errors: ' . $file_error_count);

}

/** 
 * CWRC migration batch - CWRC documents compatible with CWRC-Writer 
 *
 * @param string $path_to_file
 *   path to directory where migrated files are located.
 * @param string $collection_pid
 *   pid of the collection to add the object to 
 * @param string $cModel_pid
 *   pid of the cModel the object belongs to 
 * @param string $content_datastream_dsid
 *   id of the content datastream (dsid)
 * @param string $content_datastream_label
 *   label of the content datastream
 * @param string $entity_to_dc_xslt_path
 *   path to the cwrc_entities to DC XSLT file
 * @param string $schema_pid
 *   PID of the Object to reference for schema and css information 
 */
function drush_cwrc_migration_batch_ingest_cwrc_documents(
    $path_to_file
    , $workflow_file
    , $collection_pid
    , $cModel_pid
    , $content_datastream_dsid
    , $content_datastream_label
    , $content_to_mods_xslt_path
    , $mods_to_dc_xslt_path
    , $schema_pid
  ) 
{

  
  drush_print("CWRC documents compatible with CWRC-Writer Migration batch");

  // Include modules.
  $connection = null;
  migration_init($connection);

  // Display the user.
  drush_print("User: " . $connection->connection->username);

  // Content Model.  Create the content model.
  // Collection.  Create the collection object.
  rels_setup ( $connection, $cModel_pid, $collection_pid);

  // setup XSL 
  // Get the path to the mods_to_dc.xsl file.
  $dc_xslt
    = drupal_get_path('module', 'cwrc_migration_batch') .'/'. $mods_to_dc_xslt_path;
  drush_print("XSLT DC: " . $dc_xslt);
  dc_xslt_setup($dc_xslt, $xslt_dc_proc);

  // Get the path to the mods_to_dc.xsl file.
  $mods_xslt
    = drupal_get_path('module', 'cwrc_migration_batch') .'/'. $content_to_mods_xslt_path;
  drush_print("XSLT MODS: " . $mods_xslt);
  dc_xslt_setup($mods_xslt, $xslt_mods_proc);

  // setup the default workflow
  // get the contents of the default workflow for an entity
  $path_to_workflow_file
      = drupal_get_path('module', 'cwrc_migration_batch') .'/'. $workflow_file
      ;
  drush_print("Workflow: " . $path_to_workflow_file);
  $workflow_xml = file_get_contents($path_to_workflow_file);


  // Set source directory for the content to ingest
  $cwrc_directory = $path_to_file;

  // Open the source direcotry and iterate through every file in the 
  // directory - one file maps to one Fedora 
  $src_dir_handle = opendir($cwrc_directory);

  // Counter for the number of files to migrate.
  $file_count = 0;
  $file_error_count = 0;
  while (FALSE !== ($file_name = readdir($src_dir_handle))) 
  {
    $pid = null;
    $content_datastream_label = $file_name;

    //PHP Fatal error:  Maximum execution time of 300 seconds exceeded
    // no effect when PHP is running in safe mode
    // http://php.net/manual/en/function.set-time-limit.php
    set_time_limit(5);

    drush_print($file_name);
    // If the file is a directory then continue to next file.
    if (is_dir($file_name)) {
      continue;
    }

    // generate an id for the object
    $pid = $connection->repository->getnextIdentifier("cwrc", TRUE);

    // load XML doc
    // Load cwrc xml from a file.
    $tmp = $cwrc_directory . $file_name;
    $cwrc_xml = file_get_contents($tmp);
    
    //print ("zzz " . $cwrc_xml . "zzzzzzzzzzzzzz\n");

    $cwrc_dom = new DOMDocument();
    $cwrc_dom->loadXML($cwrc_xml);

    //print_r ("zzz " . $cwrc_dom . "zzzzzzzzzzzzzz\n");

    // build the MODS 
    // Convert content to MODS.
    // Transform to MODS xml.
    // Apply the stylesheet.
    $xslt_mods_proc->setParameter( "", "PID_PARAM", $pid );
    $mods_xml = $xslt_mods_proc->transformToXML($cwrc_dom);

    //print ("zzz " . $mods_xml . "zzzzzzzzzzzzzz\n");

    $mods_dom = new DOMDocument();
    $mods_dom->loadXML($mods_xml);
 
    // build the DC content
    // Convert MODS to DC.
    // Transform to DC xml.
    // Apply the stylesheet.
    $xslt_dc_proc->setParameter( "", "PID_PARAM", $pid );
    $dc_xml = $xslt_dc_proc->transformToXML($mods_dom);

    //print ("zzz " . $dc_xml);

    // set object title
    $title = get_dcTitle_from_dc($dc_xml);

    //print("dc:title extracted - \"$title\" \n");


    // We need to prepare a new object.
    $object
      = islandora_prepare_new_object(
        $pid 
        , $title
        , array()
        , array($cModel_pid)
        , array(
          array(
            'relationship' => 'isMemberOfCollection'
            , 'pid' => "$collection_pid"
          )
        )
      );


    // create content datastream
    $cwrc_ds = $object->constructDatastream($content_datastream_dsid, 'M');
    $cwrc_ds->label = $content_datastream_label;
    $cwrc_ds->mimeType = 'text/xml';
    $cwrc_ds->setContentFromString($cwrc_xml);
    $object->ingestDatastream($cwrc_ds);
 
    
    // create DC datastream
    create_DS_DC($dc_xml, $object);

    // create DC datastream
    create_DS_MODS($mods_xml, $object);

    // Workflow Datastream.
    // We want to get all of the responsibilitie tags.
    // For each responsibility create a workflow element.
    // Create the MODS datastream.
    create_DS_workflow($workflow_xml, $object);

    // create relationships
    $object->relationships->add(CWRC_RELS_EXT_URI, 'hasSchema', $schema_pid);

    // Create the Policy datastream.
//    if ( $policy != null && $policy!="NONE" ) 
//    {
//      create_DS_POLICY(
//        $policy 
//        , $object
//      );
//    }

    // Store the object.
    try {
      islandora_add_object($object);
      $file_count++;
      drush_print("pid=$pid title=\"$title\" was added. #{$file_count} file migrated.");
    }
    catch (Exception $e) {
      drush_print("pid=$pid title=\"$title\" was not added.");
      $file_error_count++;
      drush_print($e->getMessage());
    }

  }
  drush_print('Migration Complete');
  drush_print('Number of files migrated: ' . $file_count);
  drush_print('Number of errors: ' . $file_error_count);
  // unsure how to properly set policy - come combo of POLICY and RELS-EXT 
  // datastreams 
  drush_print("\n Next Steps: set permissions on the Collection and objects");

}


/**
 * CWRC migration batch - migration_init 
 *
 * @param string $connection
 *   tuque connection object
 */
function migration_init (
    &$connection
  )
{
  
  // https://groups.google.com/forum/#!topic/islandora-dev/1KyBnj7DjCQ
  global $user;
  drush_print($user->name);


  // Include modules.
  module_load_include('inc', 'islandora', 'includes/utilities');
  module_load_include('inc', 'cwrc_migration_batch', 'includes/workflow');
  module_load_include('inc', 'cwrc_migration_batch', 'includes/helpers');

  ini_set('max_execution_time', 300);


  // Get the tuque connection.
  $connection = islandora_get_tuque_connection();
  $connection->connection->username = $user->name;
  $connection->connection->password = $user->pass;
}

/**
 * CWRC setup
 *
 **/
function rels_setup (
    $connection 
    , $cModel_pid
    , $collection_pid
    )
{
  // Content Model.  Create the content model.
  if ( !islandora_object_load($cModel_pid) )
  {
    create_cModel($cModel_pid, $connection);
    drush_print("content model added - $cModel_pid");
  }
  else {
    drush_print("content model already exists - $cModel_pid");
  }

  // Collection.  Create the collection object.
  if ( !islandora_object_load($collection_pid) )
  {
    create_collection($collection_pid, $connection);
    drush_print("Collection added - $collection_pid");
  }
  else
  {
    drush_print("collection already exists - $collection_pid");
  }
}


/**
 * CWRC export batch - book objects
 *
 * $path_to_list_of_book_PIDs
 *  path to the list of book PIDs to export
 * $destination_path
 *  path to save the results
 */
function drush_cwrc_migration_batch_export_book (
  $path_to_list_of_book_PIDs
  , $destination_path
  )
{
  drush_print("CWRC Export Book Batch");

  // Include modules.
  module_load_include('inc', 'islandora_paged_content', 'includes/utilities');

  $connection = null;
  migration_init($connection);

  // Display the user.
  drush_print("User: " . $connection->connection->username);

  // open the input file for reading
  $handle_read = fopen("$path_to_list_of_book_PIDs", "r");

  $handle_write = null;

  // Counter for the number of files to migrate.
  $file_count = 0;
  $file_error_count = 0;
  $line = null;
  $tmp = null;
  while ($handle_read && ($line = fgets($handle_read)) !== false)
  {
    $pid = trim($line);

    //PHP Fatal error:  Maximum execution time of 300 seconds exceeded
    // no effect when PHP is running in safe mode
    // http://php.net/manual/en/function.set-time-limit.php
    set_time_limit(5);

    drush_print("[".$pid."]");


    // export the object.
    try {
      $book_object = islandora_object_load($pid);
      $current_pages = islandora_paged_content_get_pages($book_object);
      $handle_write = fopen($destination_path . "/" . $book_object->label."-".$pid, 'w+');
      $file_count++;
      foreach ($current_pages as $page)
      {
        $tmp = null;
        $tmp = islandora_object_load($page['pid']);
        fwrite($handle_write, $tmp['OCR']->content);
        drush_print("page={$page['page']} | label={$page['label']} | pid={$page['pid']} was added. #{$file_count} file exported.");
      }
      fclose($handle_write);
      drush_print("Book pid=$pid was exported. #{$file_count} file exported.");
    }
    catch (Exception $e) {
      $file_error_count++;
      drush_print("pid=$pid was not added.");
      drush_print($e->getMessage());
    }

  }
  drush_print('Migration Complete');
  drush_print('Number of files exported: ' . $file_count);
  drush_print('Number of errors: ' . $file_error_count);

}


/**
 * CWRC reindex list of objects (by PID)
 *
 * $path_to_list_of_book_PIDs
 *  path to the list of book PIDs to export
 */
function drush_cwrc_migration_batch_reindex_list(
  $path_to_list_of_book_PIDs
  )
{
  drush_print("CWRC reindex list ");

  // Include modules.

  $connection = null;
  migration_init($connection);

  // Display the user.
  drush_print("User: " . $connection->connection->username);

  // open the input file for reading
  $handle_read = fopen("$path_to_list_of_book_PIDs", "r");

  $handle_write = null;

  // Counter for the number of files to migrate.
  $file_count = 0;
  $file_error_count = 0;
  $line = null;
  $tmp = null;
  while ($handle_read && ($line = fgets($handle_read)) !== false)
  {
    $pid = trim($line);

    //PHP Fatal error:  Maximum execution time of 300 seconds exceeded
    // no effect when PHP is running in safe mode
    // http://php.net/manual/en/function.set-time-limit.php
    set_time_limit(5);

    drush_print("[".$pid."]");


    // export the object.
    try {
      $obj = islandora_object_load($pid);
      $file_count++;
      drush_print("Book pid=$pid was exported. #{$file_count} file exported.");
      drush_print($obj['WORKFLOW']->content);
      $obj['WORKFLOW']->setContentFromString($obj['WORKFLOW']->content);
    }
    catch (Exception $e) {
      $file_error_count++;
      drush_print("pid=$pid was not added.");
      drush_print($e->getMessage());
    }

    usleep(5000);
  }
  drush_print('Migration Complete');
  drush_print('Number of files: ' . $file_count);
  drush_print('Number of errors: ' . $file_error_count);

}


