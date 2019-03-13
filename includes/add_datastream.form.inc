<?php

/**
 * @file
 * Contains the implementation for adding a datastream using an xslt.
 */

/**
 * Islandora add datastream with XSLT form callback.
 */
function cwrc_migration_batch_islandora_add_datastream_form(array $form, array &$form_state, \IslandoraFedoraObject $object) {
  $cmodels = $object->models;
  $source_datastream_options = array();
  $values = !empty($form_state['values']) ? $form_state['values'] : array();
  $form['#islandora_object'] = $object;

  $form['introduction'] = array(
    '#markup' => t('<h2>Transform</h2>'),
  );

  if ($cmodels) {
    module_load_include('inc', 'islandora', 'includes/utilities');
    $supported_mime_types = ['text/xml', 'application/xml'];
    foreach ($cmodels as $cmodel_pid) {
      $cmodel = islandora_object_load($cmodel_pid);
      $cmodel_datastreams = islandora_get_datastreams_requirements_from_content_model($cmodel);
      if ($cmodel_datastreams) {
        foreach ($cmodel_datastreams as $datastream) {
          if ($datastream['id'] === 'RELS-EXT' || count($datastream['mime']) !== 1) {
            continue;
          }

          $mime_type = $datastream['mime'][0];
          if (empty($datastream['optional']) && in_array($mime_type, $supported_mime_types, TRUE)) {
            $source_datastream_options[$datastream['id']] = $datastream['id'];
          }
        }
      }
    }
  }
  $form['source_datastream'] = array(
    '#type' => 'select',
    '#title' => t('Source Datastream'),
    '#required' => TRUE,
    '#options' => $source_datastream_options,
    '#ajax' => array(
      'callback' => 'cwrc_migration_batch_islandora_add_datastream_xslt_select_ajax_callback',
      'wrapper' => 'cwrc-migration-batch--select-xslt-options-wrapper',
      'effect' => 'fade',
    ),
  );

  $form['select_xslt'] = array(
    '#type' => 'item',
    '#title' => t('Select xslt'),
    '#prefix' => '<div id="cwrc-migration-batch--select-xslt-options-wrapper">',
    '#markup' => t('<p>Available XSLT will display here.</p>'),
    '#suffix' => '</div>',
  );
  if (!empty($values['source_datastream'])) {
    $source_datastream = $values['source_datastream'];
    $form['select_xslt']['#type'] = 'select';
    $form['select_xslt']['#required'] = TRUE;
    $form['select_xslt']['#options'] = _cwrc_migration_batch_get_select_xslt_options($source_datastream, $form_state);
  }

  $form['actions'] = array(
    '#type' => 'actions',
    'submit' => array(
      '#type' => 'submit',
      '#value' => t('Save output'),
    ),
    'cancel' => array(
      '#title' => t('Cancel'),
      '#type' => 'link',
      '#href' => 'islandora/object/' . $object->id,
    ),
  );

  // Adding locks information.
  form_load_include($form_state, 'inc', 'islandora_object_lock', 'includes/form_handlers');
  islandora_object_lock_acquire_during_alter($form, $form_state, $object, NULL, 'manage/datastreams/add-using-xslt');
  return $form;
}

/**
 * Validate callback for cwrc_migration_batch_islandora_add_datastream_form().
 */
function cwrc_migration_batch_islandora_add_datastream_form_validate(array $form, array &$form_state) {
  if (empty($form_state['values']['select_xslt'])) {
    form_set_error('source_datastream', t('Please select a valid xslt to do the transformation.'));
  }
}

/**
 * Submit callback for cwrc_migration_batch_islandora_add_datastream_form().
 */
function cwrc_migration_batch_islandora_add_datastream_form_submit(array $form, array &$form_state) {
  $object = $form['#islandora_object'];
  $values = $form_state['values'];
  $source_datastream_id = $values['source_datastream'];
  $xslt_id = $values['select_xslt'];
  $xslt = $form_state['supported_xslts'][$source_datastream_id][$xslt_id];
  $output_datastream_id = $xslt->datastream_id;
  $datastream = isset($object[$output_datastream_id]) ? $object[$output_datastream_id] : $object->constructDatastream($output_datastream_id, 'M');
  $source_xml = $object[$source_datastream_id]->content;

  $saxon_processor = new Saxon\SaxonProcessor();
  $xslt_processor = $saxon_processor->newXsltProcessor();

  $xdm_node = $saxon_processor->parseXmlFromString($source_xml);
  $xslt_processor->setSourceFromXdmValue($xdm_node);
  $xslt_file = drupal_realpath($xslt->file->uri);
  $xslt_processor->compileFromFile($xslt_file);
  $output_xml = $xslt_processor->transformToString();

  $err_count = !$output_xml ? $xslt_processor->getExceptionCount() : 0;
  if ($err_count > 0) {
    $message = t('The XSLT transformer has encountered @count error(s):', array('@count' => $err_count)) . '<ol>';
    for ($i = 0; $i < $err_count; $i++) {
      $err_code = $xslt_processor->getErrorCode($i);
      $err_message = $xslt_processor->getErrorMessage($i);
      $message .= t('<li><b>Error Code:</b> @code<p><b>Error Message</b><br/>@message</p></li>', array(
        '@code' => $err_code,
        '@message' => $err_message,
      ));
    }
    $message .= '</ol>';
    drupal_set_message($message, 'error');
    $xslt_processor->exceptionClear();
  }
  else {
    $datastream->setContentFromString($output_xml);
    if (!isset($object[$output_datastream_id])) {
      // Create the datastream base on the xslt datastream output.
      $datastream->label = $output_datastream_id;
      $datastream->mimetype = $xslt->datastream_mime_type;
    }
    $object->ingestDatastream($datastream);
    drupal_set_message(t('The datastream was successuffly added!'));
    $form_state['redirect'] = "islandora/object/{$object->id}/manage/datastreams";
  }
  $xslt_processor->clearParameters();
  $xslt_processor->clearProperties();
}

/**
 * Ajax callback for xslt select ajax callback.
 */
function cwrc_migration_batch_islandora_add_datastream_xslt_select_ajax_callback($form, $form_state) {
  return $form['select_xslt'];
}

/**
 * Helper function to get the select xslt options.
 */
function _cwrc_migration_batch_get_select_xslt_options($datastream_id, &$form_state) {
  $xslts = cwrc_migration_batch_xslt_entry_load();
  $xslt_options = array('' => t('- select -'));
  foreach ($xslts as $xslt) {
    $xslt_cmodel_associations = unserialize($xslt->cmodel_associations);
    if ($xslt_cmodel_associations && _cwrc_migration_batch_is_datastream_supported_in_cmodels($xslt_cmodel_associations, $datastream_id)) {
      $file = file_load($xslt->fid);
      $xslt_id = $xslt->xslt_id;
      $xslt_options[$xslt_id] = $file->filename;
      $xslt->file = $file;
      $form_state['supported_xslts'][$datastream_id][$xslt_id] = $xslt;
    }
  }

  return $xslt_options;
}

/**
 * Helper function to check if datastream is supported in cmodels.
 */
function _cwrc_migration_batch_is_datastream_supported_in_cmodels($cmodels, $datastream_id) {
  $is_supported = FALSE;
  foreach ($cmodels as $cmodel_id => $cmodel_label) {
    if ($is_supported) {
      break;
    }
    $cmodel = islandora_object_load($cmodel_id);
    $cmodel_datastreams = islandora_get_datastreams_requirements_from_content_model($cmodel);

    if ($cmodel_datastreams) {
      foreach ($cmodel_datastreams as $datastream) {
        if ($datastream['id'] === $datastream_id) {
          $is_supported = TRUE;
          break;
        }
      }
    }
  }

  return $is_supported;
}
