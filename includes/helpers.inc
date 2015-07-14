<?php


/**
* Create content model
*
* @param string $pid
*   PID of the cModel
*
*/

function create_collection($pid, $connection) {
  // Orlando Collection.  Create the Orlando collection object.
    $orlando_collection = $connection->repository->constructObject($pid);
    $orlando_collection->owner = 'fedoraAdmin';
    $orlando_collection->label = 'Orlando Collection';
    $orlando_collection->models = 'fedora-system:ContentModel-3.0';

    // Create the Policy datastream for orlando collection.
    $path_to_xml_policy_file = drupal_get_path('module', 'cwrc_migration_batch') . '/xml/cwrc_migration_batch_XACML_Policy_Stream.xml';
    $policy_ds = new IslandoraXacml($orlando_collection, file_get_contents($path_to_xml_policy_file));
    $policy_ds->writeBackToFedora();

    islandora_add_object($orlando_collection);
}



/**
* Create collection 
*
* @param string $pid
*   PID of the cModel
*
*/
function create_cModel($pid, $connection) {
    $orlando_content_model = $connection->repository->constructObject($pid);
    $orlando_content_model->owner = 'fedoraAdmin';
    $orlando_content_model->label = 'Orlando Content Model';
    $orlando_content_model->models = 'fedora-system:ContentModel-3.0';
    islandora_add_object($orlando_content_model);

}

/**
* Create MODS datastream in the givin object
*
* @param string $mods_xml
* @param $object 
*/
function create_DS_MODS (
    $mods_xml
    , &$object
  )
{
    $mods_ds = $object->constructDatastream('MODS', 'M');
    $mods_ds->label = 'MODS Record';
    $mods_ds->mimeType = 'text/xml';
    $mods_ds->setContentFromString($mods_xml);
    $object->ingestDatastream($mods_ds);
}

/**
* Create DC datastream in the givin object
*
* @param string $mods_xml_doc
* @param $dc_xslt
*   XSLT to convert from the xml_doc to DC
* @param $object
*/
/*
function create_DS_DC (
    $xml_doc
    , $dc_xslt
    , &$object
  )
{
    // Convert MODS to DC.
    // Get the path to the mods_to_dc.xsl file.
    $path_to_xsl_file 
        = drupal_get_path('module', 'cwrc_migration_batch') . $dc_xslt 
        ;
    $xsl_doc = new DOMDocument();
    $xsl_doc->load($path_to_xsl_file);

    // Apply the stylesheet.
    $xslt_proc = new XSLTProcessor();
    $xslt_proc->importStylesheet($xsl_doc);
    // Transform to DC xml.
    $dc_xml = $xslt_proc->transformToXML($xml_doc);

    // Create the DC datastream.
    create_DC_DS($dc_xml, $object);
}
*/

/**
* Create DC datastream in the givin object
*
* @param string $xml_doc
* @param $object
*/
function create_DS_DC (
    $dc_xml
    , &$object
  )
{
    // Create the DC datastream.
    $dc_ds = $object->constructDatastream('DC', 'M');
    $dc_ds->label = 'Dublin Core Record';
    $dc_ds->mimeType = 'text/xml';
    $dc_ds->setContentFromString($dc_xml);
    $object->ingestDatastream($dc_ds);
}



/**
* Create POLICY datastream in the givin object
*
* @param string $mods_xml
* @param $object 
*/
function create_DS_POLICY (
    $path
    , &$object
  )
{
    $path_to_xml_policy_file 
        = drupal_get_path('module', 'cwrc_migration_batch') 
        . $path
        ;
    $policy_ds 
        = new IslandoraXacml(
            $object
            , file_get_contents($path_to_xml_policy_file)
            );
    $policy_ds->writeBackToFedora();
}

/**
 * get dc.title from dc
 *
 */
function get_dcTitle_from_dc (
    $dc_xml
  )
{
   // set object title
    $dc_xml_dom = new DOMDocument();
    $dc_xml_dom->loadXML($dc_xml);
    $dc_title_xpath = new DOMXpath($dc_xml_dom);
    $dc_title_xpath->registerNamespace("oai_dc", "http://www.openarchives.org/OAI/2.0/oai_dc/");
    $dc_title_xpath->registerNamespace("dc", "http://purl.org/dc/elements/1.1/");
    //$tmp = $dc_title_xpath->query('/oai_dc:dc/dc:title');
    //$tmp = $dc_title_xpath->query('/srw_dc:dcCollection/srw_dc:dc/dc:title');
    $tmp = $dc_title_xpath->query('//dc:title');

    $title = $tmp->item(0)->nodeValue;

    return $title;

}



/**
 * CWRC setup
 *
 * dc_xslt assumes drupal_get_path 
 *   drupal_get_path('module', 'cwrc_migration_batch') . $dc_xslt
 **/
function dc_xslt_setup (
    $dc_xslt
    , &$xslt_proc
    )
{
  // setup XSL
  // Get the path to the content_to_dc.xsl file.
  $xsl_doc = new DOMDocument();
  $xsl_doc->load($dc_xslt);

  $xslt_proc = new XSLTProcessor();
  $xslt_proc->importStylesheet($xsl_doc);

}

