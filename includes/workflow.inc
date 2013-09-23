
/**
* Create wordflow datastream in the givin object
*
* @param string $xml
* @param $object
*/
function create_DS_workflow(
    $xml
    , $object
  )
{
    // Workflow Datastream.
    // Load $orlando_xml.
    $orlando_xml_doc = new DomDocument();
    $orlando_xml_doc->loadXML($xml);

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

