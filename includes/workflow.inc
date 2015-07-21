<?php


/** 
* MRB -- Fri 27-Sep-2013
* Modified the PHP code to reflect changes in the workflow schema (the workflow schema
* is located at http://cwrc.ca/schema/workflow.rng); also added to the comments
*/

/**
* Create workflow datastream in the given object
*
* @param string $xml
* @param $object
*/
function create_DS_workflow(
    $xml
    , $object
  )
{
    // Create the WORKFLOW datastream
    $workflow_ds = $object->constructDatastream('WORKFLOW', 'M');
    $workflow_ds->label = 'WORKFLOW Record';
    $workflow_ds->mimeType = 'text/xml';
    $workflow_ds->setContentFromString($xml);
    $object->ingestDatastream($workflow_ds);
}


/**
* Create workflow datastream in the given object
*
* @param string $xml
* @param $object
*/
function create_DS_workflow_from_Source (
    $xml
    , $object
  )
{
    // Workflow datastream
    // Load $orlando_xml
    $orlando_xml_doc = new DomDocument();
    $orlando_xml_doc->loadXML($xml);
    // We want to get all of the responsibility tags
    $responsibility_tags = $orlando_xml_doc->getElementsByTagName('RESPONSIBILITY');

    $cwrc_doc  = new DomDocument("1.0", "UTF-8");
    $cwrc_pi = $cwrc_doc->createProcessingInstruction('xml-model', 'type="application/xml" href="http://cwrc.ca/schemas/workflow.rng" schematypens="http://relaxng.org/ns/structure/1.0"');
    $cwrc_doc->appendChild($cwrc_pi);
    $cwrc_element = $cwrc_doc->createElement('cwrc');
    // For each responsibility create a workflow element
    foreach ($responsibility_tags as $responsibility) {
      $cwrc_element->appendChild(create_workflow_element($cwrc_doc, $responsibility));
    }
    $cwrc_doc->appendChild($cwrc_element);
    $cwrc_xml = $cwrc_doc->saveXML($cwrc_doc);

    create_DS_workflow($cwrc_xml, $object);

}

/**
 * Create the workflow element
 *
 * @param DomDocument $doc
 *   The cwrc document
 *
 * @param DomDocument $responsibility
 *   The responsibility document
 */
function create_workflow_element($doc, $responsibility) {

  // Create the workflow element
  $workflow_element = $doc->createElement('workflow');

  // Set the userID attribute
  $user_id = $responsibility->getAttributeNode('RESP')->value;
  $workflow_element->setAttribute('userID', $user_id);

  // Set the date attribute
  $date_tag = $responsibility->getElementsByTagName('DATE');
  $date = $date_tag->item(0)->getAttribute('VALUE');
  if (!isset($date) or $date == "")
  {
    $date = date("Y-m-d",strtotime($date_tag->item(0)->nodeValue));
  }
  $workflow_element->setAttribute('date', $date);

  // Create the activity element
  $activity_element = $doc->createElement('activity');

  // Set the category attribute
  $activity_category = get_activity_category($responsibility->getAttribute('WORKSTATUS'));
  $activity_element->setAttribute('category', $activity_category);

  // Set the status attribute
  $status = strtolower($responsibility->getAttribute('WORKVALUE'));
  $activity_element->setAttribute('status', $status);

  // Set the stamp attribute
  $stamp = get_stamp($responsibility->getAttribute('WORKSTATUS'));
  $activity_element->setAttribute('stamp', $stamp);

  // Create the note element
  $note_element = $doc->createElement('note');
  $item_tag = $responsibility->getElementsByTagName('ITEM');
  if ($item_tag->length > 0) {
    $note_element->nodeValue = htmlspecialchars($item_tag->item(0)->nodeValue);
  }

  // Build the workflow element tree
  $activity_element->appendChild($note_element);
  $workflow_element->appendChild($activity_element);

  return $workflow_element;

}


/**
 * Get the activity category attribute value
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
 * Create an activity category map
 *
 * Create a map for the responsibility workstatus to cwrc activity category
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
 * Get the stamp attribute value
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
 * Create a stamp map
 *
 * Create a map for the responsibility workstatus to cwrc stamp
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

