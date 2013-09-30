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
  $items['cwrc_migration_batch_ingest'] = array(
    'description' => 'Ingest objects from a zip file',
    'examples' => array(
      'drush -u 1 cwrc_migration_batch_ingest path_to_directory name_of_mods_directory name_of_orlando_directory',
    ),
    'bootstrap' => DRUSH_BOOTSTRAP_MAX,
  );

  $items['cwrc_migration_batch_ingest_entities'] = array(
    'description' => 'Ingest objects from a zip file',
    'examples' => array(
      'drush -u 1 cwrc_migration_batch_ingest_entities path_to_directory name_of_default_workflow_file_ name_of_orlando_directory collection_pid cModel_pid',
    ),
    'bootstrap' => DRUSH_BOOTSTRAP_MAX,
  );

  $items['cwrc_migration_batch_ingest_events'] = array(
    'description' => 'Ingest objects from a zip file',
    'examples' => array(
      'drush -u 1 cwrc_migration_batch_ingest_events path_to_directory name_of_mods_directory name_of_orlando_directory',
    ),
    'bootstrap' => DRUSH_BOOTSTRAP_MAX,
  );

  $items['cwrc_migration_batch_ingest_documentation'] = array(
    'description' => 'Ingest objects from a zip file',
    'examples' => array(
      'drush -u 1 cwrc_migration_batch_ingest_documentation path_to_directory name_of_mods_directory name_of_orlando_directory',
    ),
    'bootstrap' => DRUSH_BOOTSTRAP_MAX,
  );

  $items['cwrc_migration_batch_ingest_bibliography'] = array(
    'description' => 'Ingest objects from a zip file',
    'examples' => array(
      'drush -u 1 cwrc_migration_batch_ingest_bibliography path_to_directory name_of_mods_directory name_of_orlando_directory',
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
 * @param string $mods_directory
 *   name of the mods directory.
 * @param string $orlando_directory
 *   name of the orlando directory.
 */
function drush_cwrc_migration_batch_ingest_entities(
    $path_to_file
    , $workflow_file
    , $orlando_directory
    , $collection_pid
    , $cModel_pid
  ) 
{
  drush_print("CWRC Entities Migration batch");

  // Include modules.
  $connection = null;
  migration_init($connection);

  // Display the user.
  drush_print("User: " . $connection->connection->username);

  /*
  // Orlando Content Model.  Create the Orlando content model.
  if ( !islandora_object_load($cModel_pid) ) 
  {
    create_cModel($tmp_cModel_pid);
    drush_print("Orlando content model added - $cModel_pid");
  }
  else {
    drush_print("Orlando contentmodel already exists - $cModel_pid");
  }

  // Orlando Collection.  Create the Orlando collection object.
  if ( !islandora_object_load($collection_pid) ) 
  {
    create_collection($collection_pid);
    drush_print("Orlando Collection added - $collection_pid");
  }
  else
  {
    drush_print("Orlando collection already exists - $collection_pid");
  }
  */

  // setup XSL 
  // Get the path to the content_to_dc.xsl file.
  $dc_xslt = "entity_to_dc.xsl";
  $path_to_xsl_file
      = drupal_get_path('module', 'cwrc_migration_batch') . $dc_xslt
      ;
  $xsl_doc = new DOMDocument();
  $xsl_doc->load($path_to_xsl_file);

  $xslt_proc = new XSLTProcessor();
  $xslt_proc->importStylesheet($xsl_doc);

  // setup the default workflow
  // get the contents of the default workflow for an entity
  $path_to_workflow_file
      = drupal_get_path('module', 'cwrc_migration_batch') . $workflow_file
      ;
  $workflow_xml = file_get_contents($workflow_file);


  // Set source directory for the content to ingest
  $orlando_directory = $path_to_file . '/' . $orlando_directory . '/';

  // Open the source direcotry and iterate through every file in the 
  // directory - one file maps to one Fedora 
  $src_dir_handle = opendir($orlando_directory);

  // Counter for the number of files to migrate.
  $file_count = 0;
  while (FALSE !== ($file_name = readdir($src_dir_handle))) 
  {
    drush_print($file_name);
    // If the file is a directory then continue to next file.
    if (is_dir($file_name)) {
      continue;
    }

    // load XML doc
    $tmp = $orlando_directory . $file_name;
    // Load ORLANDO xml from a file.
    $orlando_xml = file_get_contents($file);

        // set object title
    $dc_xml_dom = new DOMDocument();
    $dc_xml_dom->loadXML($dc_xml);
    $dc_title_xpath = new DOMXpath($dc_xml_dom);
    $title = $dc_title_xpath->query('/oai_dc:dc/oai_dc:dc');

    // generate an id for the object
    $pid = $connection->repository->getnextIdentifier("cwrc", TRUE);

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
    
    // build the DC content
    // Convert MODS to DC.
    // Transform to DC xml.
    // Apply the stylesheet.
    $xslt_proc->setParameter( "", "PID_PARAM", $pid );
    $dc_xml = $xslt_proc->transformToXML($orlando_doc);



    // create content datastream
    $orlando_ds = $object->constructDatastream('CWRC-CONTENT', 'M');
    $orlando_ds->label = 'ORLANDO Record';
    $orlando_ds->mimeType = 'text/xml';
    $orlando_ds->setContentFromString($orlando_xml);
    $object->ingestDatastream($orlando_ds);
 
    
    // create DC datastream
    create_DS_DC($dc_xml, $object);


    // Create the Policy datastream.
    create_DS_POLICY(
      '/xml/cwrc_migration_batch_XACML_Policy_Stream.xml'
      , $object
    );

    // Workflow Datastream.
    // We want to get all of the responsibilitie tags.
    // For each responsibility create a workflow element.
    // Create the MODS datastream.
    create_DS_workflow($workflow_xml, $object);

    // Store the object.
    try {
      islandora_add_object($object);
      $file_count++;
      drush_print("cwrc:$object_name was added. #{$file_count} file migrated.");
    }
    catch (Exception $e) {
      drush_print("cwrc:$object_name was not added.");
      drush_print($e->getMessage());
    }
  }
  drush_print('Migration Complete');
  drush_print('Number of files migrated: ' . $file_count);
}

/** 
 * CWRC migration batch - events Orlando
 *
 * @param string $path_to_file
 *   path to directory where migrated files are located.
 * @param string $mods_directory
 *   name of the mods directory.
 * @param string $orlando_directory
 *   name of the orlando directory.
 */
function drush_cwrc_migration_batch_ingest_events (
    $path_to_file
    , $mods_directory
    , $orlando_directory
  ) 
{
  drush_print("CWRC Events Migration batch");

  // Include modules.
  $connection = null;
  migration_init($connection);

  // Display the user.
  drush_print("User: " . $connection->connection->username);

}

/** 
 * CWRC migration batch - documentation Orlando
 *
 * @param string $path_to_file
 *   path to directory where migrated files are located.
 * @param string $mods_directory
 *   name of the mods directory.
 * @param string $orlando_directory
 *   name of the orlando directory.
 */
function drush_cwrc_migration_batch_ingest_documentation (
    $path_to_file
    , $mods_directory
    , $orlando_directory
  ) 
{
  drush_print("CWRC Documentation Migration batch");

  // Include modules.
  $connection = null;
  migration_init($connection);

  // Display the user.
  drush_print("User: " . $connection->connection->username);

}

/** 
 * CWRC migration batch - bibliography Orlando
 *
 * @param string $path_to_file
 *   path to directory where migrated files are located.
 * @param string $mods_directory
 *   name of the mods directory.
 * @param string $orlando_directory
 *   name of the orlando directory.
 */
function drush_cwrc_migration_batch_ingest_bibliography (
    $path_to_file
    , $mods_directory
    , $orlando_directory
  ) 
{
  drush_print("CWRC bibligraphy Migration batch");

  // Include modules.
  $connection = null;
  migration_init($connection);

  // Display the user.
  drush_print("User: " . $connection->connection->username);

}

/**
 * CWRC migration batch.
 *
 * Ingests new objects from a directory that is from a zip file.
 *
 * @param string $path_to_file
 *   path to directory where migrated files are located.
 * @param string $mods_directory
 *   name of the mods directory.
 * @param string $orlando_directory
 *   name of the orlando directory.
 */
function drush_cwrc_migration_batch_ingest($path_to_file, $mods_directory, $orlando_directory) {

  // Print script name.
  drush_print("CWRC biography/writing migration batch");

  // Include modules.
  $connection = null;
  migration_init($connection);

  // Display the user.
  drush_print("User: " . $connection->connection->username);

  // Orlando Content Model.  Create the Orlando content model.
  $cModel_pid = 'cwrc:orlandoCModel';
  if (!islandora_object_load($cModel_pid)) {
    create_cModel($tmp_cModel_pid);
    drush_print("Orlando content model added - $cModel_pid");
  }
  else {
    drush_print("Orlando contentmodel already exists - $cModel_pid");
  }

  // Orlando Collection.  Create the Orlando collection object.
  $collection_pid = 'cwrc:orlandoCollection';
  if ( !islandora_object_load($collection_pid)) 
  {
    create_collection($collection_pid);
    drush_print("Orlando Collection added - $collection_pid");
  }
  else
  {
    drush_print("Orlando collection already exists - $collection_pid");
  }

  // Set the mods and orlando directories from parameters.
  $mods_directory = $path_to_file . '/' . $mods_directory . '/';
  $orlando_directory = $path_to_file . '/' . $orlando_directory . '/';

  // Open the mods directory.
  $mods = opendir($mods_directory);
  // Counter for the number of files to migrate.
  $file_count = 0;
  while (FALSE !== ($file_name = readdir($mods))) {
    drush_print($file_name);
    // If the file is a directory then continue to next file.
    if (is_dir($file_name)) {
      continue;
    }

    // Strip out the .xml from the file name and store in the variable.
    preg_match('/[a-z0-9-_]*/', $file_name, $object_name);
    // Strip out file name to get type -b(biography) or -w (writable).
    preg_match('/-[a-z]+/', $file_name, $object_type);

    $object_name = $object_name[0];
    $object_type = $object_type[0];

    // If the object already exists then continue to next file.
    if (islandora_object_load("cwrc:$object_name")) {
      drush_print("object $object_name is already in fedora");
      continue;
    }

    // Load Mods xml from a file.
    $mods_xml = file_get_contents($mods_directory . $file_name);

    // We need to get the Title from the mods document.
    $mods_xml_doc = new DOMDocument();
    $mods_xml_doc->loadXML($mods_xml);
    $mods_title_xpath = new DOMXpath($mods_xml_doc);
    $mods_title = $mods_title_xpath->query('/mods:mods/mods:titleInfo/mods:title');

    // Get the MODS title.
    $title = $mods_title->item(0)->nodeValue;

    // We need to prepare a new object.
    $object 
      = islandora_prepare_new_object(
        "cwrc:$object_name"
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

    // Create the MODS datastream.
    create_DS_MODS($mods_xml, $object);

    // Convert MODS to DC.
    // Get the path to the mods_to_dc.xsl file.
    // Transform to DC xml.
    // Create the DC datastream.
    create_DS_DC($mods_xml_doc, '/transforms/mods_to_dc.xsl', $object);

    // Create the Policy datastream.
    create_DS_POLICY(
      '/xml/cwrc_migration_batch_XACML_Policy_Stream.xml'
      , $object
    );

    // Orlando datastream.
    $file = $orlando_directory . $file_name;

    // Load ORLANDO xml from a file.
    $orlando_xml = file_get_contents($file);
    // Create the MODS datastream.
    $orlando_ds = $object->constructDatastream('CWRC-CONTENT', 'M');
    $orlando_ds->label = 'ORLANDO Record';
    $orlando_ds->mimeType = 'text/xml';
    $orlando_ds->setContentFromString($orlando_xml);
    $object->ingestDatastream($orlando_ds);

    // Workflow Datastream.
    // We want to get all of the responsibilitie tags.
    // For each responsibility create a workflow element.
    // Create the MODS datastream.
    create_DS_workflow($orlando_xml, $object);

    // Create relationships.
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
      drush_print("cwrc:$object_name was added. #{$file_count} file migrated.");
    }
    catch (Exception $e) {
      drush_print("cwrc:$object_name was not added.");
      drush_print($e->getMessage());
    }
  }
  drush_print('Migration Complete');
  drush_print('Number of files migrated: ' . $file_count);
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
  // Include modules.
  module_load_include('inc', 'islandora', 'includes/utilities');
  module_load_include('inc', 'cwrc_migration_batch', 'includes/workflow');
  module_load_include('inc', 'cwrc_migration_batch', 'includes/helpers');

  ini_set('max_execution_time', 300);


  // Get the tuque connection.
  $connection = islandora_get_tuque_connection();

}


