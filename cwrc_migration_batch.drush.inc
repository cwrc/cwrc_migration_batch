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

  return $items;
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

  // Include modules.
  module_load_include('inc', 'islandora', 'includes/utilities');
  ini_set('max_execution_time', 300);

  // Print script name.
  drush_print("CWRC migration batch");

  // Get the tuque connection.
  $connection = islandora_get_tuque_connection();
  // Display the user.
  drush_print("User: " . $connection->connection->username);

  // Orlando Content Model.  Create the Orlando content model.
  if (!islandora_object_load('cwrc:orlandoCModel')) {
    $orlando_content_model = $connection->repository->constructObject('cwrc:orlandoCModel');
    $orlando_content_model->owner = 'fedoraAdmin';
    $orlando_content_model->label = 'Orlando Content Model';
    $orlando_content_model->models = 'fedora-system:ContentModel-3.0';
    islandora_add_object($orlando_content_model);
    drush_print("Orlando content model added");
  }
  else {
    drush_print("Orlando contentmodel already exists");
  }

  // Orlando Collection.  Create the Orlando collection object.
  if (!islandora_object_load('cwrc:orlandoCollection')) {
    $orlando_collection = $connection->repository->constructObject('cwrc:orlandoCollection');
    $orlando_collection->owner = 'fedoraAdmin';
    $orlando_collection->label = 'Orlando Collection';
    $orlando_collection->models = 'fedora-system:ContentModel-3.0';

    // Create the Policy datastream for orlando collection.
    $path_to_xml_policy_file = drupal_get_path('module', 'cwrc_migration_batch') . '/xml/cwrc_migration_batch_XACML_Policy_Stream.xml';
    $policy_ds = new IslandoraXacml($orlando_collection, file_get_contents($path_to_xml_policy_file));
    $policy_ds->writeBackToFedora();

    islandora_add_object($orlando_collection);
    drush_print("Orlando Collection added");
  }
  else {
    drush_print("Orlando collection already exists");
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
    $object = islandora_prepare_new_object("cwrc:$object_name", $title, array(), array('cwrc:orlandoCModel'), array(array('relationship' => 'isMemberOfCollection', 'pid' => "cwrc:orlandoCollection")));

    // Create the MODS datastream.
    $mods_ds = $object->constructDatastream('MODS', 'M');
    $mods_ds->label = 'MODS Record';
    $mods_ds->mimeType = 'text/xml';
    $mods_ds->setContentFromString($mods_xml);
    $object->ingestDatastream($mods_ds);

    // Convert MODS to DC.
    // Get the path to the mods_to_dc.xsl file.
    $path_to_xsl_file = drupal_get_path('module', 'cwrc_migration_batch') . '/transforms/mods_to_dc.xsl';
    $xsl_doc = new DOMDocument();
    $xsl_doc->load($path_to_xsl_file);

    // Apply the stylesheet.
    $xslt_proc = new XSLTProcessor();
    $xslt_proc->importStylesheet($xsl_doc);
    // Transform to DC xml.
    $dc_xml = $xslt_proc->transformToXML($mods_xml_doc);

    // Create the DC datastream.
    $dc_ds = $object->constructDatastream('DC', 'M');
    $dc_ds->label = 'DC Record';
    $dc_ds->mimeType = 'text/xml';
    $dc_ds->setContentFromString($dc_xml);
    $object->ingestDatastream($dc_ds);

    // Create the Policy datastream.
    $path_to_xml_policy_file = drupal_get_path('module', 'cwrc_migration_batch') . '/xml/cwrc_migration_batch_XACML_Policy_Stream.xml';
    $policy_ds = new IslandoraXacml($object, file_get_contents($path_to_xml_policy_file));
    $policy_ds->writeBackToFedora();

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

    // Workflow Datastream.
    // Load $orlando_xml.
    $orlando_xml_doc = new DomDocument();
    $orlando_xml_doc->loadXML($orlando_xml);

    // We want to get all of the responsibilitie tags.
    $responsibility_tags = $orlando_xml_doc->getElementsByTagName('RESPONSIBILITY');

    $crwc_doc  = new DomDocument();
    $cwrc_element = $crwc_doc->createElement('cwrc');
    // For each responsibility create a workflow element.
    foreach ($responsibility_tags as $responsibility) {
      $cwrc_element->appendChild(create_workflow_element($crwc_doc, $responsibility));
    }
    $crwc_doc->appendChild($cwrc_element);
    $cwrc_xml = $crwc_doc->saveXML($crwc_doc);

    // Create the MODS datastream.
    $workflow_ds = $object->constructDatastream('WORKFLOW', 'M');
    $workflow_ds->label = 'WORKFLOW Record';
    $workflow_ds->mimeType = 'text/xml';
    $workflow_ds->setContentFromString($cwrc_xml);
    $object->ingestDatastream($workflow_ds);

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
 * Create_workflow_element.
 *
 * @param DomDocument $doc
 *   The cwrc document
 *
 * @param DomDocument $responsibility
 *   The responsibility document
 */
function create_workflow_element($doc, $responsibility) {

  // Create the workflow element/
  $workflow_element = $doc->createElement('workflow');

  // Human Tag.
  $human_element = $doc->createElement('human');
  $user_id = $responsibility->getAttributeNode('RESP')->value;
  // Set the user Id.
  $human_element->setAttribute('userID', $user_id);

  $date_tag = $responsibility->getElementsByTagName('DATE');
  $date = $date_tag->item(0)->getAttribute('VALUE');
  // Set the user Id.
  $human_element->setAttribute('date', $date);

  // Activity Tag.
  $activity_element = $doc->createElement('activity');
  $activity_category = get_activity_category($responsibility->getAttribute('WORKSTATUS'));
  // Set the category.
  $activity_element->setAttribute('category', $activity_category);

  // Set the status.
  $status = strtolower($responsibility->getAttribute('WORKVALUE'));
  $activity_element->setAttribute('status', $status);

  // Set the stamp.
  $stamp = get_stamp($responsibility->getAttribute('WORKSTATUS'));
  $activity_element->setAttribute('stamp', $stamp);

  // Notes Tag.
  $notes_element = $doc->createElement('note');
  $item_tag = $responsibility->getElementsByTagName('ITEM');
  if ($item_tag->length > 0) {
    $notes_element->nodeValue = htmlspecialchars($item_tag->item(0)->nodeValue);
  }

  // Build the human element.
  $human_element->appendChild($activity_element);
  $human_element->appendChild($notes_element);
  $workflow_element->appendChild($human_element);

  return $workflow_element;

}

/**
 * Get activity category.
 *
 * @param string $workstatus
 *   The workstatus of the responsibility
 */
function get_activity_category($workstatus) {

  static $activity_map;

  if (!isset($activity_map)) {
    $activity_map = create_activity_category_map();
  }

  if (array_key_exists($workstatus, $activity_map)) {
    $activity_category = $activity_map[$workstatus];
  }
  else {
    $activity_category = 'DEFAULT';
  }

  return $activity_category;
}

/**
 * Create activity category map.
 *
 * Create a map for the responsibility workstatus to crwc activity category.
 */
function create_activity_category_map() {

  $array = array(
    "RWT" => "content_contribution",
    "REV" => "content_contribution",
    "ENH" => "content_contribution",
    "CFT" => "metadata_contribution",
    "CFB" => "metadata_contribution",
    "RBV" => "metadata_contribution",
    "CFC" => "metadata_contribution",
    "OLD" => "content_contribution",
    "CAS" => "checked",
    "PUB" => "published",
    "SUB" => "created",
    "PUB-C" => "published",
    "PUB-I" => "published",
  );

  return $array;

}

/**
 * Get stamp.
 *
 * @param string $workstatus
 *   The workstatus of the responsibility
 */
function get_stamp($workstatus) {

  static $stamp_map;

  if (!isset($stamp_map)) {
    $stamp_map = create_stamp_map();
  }

  if (array_key_exists($workstatus, $stamp_map)) {
    $stamp = $stamp_map[$workstatus];
  }
  else {
    $stamp = 'DEFAULT';
  }

  return $stamp;
}

/**
 * Create stamp map.
 *
 * Create a map for the responsibility workstatus to crwc stamp.
 */
function create_stamp_map() {

  $array = array(
    "SMUR" => "niso:SMUR",
    "AM" => "niso:AM",
    "P" => "niso:P",
    "VoR" => "niso:VoR",
    "CVoR" => "niso:CVoR",
    "EVoR" => "niso:EVoR",
    "SUB" => "orl:SUB",
    "RWT" => "orl:RWT",
    "OLD" => "orl:RWT",
    "REV" => "orl:REV",
    "RBV" => "orl:RBV",
    "CAS" => "orl:CAS",
    "CFT" => "orl:CFT",
    "CFB" => "orl:CFB",
    "PUB" => "orl:PUB",
    "ENH" => "orl:ENH",
    "TC" => "orl:TC",
    "PUBR" => "orl:PUBR",
    "cre" => "cwrc:cre",
    "dep" => "cwrc:dep",
    "cvr" => "cwrc:cvr",
    "evr" => "cwrc:evr",
    "ckd" => "cwrc:ckd",
    "tag" => "cwrc:tag",
    "rights_asg" => "cwrc:rights_asg",
    "pub" => "cwrc:pub",
    "rev" => "cwrc:rev",
    "wdr" => "cwrc:wdr",
    "del" => "cwrc:del",
  );

  return $array;

}
