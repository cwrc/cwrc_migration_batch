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

/**
 * XSLT setup
 *
 * xslt_file path to the XSLT file to load
 *   
 **/
function xslt_setup (
    $xslt_file
    , &$xslt_proc
    )
{
  dc_xslt_setup($xslt_file, $xslt_proc);
}


/**
 * determine schema or use default
 *
 *
 */
function determine_schema_url_from_xml($content, $default_schema)
{
  $schema_url = $default_schema;
  $dom = new DOMDocument;
  $dom->LoadXML($content);

  $xpath = new DOMXPath($dom);
  $xpath_qry = "/processing-instruction('xml-model')";

  $tmp_array = $xpath->query($xpath_qry);

  // grab the first
  $pi_str = null;
  if ($tmp_array)
  {
    $pi_str = $tmp_array->item(0)->data;
    //drush_print($pi_str);
    preg_match("/href=[\'\"](.*?)[\'\"]/", $pi_str, $matches);
    if ($matches[1])
    {
      $schema_url = $matches[1];
    }
  }
  return $schema_url;
}

/**
 * use the object RELS-EXT to dermine the schema url 
 *
 * @return
 *    null if not found or not a Fedora external type datastream
 */
function determine_schema_url_from_rels_ext($object)
{
  module_load_include('inc', 'islandora_cwrc_writer', 'includes/utilities');
  
  $schema_url = null;

  $schema_pid = islandora_cwrc_writer_get_document_schema_pid($object);
  $schema_object = islandora_object_load($schema_pid);

  print_r( ($schema_obj['SCHEMA']) );

  // depending on the type of the SCHEMA datastream, find the url 
  if (
    $schema_object['SCHEMA']->controlGroup == 'X' 
    || $schema_object['SCHEMA']->controlGroup == 'M'
    ) 
  {
    $schema_url = islandora_cwrc_writer_get_absolute_url(
      "islandora/object/{$schema_object->id}/datastream/SCHEMA/view"
      );
  }
  else
  {
    $schema_url = $schema_object['SCHEMA']->url;
  }

  return $schema_url;
}


/**
 * determine schema or use default
 *
 *
 */
function validate_content(
    $content
    , $schema
    , $validation_url
    )
{
    $schema_type = "RNG_XML";

    $fields = array (
            "content" => $content
            , "sch" =>  $schema
            , "type" => $schema_type
            );
    $qry = http_build_query($fields, '');

    //print ($qry);
    //print "\n";

    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $validation_url);
    curl_setopt($ch, CURLOPT_HEADER, false);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS        , $qry        );
    curl_setopt($ch, CURLOPT_RETURNTRANSFER        , true        );
    //curl_setopt($ch, CURLOPT_SSLVERSION        , 3         );
    //curl_setopt($ch, CURLOPT_USERPWD, "$username:$password");
    //curl_setopt($ch, CURLOPT_HTTPAUTH, CURLAUTH_BASIC);
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION , true        ); // follow redirects
    curl_setopt($ch, CURLOPT_ENCODING       , ""        ); // handle all encodings
    //curl_setopt($ch, CURLOPT_CONNECTTIMEOUT , 120        ); // timeout on connect
    //curl_setopt($ch, CURLOPT_TIMEOUT        , 120        ); // timeout on response
    //curl_setopt($ch, CURLOPT_MAXREDIRS      , 10        ); // stop after 10 redirects
    //curl_setopt($ch, CURLOPT_SSL_VERIFYHOST , 1        );
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER , false        );

    $result = curl_exec($ch);

    if ($result === false)
    {
            print ( curl_error($ch) );
            print ("\n");
    }

    curl_close($ch);
    $result
        = str_replace(
            '<?xml version="1.0" encoding="UTF-8"?>'
            , ""
            , $result
            );
   
    return $result; 
}


/**
 * 
 *
 */
function add_entity_references_via_element(
    $content
    , $entity_cmodel
    , $element_name
    , $attr_new
    , $attr_src
    , $xquery_id 
    )
{
  $dom = new DOMDocument;
  $dom->loadXML($content);

  // get all the elements of the given name
  $nodes = $dom->getElementsByTagName($element_name);

  return add_entity_references(
    $nodes 
    , $dom
    , $entity_cmodel
    , $element_name
    , $attr_new
    , $attr_src
    , $xquery_id 
  );
  
}


/**
 * 
 *
 */
function add_entity_references_via_xpath(
    $content
    , $entity_cmodel
    , $xpath_str
    , $attr_new
    , $attr_src
    , $xquery_id 
    )
{
  $dom = new DOMDocument;
  $dom->loadXML($content);
  $xpath = new DOMXpath($dom);

  // get all the elements of the given name
  $xpath->registerNamespace('mods', "http://www.loc.gov/mods/v3"); 
  $nodes = $xpath->query($xpath_str);

  return add_entity_references(
    $nodes 
    , $dom
    , $entity_cmodel
    , "MODS Subject"
    , $attr_new
    , $attr_src
    , $xquery_id 
  );
}


/**
 * 
 *
 */
function add_entity_references(
    $nodes
    , $dom
    , $entity_cmodel
    , $context
    , $attr_new
    , $attr_src
    , $xquery_id 
    )
{
  if($nodes instanceof DOMNodeList)
  {
    // get the base of the entity uri
    $base_entity_url = variable_get('islandora_cwrc_writer_repository_base_object_url', '');

    foreach($nodes as $domElement)
    {
      $lookup_str = null;
      // find the string to use in the lookup of the URI
      if (empty($attr_src))
      {
        // if no attribute name passed in as the source for the lookup
        // use the text of the element
        $lookup_str = $domElement->nodeValue;
      }
      else if (!$domElement->hasAttribute($attr_src))
      {
        // is the attribute present that will be used to lookup the entity
        // if not, register error (or could try to build the standard
        // representation)
        drush_print("Error: [$context] not found with attribute [$attr_src] for [$domElement->nodeValue]");
      }
      else
      {
        // else use the value of the "$attr_src" - source attribute name value
        $lookup_str = $domElement->getAttribute($attr_src);
      }

      // lookup and set the URI reference
      if (!$domElement->hasAttribute($attr_new))
      {
        // is the new attribute already present?
        // if no then add based on a lookup in the entity set
        // lookup_entity_given_orlando_standard();
        $attr_ref_value = lookup_uri_by_string(
            $lookup_str
            , $entity_cmodel
            , $xquery_id
            );
        
        $tmp_array = json_decode($attr_ref_value);

        // may return a list of pids
        // grap the first that is present in Fedora 
        // json look like the following: { "pid" : [] }
        $pid = null;
        if ($tmp_array->pids)
        { 
          $iter = 0;
          do 
          {
            $tmp_pid = $tmp_array->pids[$iter];
            if (islandora_object_load($tmp_pid))
            {
              $pid = $tmp_array->pids[$iter];
            }
            $iter++;
          } while ($iter < count($tmp_array->pids) ) ;
        }

        if (!empty($attr_new) and !empty($pid))
        {
          // writin the entity uri (base + PID)
          $domElement->setAttribute($attr_new, $base_entity_url.$pid);
          drush_print("INFO: [$context] found with lookup [$lookup_str] for [$domElement->nodeValue] ref: [$pid]");
        }
        else
        {
          drush_print("ERROR: [$context] not found with lookup [$lookup_str] for [$domElement->nodeValue] ref: [$attr_ref_value]");
        }
      }
      else
      {
        drush_print("INFO: Already contains attribute [$attr_new] [$context] found with lookup [$lookup_str] ");
      }
    }
  }
  return $dom->saveXML();
}


/**
 * lookup the URL based on a unique string
 *
 */
function lookup_uri_by_string(
  $lookup_str
  , $entity_cmodel
  , $xquery_id
  )
{
  module_load_include('inc', 'islandora_cwrc_basexdb', 'includes/xmldb_endpoints');

  $result = null;
  if ($lookup_str)
  {
    $keyValueArray = array(
      "LOOKUP_STR" => "$lookup_str"
      , "CMODEL_STR" => "$entity_cmodel"
      );
    $result = islandora_cwrc_exec_xquery($xquery_id, $keyValueArray);
  }
  return $result;
} 


/**
 * build hash array of entry id's and associated file names
 * */
function build_hash_map(&$entries, $src_dir, $file_type, $file_sccs) {

    $src_dh = opendir($src_dir);
    while (FALSE !== ($file_name = readdir($src_dh))) {

        //drush_print($file_name."\n");

        // If the file is a directory then continue to next file.
        if (is_dir($file_name)) {
            continue;
        }

        //$file_name_xml = preg_replace('/(\.sgm)$/','.xml', $file_name);
        //print("xml:" . $file_name_xml."\n");

        $entry_id = preg_replace('/^([a-zA-Z_0-9]{6,6})-[wb]\.xml/','$1', $file_name);
        $entry_type = preg_replace('/^[a-zA-Z_0-9]{6,6}-([wb])\.xml/','$1', $file_name);                                        

        if (!empty($entries[$entry_id])) {
            $entries[$entry_id][$file_type] = $file_name;
            $entries[$entry_id][$file_sccs] = "s.".$entry_id."-".$entry_type.".sgm";
        } else {
            $entries[$entry_id] = array("$file_type" => "$file_name");
            $entries[$entry_id][$file_sccs] = "s.".$entry_id."-".$entry_type.".sgm";
        }                                                                                                                   
    }
    closedir($src_dh);
}
