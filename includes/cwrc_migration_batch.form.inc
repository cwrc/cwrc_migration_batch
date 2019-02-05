<?php

/**
 * @file
 * Contain implementations of various batch forms.
 */

/**
 * Ingest generic form.
 *
 * @param array $form
 *   The form elements.
 * @param array $form_state
 *   The form state.
 *
 * @return array
 *   The form structure.
 */
function cwrc_migration_batch_ingest_generic_form(array $form, array &$form_state) {
  $form['file'] = array(
    '#type' => 'managed_file',
    '#title' => t('Upload the zip file containing files to ingest'),
    '#description' => t('Please upload the compressed/archived files containing the objects to ingest. <br/>Maximum file size: @size.', array(
      '@size' => file_upload_max_size(),
    )),
    '#upload_validators' => array(
      'file_validate_extensions' => array('zip'),
    ),
  );

  $form['options'] = array(
    '#type' => 'fieldset',
    '#title' => t('Ingest parameters'),
    '#collapsible' => TRUE,
    '#collapse' => FALSE,
    '#tree' => TRUE,
  );
  $form['options']['collection_pid'] = array(
    '#type' => 'textfield',
    '#title' => t('Collection'),
    '#attributes' => array(
      'placeholder' => t('search CWRC collections'),
    ),
    '#description' => t('Add objects to the given collection if PUC-C workflow.'),
    '#required' => TRUE,
    '#default_value' => 'ceww:ee081346-e5ba-4b95-a90a-33d127ea85c8',
    '#autocomplete_path' => 'islandora/basic_collection/find_collections_user',
  );
  $form['options']['cmodel_pid'] = array(
    '#type' => 'textfield',
    '#title' => t('cModel PID'),
    '#description' => t('cModel pid assignments.'),
    '#required' => TRUE,
    '#default_value' => 'cwrc:documentCModel',
  );
  $form['options']['main_ds_id'] = array(
    '#type' => 'textfield',
    '#title' => t('Main datastream ID'),
    '#description' => t('Id of the main datastream (where content XML stored).'),
    '#required' => TRUE,
    '#default_value' => 'CWRC',
  );
  $form['options']['namespace'] = array(
    '#type' => 'textfield',
    '#title' => t('Namespace'),
    '#description' => t('PID namespace.'),
    '#required' => TRUE,
    '#default_value' => 'ceww',
  );

  $path_cwrc_entities = drupal_get_path('module', 'cwrc_entities');
  $form['options']['xslt_to_dc'] = array(
    '#type' => 'textfield',
    '#title' => t('XSLT to DC path'),
    '#description' => t('Path to XSLT to convert mods to DC.'),
    '#required' => TRUE,
    '#default_value' => $path_cwrc_entities . '/xslt/entity_to_dc_TEI_support.xsl',
  );

  $form['submit'] = array(
    '#type' => 'submit',
    '#value' => t('Ingest'),
  );

  return $form;
}

/**
 * Validates cwrc_migration_batch_ingest_generic_form().
 */
function cwrc_migration_batch_ingest_generic_form_validate(array $form, array &$form_state) {
  $field = 'file';
  // Check if file uploaded OK.
  if (!($file = file_load($form_state['values'][$field]))) {
    form_set_error($field, t('A file must be uploaded.'));
  }
  elseif ($file->filemime !== 'application/zip') {
    form_set_error($field, t('Only .zip files extension are allowed.'));
  }
  else {
    // Set files to form_state, to process when form is submitted.
    $form_state['values'][$field] = $file;
  }
}

/**
 * Submit callback for cwrc_migration_batch_ingest_generic_form().
 */
function cwrc_migration_batch_ingest_generic_form_submit(array $form, array &$form_state) {
  $field = 'file';
  $values = $form_state['values'];
  $file = $values[$field];

  try {
    $file = is_numeric($file) ? file_load($file) : $file;
    $archiver = archiver_get_archiver($file->uri);
  }
  catch (Exception $e) {
    form_set_error($field, $e->getMessage());
    return;
  }

  if (!$archiver) {
    form_set_error($field, t('Cannot extract %file, not a valid archive.', array(
      '%file' => $file->filename,
    )));
    return;
  }
  $files = $archiver->listContents();
  if (!$files) {
    form_set_error($field, t('Provided archive contains no files.'));
    return;
  }

  $file_name = str_replace('.zip', '', $file->filename);
  $file_name = drupal_html_class($file_name);

  // Extraction directory.
  $uniq_id = substr(hash('sha256', drupal_get_hash_salt()), 0, 8);
  $directory = 'public://ingest-generic-extraction-' . $uniq_id;
  if (!file_exists($directory)) {
    mkdir($directory);
  }
  $extraction_location = $directory . '/' . $file_name;
  if (file_exists($extraction_location)) {
    file_unmanaged_delete_recursive($extraction_location);
  }
  $archiver->extract($extraction_location);
  $xml_files = file_scan_directory($extraction_location, '/\\.xml$/');

  $batch = array(
    'title' => t('Ingesting @main_ds_id', array(
      '@main_ds_id' => $values['options']['main_ds_id'],
    )),
    'operations' => array(),
    'finished' => 'cwrc_migration_batch_ingest_generic_form_batch_process_finished',
    'progress_message' => t('Ingested @current out of @total.'),
    'error_message' => t('An error occurred during the ingestion!'),
    'file' => drupal_get_path('module', 'cwrc_migration_batch') . '/includes/cwrc_migration_batch.form.inc',
  );

  $batch['operations'][] = array(
    'cwrc_migration_batch_ingest_generic_form_batch_init',
    array($values['options']),
  );

  foreach ($xml_files as $file) {
    $batch['operations'][] = array(
      'cwrc_migration_batch_ingest_generic_form_batch_process',
      array($file, $values['options']),
    );
  }

  batch_set($batch);
}

/**
 * Initialize the variables needed for the batch process.
 *
 * @param array $options
 *   Ingestion options.
 * @param array $context
 *   The batch context.
 */
function cwrc_migration_batch_ingest_generic_form_batch_init(array $options, array &$context) {
  $saxon_processor = new Saxon\SaxonProcessor();
  $connection = islandora_get_tuque_connection();
  $context['results']['connection'] = $connection;
  $context['results']['saxon_processor'] = $saxon_processor;
  $context['results']['to_mods_xslt_proc'] = $saxon_processor->newXsltProcessor();
  $context['results']['to_dc_xslt_proc'] = $saxon_processor->newXsltProcessor();
  $context['results']['schema_object'] = NULL;
  $context['results']['ingested_count'] = 0;
  $context['results']['failed_ingestion'] = array();

  if ($options['cmodel_pid'] === 'cwrc:documentCModel') {
    $context['results']['schema_object'] = islandora_object_load($options['schema_object']);
    $context['results']['mods_to_dc_xslt_proc'] = $saxon_processor->newXsltProcessor();
  }
}

/**
 * Process the batch.
 *
 * @param \stdClass $file
 *   The file object.
 * @param array $options
 *   Ingestion options.
 * @param array $context
 *   The batch context.
 */
function cwrc_migration_batch_ingest_generic_form_batch_process($file, array $options, array &$context) {
  module_load_include('inc', 'cwrc_migration_batch', 'includes/helpers');
  module_load_include('inc', 'islandora', 'includes/utilities');

  $cmodel_pid = $options['cmodel_pid'];
  $is_cwrc_document_cmodel = $cmodel_pid === 'cwrc:documentCModel';
  $collection_pid = (string) $options['collection_pid'];
  if ($is_cwrc_document_cmodel && empty($context['results']['schema_object'])) {
    $error_message = t('Failed to ingest @file - @filename. Collection PID: @pid. No schema provided.', array(
      '@pid' => $collection_pid,
      '@file' => $file->name,
      '@filename' => $file->filename,
    ));
    watchdog('cwrc_migration_batch', $error_message);
    $context['results']['failed_ingestion'][$file->filename] = array(
      'pid' => '<none>',
      'filename' => $file->filename,
      'title' => $file->name,
      'error_message' => $error_message,
    );
    return;
  }

  $pid = NULL;
  $connection = $context['results']['connection'];
  $saxon_processor = $context['results']['saxon_processor'];
  $to_mods_xslt_processor = $context['results']['to_mods_xslt_proc'];
  $to_dc_xslt_processor = $context['results']['to_dc_xslt_proc'];
  $schema_object = $context['results']['schema_object'];
  $datastream_id = $options['main_ds_id'];
  $cmodels = array($cmodel_pid);
  $options['xslt_to_dc'] = !empty($options['xslt_to_dc']) ? $options['xslt_to_dc'] : libraries_get_path('islandora_cwrc_xslt_library') . '/xslt/mods_to_dc.xsl';

  $to_dc_xslt_processor->compileFromFile($options['xslt_to_dc']);

  // Generate an id for the object.
  $pid = $connection->repository->getnextIdentifier($options['namespace'], TRUE);
  if (islandora_object_load($pid)) {
    $error_message = t('Failed to ingest @file - @filename, Object already ingested. Collection PID: @pid. No schema provided.', array(
      '@pid' => $collection_pid,
      '@file' => $file->name,
      '@filename' => $file->filename,
    ));
    watchdog('cwrc_migration_batch', $error_message);
    $context['results']['failed_ingestion'][$file->filename] = array(
      'pid' => $pid,
      'filename' => $file->filename,
      'title' => $file->name,
      'error_message' => $error_message,
    );
    return;
  }

  // Load xml from a file.
  $legacy_content = file_get_contents($file->uri);

  $xml_contents = array();
  if ($is_cwrc_document_cmodel) {
    $mods_to_dc_xslt_proc = $context['results']['mods_to_dc_xslt_proc'];
    $to_mods_xslt_processor->setSourceFromXdmValue(
      $saxon_processor->parseXmlFromString($legacy_content)
    );
    $xml_contents['mods'] = $to_mods_xslt_processor->transformToString();
    $mods_xml = $xml_contents['mods'];

    if (empty($mods_xml)) {
      $error_message = t("Failed to ingest @file - @filename, couldn't generate MODS xml. Collection PID: @pid. No schema provided.", array(
        '@pid' => $collection_pid,
        '@file' => $file->name,
        '@filename' => $file->filename,
      ));
      watchdog('cwrc_migration_batch', $error_message);
      $context['results']['failed_ingestion'][$file->filename] = array(
        'pid' => $pid,
        'filename' => $file->filename,
        'title' => $file->name,
        'error_message' => $error_message,
      );
      return;
    }
    $mods_to_dc_xslt_proc->setSourceFromXdmValue(
      $saxon_processor->parseXmlFromString($mods_xml)
    );
    $xml_contents['dc'] = $mods_to_dc_xslt_proc->transformToString();
    $dc_xml = $xml_contents['dc'];
  }
  elseif (!empty($options['xlst_to_mods'])) {
    // Build MODS XML.
    $to_mods_xslt_processor->compileFromFile($options['xlst_to_mods']);
    $xml_contents = _cwrc_migration_batch_ingest_generic_form_batch_process_build_mods($legacy_content, $pid, $to_mods_xslt_processor, $to_dc_xslt_processor, $saxon_processor);
    $dc_xml = $xml_contents['dc'];
  }
  else {
    $to_dc_xslt_processor->setParameter('PID_PARAM', $saxon_processor->createAtomicValue($pid));
    $to_dc_xslt_processor->setSourceFromXdmValue($saxon_processor->parseXmlFromString($legacy_content));
    $dc_xml = $to_dc_xslt_processor->transformToString();
  }

  if (empty($dc_xml)) {
    $error_message = t('Failed to create Dublin Core datastream content for @file - @filename. Check the file and try again. Collection PID: @pid', array(
      '@pid' => $collection_pid,
      '@file' => $file->name,
      '@filename' => $file->filename,
    ));
    watchdog('cwrc_migration_batch', $error_message);
    $context['results']['failed_ingestion'][$file->filename] = array(
      'pid' => $pid,
      'filename' => $file->filename,
      'title' => $file->name,
      'error_message' => $error_message,
    );
    return;
  }

  // Set object title.
  $dc_xml_dom = new DOMDocument();
  $dc_xml_dom->loadXML($dc_xml);
  $xpath = new DOMXpath($dc_xml_dom);
  $xpath->registerNamespace('oai_dc', 'http://www.openarchives.org/OAI/2.0/oai_dc/');
  $xpath->registerNamespace('dc', 'http://purl.org/dc/elements/1.1/');
  $label_node = $xpath->evaluate('/oai_dc:dc/dc:title/text()');
  $title = $label_node->item(0)->nodeValue;

  $relationships = array(
    array(
      'relationship' => 'isMemberOfCollection',
      'pid' => $collection_pid,
    ),
  );

  // Prepare a new Fedora object.
  $object = islandora_prepare_new_object($pid, $title, array(), $cmodels, $relationships);

  // Create content datastream with the legacy content.
  $cwrc_ds = $object->constructDatastream($datastream_id, 'M');
  $cwrc_ds->label = $datastream_id;
  $cwrc_ds->mimeType = 'text/xml';
  $cwrc_ds->setContentFromString($legacy_content);
  $object->ingestDatastream($cwrc_ds);

  // Create DC datastream.
  $dc_ds = $object->constructDatastream('DC', 'M');
  $dc_ds->label = 'Dublin Core Record';
  $dc_ds->mimeType = 'text/xml';
  $dc_ds->setContentFromString($dc_xml);
  $object->ingestDatastream($dc_ds);

  // Create MODS datastream.
  if (!empty($xml_contents['mods'])) {
    create_DS_MODS($xml_contents['mods'], $object);
  }

  if (!empty($schema_object)) {
    module_load_include('inc', 'islandora_cwrc_writer', 'includes/utilities');
    islandora_cwrc_writer_set_document_schema($object, $schema_object);
  }

  try {
    // Store the object.
    islandora_add_object($object);
    $context['results']['ingested_count']++;

    // Add a workflow stamp indicating that the object was ingested.
    $activity_params = array(
      'category' => 'published',
      'stamp' => 'cwrc:cre',
      'status' => 'c',
      'note' => 'Initial ingest into the CWRC repository.',
    );
    _cwrc_migration_batch_add_workflow($object, $activity_params);
  }
  catch (Exception $e) {
    watchdog('cwrc_migration_batch', 'File name: @file<br>Collection PID: @pid<br>Code: @code<br/>Message:<br>@message', array(
      '@code' => $e->getCode(),
      '@message' => $e->getMessage(),
      '@pid' => $collection_pid,
      '@file' => $file->name,
    ));
    $context['results']['failed_ingestion'][$pid] = array(
      'pid' => $pid,
      'filename' => $file->filename,
      'title' => $title,
      'error_message' => $e->getMessage(),
    );
  }
}

/**
 * Batch 'finished' callback.
 */
function cwrc_migration_batch_ingest_generic_form_batch_process_finished($success, $results, $operations) {
  if ($success) {
    drupal_set_message(t('Migration completed'));
    drupal_set_message(t('Number of files migrated: @count', array(
      '@count' => $results['ingested_count'],
    )));
    drupal_set_message(t('Number of errors: @count', array(
      '@count' => count($results['failed_ingestion']),
    )));
  }
  else {
    // An error occurred.
    // $operations contains the operations that remained unprocessed.
    $error_operation = reset($operations);
    drupal_set_message(
      t('An error occurred while processing @operation with arguments : @args',
        array(
          '@operation' => $error_operation[0],
          '@args' => print_r($error_operation[0], TRUE),
        )
      ),
      'error'
    );
  }
}

/**
 * Helper method to build a mods xml along with the dc one.
 */
function _cwrc_migration_batch_ingest_generic_form_batch_process_build_mods($content, $pid, $to_mods_xslt_proc, $to_dc_xslt_proc, $saxon_processor) {
  $xmls_content = array();
  $to_mods_xslt_proc->setSourceFromXdmValue($saxon_processor->parseXmlFromString($content));
  $xmls_content['mods'] = $to_mods_xslt_proc->transformToString();

  $to_dc_xslt_proc->setParameter('PID_PARAM', $saxon_processor->createAtomicValue($pid));
  $to_dc_xslt_proc->setSourceFromXdmValue($saxon_processor->parseXmlFromString($xmls_content['mods']));
  $xmls_content['dc'] = $to_dc_xslt_proc->transformToString();

  return $xmls_content;
}

/**
 * Implements hook_cwrc_search_display_blacklist_alter().
 */
function _cwrc_migration_batch_content_models_options() {
  module_load_include('inc', 'islandora', 'includes/utilities');

}

function _cwrc_migration_batch_add_workflow($object, $activity_params) {
  module_load_include('inc', 'islandora_workflow_rest', 'includes/cwrc_workflow');
  module_load_include('inc', 'islandora_workflow_rest', 'includes/basic_enum');
  module_load_include('inc', 'islandora_workflow_rest', 'includes/workflow_item');
  module_load_include('inc', 'islandora_workflow_rest', 'includes/utilities');

  try {
    if (!isset($object['WORKFLOW'])) {
      $workflow = CWRCWorkflowAPI::fromTemplate();
      CWRCWorkflowAPI::updateDatastream($workflow, $object);
    }
    else {
      $workflow = CWRCWorkflowAPI::fromDatastream($object['WORKFLOW']);
    }

    $entry = new WorkflowItem(WorkflowConst::WORKFLOW, array());
    $activity = new WorkflowItem(WorkflowConst::ACTIVITY, $activity_params);
    $assigned = NULL;

    $workflow->addWorkflowStep($object->id, $entry, $activity, $assigned);
    CWRCWorkflowAPI::updateDatastream($workflow, $object);
  }
  catch (Exception $e) {
    watchdog('cwrc_migration_batch', 'Failed to add activity. Details below<br/>Code: @code<br/>Message:<br>@message<br>@trace', array(
      '@code' => $e->getCode(),
      '@message' => $e->getMessage(),
      '@trace' => $e->getTraceAsString(),
    ));
  }
}
