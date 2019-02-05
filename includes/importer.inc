<?php

/**
 * @file
 * Defines the CwrcZipBatchImporter.
 */

/**
 * CWRC Zip file importer.
 */
class CwrcZipBatchImporter extends ZipBatchImporter {

  protected $itemClass = 'CwrcZipBatchImportObject';

  /**
   * {@inheritdoc}
   */
  public static function getForm(array &$form_state) {
    $form = parent::getForm($form_state);

    $form['fs']['#title'] = t('CWRC @original', array(
      '@original' => $form['fs']['#title'],
    ));
    $form['fs']['#description'] = '';

    $form['fs']['file']['#title'] = t('Upload the zip file containing files to ingest');
    $form['fs']['file']['#weight'] = 1;

    // Adding parameters/options.
    $form['fs']['parameters'] = array(
      '#type' => 'fieldset',
      '#title' => t('Ingest parameters'),
      '#collapsible' => TRUE,
      '#collapse' => FALSE,
      '#tree' => TRUE,
      '#weight' => 2,
    );

    // Cmodel customizations.
    $zip_importer_cmodel = $form['fs']['fs']['content_model'];
    $cmodel_description = $form['fs']['fs']['#description'];
    unset($form['fs']['fs']);
    $cmodel_table_options = $zip_importer_cmodel['#options'];
    $cm_options = array();
    foreach ($cmodel_table_options as $cmodel_pid => $option) {
      $cm_options[$cmodel_pid] = $option['title'] . " ({$cmodel_pid})";
    }
    // Moving namespace input into parameters fieldset + our customization.
    $form['fs']['parameters']['content_model'] = $zip_importer_cmodel;
    $form['fs']['parameters']['content_model']['#title'] = t('Content Model');
    $form['fs']['parameters']['content_model']['#description'] = $cmodel_description;
    $form['fs']['parameters']['content_model']['#weight'] = 1;
    $form['fs']['parameters']['content_model']['#multiple'] = FALSE;
    $form['fs']['parameters']['content_model']['#required'] = TRUE;
    $form['fs']['parameters']['content_model']['#type'] = 'select';
    $form['fs']['parameters']['content_model']['#options'] = $cm_options;
    $form['fs']['parameters']['content_model']['#ajax'] = array(
      'wrapper' => 'cwrc-migration-batch--cmodel-dependents-wrapper',
      'callback' => array(__CLASS__, 'cmodelDependentsAjaxCallback'),
    );

    // Namespace customizations.
    $ns_options = $form['fs']['namespace']['#options'];
    array_shift($ns_options);
    // Moving namespace input into parameters fieldset + our customization.
    $namespace = $form['fs']['namespace'];
    $namespace['#options'] = $ns_options;
    unset($form['fs']['namespace']);
    $form['fs']['parameters']['namespace'] = $namespace;
    $form['fs']['parameters']['namespace']['#required'] = TRUE;
    $form['fs']['parameters']['namespace']['#weight'] = 2;

    $form['fs']['submit']['#weight'] = 3;

    return $form;
  }

  /**
   * Cmodel dependents ajax callback.
   *
   * @param array $form
   *   The form array.
   * @param array $form_state
   *   The form state.
   *
   * @return array
   *   The xsl transform form element structure.
   */
  public static function cmodelDependentsAjaxCallback(array $form, array $form_state) {
    return $form['fs']['parameters']['cmodel_dependents'];
  }

  /**
   * {@inheritdoc}
   */
  public static function readyForBatch(array &$form_state) {
    $has_file = !empty($form_state['values']['file']);
    $parameters = !empty($form_state['values']['parameters']) ? $form_state['values']['parameters'] : array();
    $cmodel_pid = $parameters ? $parameters['content_model'] : '';
    $supported_cmodels = array(
      'cwrc:person-entityCModel',
      'cwrc:place-entityCModel',
      'cwrc:documentCModel',
    );
    $pass = TRUE;

    if (!$has_file) {
      form_set_error('file', t('Need a Zip file!'));
    }

    if (!in_array($cmodel_pid, $supported_cmodels) || empty($parameters['xsl_transform_dc'])) {
      form_set_error('parameters', t('The selected content model is not currently supported'));
      $pass = FALSE;
    }

    return $has_file && $pass;
  }

  /**
   * {@inheritdoc}
   */
  public static function getBatchInfo(array &$form_state) {
    $values = $form_state['values'];
    $parameters = $values['parameters'];

    // Load the file.
    $file = file_load($values['file']);
    // Grab the content models.
    $content_models = array($parameters['content_model']);

    $info = array(
      'file' => $file,
      'pid_namespace' => $parameters['namespace'],
      'content_model' => $content_models,
      'object_info' => static::getIngestInfo($file),
      'processed_objects' => array(),
    );
    return $info;
  }

  /**
   * {@inheritdoc}
   */
  protected static function getIngestInfo($file) {
    $info = array();
    try {
      $archiver = archiver_get_archiver($file->uri);
    }
    catch (Exception $e) {
      drupal_set_message(t('Error opening the provided Zip file.  Code: %code<br>Error message: @error', array(
        '%code' => $e->getCode(),
        '@error' => $e->getMessage(),
      )));
      return;
    }

    if (!$archiver) {
      drupal_set_message(t('Cannot extract %file, not a valid archive.', array(
        '%file' => $file->filename,
      )));
      return;
    }

    $files = $archiver->listContents();
    if (!$files) {
      drupal_set_message(t('Provided archive contains no files.'));
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

    foreach ($xml_files as $file_info) {
      $path_info = pathinfo($file_info->filename);
      $datastream_key = strtolower($path_info['extension']);
      $info[$file_info->uri][$datastream_key] = $file_info->name;
    }
    // Clean the files.
    file_unmanaged_delete_recursive($extraction_location);
    return $info;
  }

  public static function getXmlTransformOptions($cmodel) {
    $supported_cmodels = array(
      'cwrc:person-entityCModel',
      'cwrc:place-entityCModel',
    );
    if (!in_array($cmodel, $supported_cmodels)) {
      return array();
    }

    $path_cwrc_entities = drupal_get_path('module', 'cwrc_entities');
    $entity_to_dc = $path_cwrc_entities . '/xslt/entity_to_dc_TEI_support.xsl';
    $entity_to_dc_default = $path_cwrc_entities . '/xslt/entity_to_dc.xsl';
    return array(
      $entity_to_dc => $entity_to_dc,
      $entity_to_dc_default => $entity_to_dc_default,
    );
  }

  public static function getXmlTransformModsOptions($cmodel) {
    $supported_cmodels = array(
      'cwrc:documentCModel',
    );
    if (!in_array($cmodel, $supported_cmodels)) {
      return array();
    }

    $path = drupal_get_path('module', 'cwrc_migration_batch');
    $reed_entry_to_mods = $path . '/transforms/reed_entry2mods.xsl';
    $ceww_entry_to_mods = $path . '/transforms/ceww_entry2mods.xsl';
    $tei_to_mods = $path . '/transforms/tei2mods.xsl';
    return array(
      $reed_entry_to_mods => $reed_entry_to_mods,
      $tei_to_mods => $tei_to_mods,
    );
  }

}

class CwrcZipBatchImportObject extends ZipBatchImportObject {

  protected static $ENTITY2DCTEI = '';
  protected static $REEDENTRY2MODS = '';
  protected static $TEI2MODS = '';
  protected static $modulePath = '';

  /**
   * {@inheritdoc}
   */
  public static function initializePaths() {
    parent::initializePaths();

    if (self::$modulePath === '') {
      self::$modulePath = drupal_get_path('module', 'cwrc_migration_batch');

      if (self::$ENTITY2DCTEI === '') {
        $path = drupal_get_path('module', 'cwrc_entities');
        self::$ENTITY2DCTEI = $path . '/xslt/entity_to_dc_TEI_support.xsl';
      }

      if (self::$REEDENTRY2MODS === '') {
        self::$REEDENTRY2MODS = self::$modulePath . '/transforms/reed_entry2mods.xsl';
      }

      if (self::$TEI2MODS === '') {
        self::$TEI2MODS = self::$modulePath . '/transforms/tei2mods.xsl';
      }
    }
  }

}
