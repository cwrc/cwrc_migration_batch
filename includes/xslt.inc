<?php /** @noinspection UnserializeExploitsInspection */

/**
 * @file
 * Implementing xlts crud pages.
 */

function cwrc_migration_batch_xslt_main() {
  $empty = t('<p>No XSLTS have been imported.</p>');

  $query = db_select('cwrc_migration_batch_xlts', 'xslt')->extend('PagerDefault')->extend('TableSort');;
  $query->leftJoin('file_managed', 'file', 'xslt.fid = file.fid');
  $query->fields('xslt');
  $query->addField('file', 'filename');
  $query->addField('file', 'uri');

  $headers = array(
    array('data' => t('Title'), 'field' => 'file.filename'),
    array('data' => t('XSLT Version'), 'field' => 'xslt.version'),
    array('data' => t('Operations')),
  );
  $rows = array();

  $entries = $query
    ->limit(50)
    ->orderByHeader($headers)
    ->execute();
  foreach ($entries as $entry) {
    $rows[] = array(
      'data' => array(
        'title' => $entry->filename,
        'version' => $entry->version,
        'operations' => _cwrc_migration_batch_constructs_xslt_operations_links($entry),
      ),
    );
  }

  return theme('table', array(
    'header' => $headers,
    'rows' => $rows,
    'empty' => $empty,
  ));
}

function cwrc_migration_batch_xslt_add_form($form, &$form_state) {
  $values = !empty($form_state['values']) ? $form_state['values'] : array();
  $dsid = $values ? $values['datastream_id'] : '';

  if (empty($form_state['existing_dsids'])) {
    $form_state['existing_dsids'] = cwrc_migration_batch_get_datastreams_by_mime_type();
  }
  $existing_dsids = $form_state['existing_dsids'];
  $existing_dsid = isset($existing_dsids[$dsid]);
  $mime_type = $existing_dsid ? $existing_dsids[$dsid]['mime_type'] : '';

  $form['xslt_fid'] = array(
    '#title' => t('XSLT file'),
    '#title_display' => 'invisible',
    '#required' => TRUE,
    '#type' => 'managed_file',
//    '#default_value' => '',
    '#upload_location' => 'public://cwrc-migration-batch-xslts/',
    '#upload_validators' => array(
      'file_validate_extensions' => array('xsl', 'xslt'),
    ),
  );

  $form['output'] = array(
    '#title' => t('Output'),
    '#type' => 'fieldset',
    '#collapsible' => FALSE,
    '#collpase' => FALSE,
    '#prefix' => '<div id="cwrc-migration-batch--output-mime-type-wrapper">',
    '#suffix' => '</div>',
  );
  $form['output']['datastream_id'] = array(
    '#title' => t('Datastream ID'),
    '#type' => 'textfield',
    '#autocomplete_path' => 'islandora/autocomplete/cwrc-datastream-id',
    '#ajax' => array(
      'event' => 'autocompleteSelect blur',
      'callback' => 'cwrc_migration_batch_xslt_add_form_output_ajax_callback',
      'wrapper' => 'cwrc-migration-batch--output-mime-type-wrapper',
      'effect' => 'fade',
    ),
    '#required' => TRUE,
  );
  // Changing form element type based on datastream id input.
  $form['output']['mime_type'] = array(
    '#title' => !$existing_dsid ? t('Mime type') : t('Mime type: @mime_type', array('@mime_type' => $mime_type)),
    '#type' => !$existing_dsid ? 'textfield' : 'item',
    '#required' => !$existing_dsid,
  );

  $form['actions'] = array(
    '#type' => 'actions',
    'submit' => array(
      '#type' => 'submit',
      '#value' => t('Save'),
    ),
    'cancel' => array(
      '#title' => t('Cancel'),
      '#type' => 'link',
      '#href' => 'admin/islandora/cwrc-migration-batch/xslt/list',
    ),
  );
  return $form;
}

function cwrc_migration_batch_xslt_add_form_output_ajax_callback($form, $form_state) {
  return $form['output'];
}

function cwrc_migration_batch_xslt_add_form_submit($form, &$form_state) {
  $values = $form_state['values'];
  $fid = $values['xslt_fid'];
  $datastream_id = $values['datastream_id'];
  if (!isset($form_state['existing_dsids'][$datastream_id])) {
    $mime_type = $values['mime_type'];
  }
  else {
    $mime_type = $form_state['existing_dsids'][$datastream_id]['mime_type'];
  }

  $file = file_load($fid);
  $xslt_path = drupal_realpath($file->uri);
  $xslt_version = _cwrc_migration_batch_get_xslt_version($xslt_path);
  $increment_usage = FALSE;
  if ($file->status != FILE_STATUS_PERMANENT) {
    $file->status = FILE_STATUS_PERMANENT;
    file_save($file);
    $increment_usage = TRUE;
  }

  // Insert new xslt data.
  $entry = array(
    'fid' => $fid,
    'version' => $xslt_version,
    'datastream_id' => $datastream_id,
    'datastream_mime_type' => $mime_type,
    'changed' => time(),
  );
  $xslt_id = cwrc_migration_batch_xslt_entry_insert($entry);
  if ($increment_usage && is_numeric($xslt_id)) {
    file_usage_add($file, 'cwrc_migration_batch', 'cwrc_migration_batch_xslts', $xslt_id);
  }

  drupal_set_message(t('@name successfully imported', array('@name' => $file->filename)));
  $form_state['redirect'] = 'admin/islandora/cwrc-migration-batch/xslt/list';
}

function cwrc_migration_batch_xslt_cmodel_associations($form, &$form_state, $xslt_id) {
  $form['placeholder'] = array(
    '#markup' => t('<p>Form inputs coming soon.</p>'),
  );

  return $form;
}

/**
 * XSLT Enabled associations page callback.
 */
function cwrc_migration_batch_xslt_enabled_associations() {
  $build = array();
  $xslts = cwrc_migration_batch_xslt_entry_load();

  foreach ($xslts as $xslt) {
    $file = file_load($xslt->fid);
    $associations = !empty($xslt->cmodel_associations) ? unserialize($xslt->cmodel_associations) : array();
    $array_key = 'xslt_' . $xslt->xslt_id;
    $class = drupal_clean_css_identifier('xslt-associations-' . $array_key);
    $build[$array_key] = array(
      '#type' => 'container',
      '#attributes' => array(
        'class' => array('xslt-enabled-associations', $class, 'clearfix'),
      ),
      'heading' => array(
        '#type' => 'html_tag',
        '#tag' => 'h2',
        '#value' => $file->filename,
      ),
      'items' => array(
        '#markup' => t('<p>No cModel association have been added yet!</p>'),
      ),
    );
    if ($associations) {
      $build[$array_key]['items']['#markup'] = theme('item_list', array(
        'items' => array_values($associations),
        'title' => NULL,
        'type' => 'ul',
        'attributes' => array('class' => 'clearfix'),
      ));
    }
  }

  // In case no xslt has been added yet.
  if (!$build) {
    $build['placeholder'] = [
      '#markup' => t('<p>No xslt has been added yet.</p>'),
    ];
  }
  else {
    $module_name = 'cwrc_migration_batch';
    $path = drupal_get_path('module', $module_name);
    $build['#attached']['css'] = array($path . '/css/style.css');
  }

  return $build;
}

/**
 * Delete title callback.
 *
 * @param int $xslt_id
 *   The xslt id.
 *
 * @return string
 *   Formatted title.
 */
function cwrc_migration_batch_xslt_delete_title_callback($xslt_id) {
  if (!is_numeric($xslt_id) || !($entry = cwrc_migration_batch_xslt_entry_load(array('xslt_id' => $xslt_id)))) {
    return t('Wrong xslt internal identifier (@id) provided!', array('@id' => $xslt_id));
  }

  $file = file_load($entry[0]->fid);
  return t('You are about to delete @name xslt file', array('@name' => $file->filename));
}

/**
 * XSLT Delete form confirmation page callback.
 *
 * @param array $form
 *   The form structure.
 * @param array $form_state
 *   The form state.
 * @param int $xslt_id
 *   The xslt id.
 *
 * @return array
 *   The form array structure.
 */
function cwrc_migration_batch_xslt_delete_form_callback($form, &$form_state, $xslt_id = 0) {
  if (!is_numeric($xslt_id) || $xslt_id <= 0) {
    $form['warning'] = array(
      '#markup' => t('<p>Wrong xslt internal identifier (@id) provided!</p>', array('@id' => $xslt_id)),
    );
    return $form;
  }

  $form_state['xslt_id'] = $xslt_id;
  $form['warning'] = array(
    '#markup' => t('<p>This action cannot be undone!</p>'),
  );
  $form['actions'] = array(
    '#type' => 'actions',
    'submit' => array(
      '#type' => 'submit',
      '#value' => t('Delete'),
    ),
    'cancel' => array(
      '#title' => t('Cancel'),
      '#type' => 'link',
      '#href' => 'admin/islandora/cwrc-migration-batch/xslt/list',
    ),
  );
  return $form;
}

/**
 * XSLT Delete form confirmation page submit.
 */
function cwrc_migration_batch_xslt_delete_form_callback_submit($form, &$form_state) {
  $xslt_id = $form_state['xslt_id'];
  $condition = array('xslt_id' => $xslt_id);
  $name = $xslt_id;
  if (is_numeric($xslt_id) && $entry = cwrc_migration_batch_xslt_entry_load($condition)) {
    cwrc_migration_batch_xslt_entry_delete($condition);
    if ($file = file_load($entry[0]->fid)) {
      $name = $file->filename;
      file_delete($file);
    }
  }
  drupal_set_message(t('@name successfully deleted', array('@name' => $name)));
  $form_state['redirect'] = 'admin/islandora/cwrc-migration-batch/xslt/list';
}

/**
 * Delete title callback.
 *
 * @param int $xslt_id
 *   The xslt id.
 *
 * @return string
 *   Formatted title.
 */
function cwrc_migration_batch_xslt_associate_title_callback($xslt_id) {
  if (!is_numeric($xslt_id) || !($entry = cwrc_migration_batch_xslt_entry_load(array('xslt_id' => $xslt_id)))) {
    return t('Wrong xslt internal identifier (@id) provided!', array('@id' => $xslt_id));
  }

  $file = file_load($entry[0]->fid);
  return t('@name association', array('@name' => $file->filename));
}

/**
 * XSLT Delete form confirmation page callback.
 *
 * @param array $form
 *   The form structure.
 * @param array $form_state
 *   The form state.
 * @param int $xslt_id
 *   The xslt id.
 *
 * @return array
 *   The form array structure.
 */
function cwrc_migration_batch_xslt_associate_form_callback(array $form, array &$form_state, $xslt_id = 0) {
  $is_valid_xslt = is_numeric($xslt_id) && $xslt_id > 0;

  if ($is_valid_xslt) {
    $entries = cwrc_migration_batch_xslt_entry_load(array('xslt_id' => $xslt_id));
    $xslt = !empty($entries[0]) ? $entries[0] : NULL;
    $form['#xslt_entry'] = $xslt;
    $form_state['current_associations'] = $xslt ? unserialize($xslt->cmodel_associations) : array();
  }

  if (empty($form['#xslt_entry'])) {
    $form['warning'] = array(
      '#markup' => t('<p>Wrong xslt internal identifier (@id) provided!</p>', array('@id' => $xslt_id)),
    );
    return $form;
  }

  $form['#cmodel_pids'] = _cwrc_migration_batch_get_cmodel_options();
  $form_state['#xslt_id'] = $xslt_id;

  $form['existing_associations'] = cwrc_migration_batch_xslt_associate_form_existing_associations($form, $form_state);

  $form['add_association'] = array(
    '#type' => 'fieldset',
    '#title' => t('Add association:'),
    '#collapsible' => TRUE,
    '#collapse' => FALSE,
    '#weight' => 2,
  );
  $form['add_association']['cmodel_pid'] = array(
    '#title' => t('Cmodel'),
    '#type' => 'textfield',
    '#required' => TRUE,
    '#autocomplete_path' => ISLANDORA_CONTENT_MODELS_AUTOCOMPLETE,
  );

  $form['add_association']['actions'] = array(
    '#type' => 'actions',
    'submit' => array(
      '#type' => 'submit',
      '#value' => t('Add association'),
    ),
    'cancel' => array(
      '#title' => t('Cancel'),
      '#type' => 'link',
      '#href' => 'admin/islandora/cwrc-migration-batch/xslt/list',
    ),
  );

  return $form;
}

/**
 * Validate handler for the xslt associate form callback.
 */
function cwrc_migration_batch_xslt_associate_form_callback_validate(array $form, array &$form_state) {
  $cmodel_pids = $form['#cmodel_pids'];
  $cmodel_pid = !empty($form_state['values']['cmodel_pid']) ? $form_state['values']['cmodel_pid'] : '';
  if (!isset($cmodel_pids[$cmodel_pid])) {
    form_set_error('cmodel_pid', t('Please provide a valid content model pid!'));
    return;
  }

  // Check if the association to the cmodel is already made.
  if (isset($form_state['current_associations'][$cmodel_pid])) {
    form_set_error('cmodel_pid', t('The <strong>@cmodel</strong> content model association already exists.', array(
      '@cmodel' => $form_state['current_associations'][$cmodel_pid],
    )));
  }
}

/**
 * Submit handler for the xslt associate form callback.
 */
function cwrc_migration_batch_xslt_associate_form_callback_submit(array $form, array &$form_state) {
  $cmodel_pid = $form_state['values']['cmodel_pid'];
  $associations = $form_state['current_associations'];
  $associations[$cmodel_pid] = $form['#cmodel_pids'][$cmodel_pid];

  $xslt = $form['#xslt_entry'];
  $xslt->cmodel_associations = serialize($associations);

  _cwrc_migration_batch_xslt_form_association_entry_update_helper($xslt, $cmodel_pid, $associations);
}

/**
 * Subform to build the association table.
 */
function cwrc_migration_batch_xslt_associate_form_existing_associations($form, &$form_state) {
  $associations = $form_state['current_associations'];
  $subform = array(
    '#prefix' => '<div id="cwrc-migration-batch--xslt-associations-wrapper">',
    '#suffix' => '</div>',
    '#tree' => TRUE,
    '#theme' => 'table',
    '#header' => array(t('Cmodel'), t('Operations')),
    '#rows' => array(),
    '#weight' => 1,
    '#empty' => t('There are currently no associations for this xslt.'),
  );

  foreach ($associations as $cmodel_pid => $cmodel) {
    $cmodel_pid_key = str_replace(array(':', '-'), '_', $cmodel_pid);
    $cmodel_row = array(
      '#id' => drupal_clean_css_identifier($cmodel_pid_key),
      '#markup' => $cmodel,
    );
    $cmodel_operation = array(
      '#id' => drupal_clean_css_identifier($cmodel_pid_key) . '-remove',
      '#type' => 'submit',
      '#value' => t('remove'),
      '#name' => drupal_clean_css_identifier($cmodel_pid),
      '#submit' => array('cwrc_migration_batch_xslt_associate_form_existing_associations_remove_submit'),
      '#limit_validation_errors' => array(),
      '#cmodel_pid' => $cmodel_pid,
      '#ajax' => array(
        'callback' => 'cwrc_migration_batch_xslt_associate_form_existing_associations_remove_ajax_callback',
        'wrapper' => 'cwrc-migration-batch--xslt-associations-wrapper',
        'effect' => 'fade',
      ),
    );
    $subform[$cmodel_pid_key] = array(
      $cmodel_pid_key => &$cmodel_row,
      $cmodel_pid_key . '_remove' => &$cmodel_operation,
    );

    $subform['#rows'][$cmodel_pid_key] = array(
      array('data' => &$cmodel_row),
      array('data' => &$cmodel_operation),
    );

    unset($cmodel_row);
    unset($cmodel_operation);
  }

  return $subform;
}

/**
 * Remove ajax callback for an xslt association.
 */
function cwrc_migration_batch_xslt_associate_form_existing_associations_remove_ajax_callback($form, $form_state) {
  return $form['existing_associations'];
}

/**
 * Remove submit ajax callback for an xslt association.
 */
function cwrc_migration_batch_xslt_associate_form_existing_associations_remove_submit($form, &$form_state) {
  $triggering_element = $form_state['triggering_element'];
  $cmodel_pid = $triggering_element['#cmodel_pid'];
  $associations = $form_state['current_associations'];

  // Remove the association.
  unset($form_state['current_associations'][$cmodel_pid]);

  // Get the xslt entry to update.
  $xslt = $form['#xslt_entry'];
  // Update the xslt entry.
  $xslt->cmodel_associations = serialize($form_state['current_associations']);
  _cwrc_migration_batch_xslt_form_association_entry_update_helper($xslt, $cmodel_pid, $associations, 'delete');

  $form_state['rebuild'] = TRUE;
}

/**
 * Helper functions.
 */

/**
 * Gets the xslt version from the file content.
 *
 * @param string $xslt_file
 *   The xslt file url.
 *
 * @return string
 *   The xslt version.
 */
function _cwrc_migration_batch_get_xslt_version($xslt_file) {
  $xsl_doc = new DOMDocument();
  $xsl_doc->load($xslt_file);

  $xpath = new DOMXPath($xsl_doc);
  $dom_node_list = $xpath->query('//xsl:stylesheet[1]/@version');
  $version = '';
  foreach ($dom_node_list as $attribute) {
    if ($attribute->name === 'version') {
      $version = $attribute->value;
      break;
    }
  }
  return $version;
}

/**
 * Constructs xslt operations links.
 */
function _cwrc_migration_batch_constructs_xslt_operations_links($entry) {
  // Download operation.
  $name = $entry->filename;
  $url = file_create_url($entry->uri);
  $operations = l(t('Download'), $url, array(
    'attributes' => array(
      'target' => '_blank',
      'title' => t('Download @name, open a new window', array('@name' => $name)),
      'download' => '',
    ),
  ));

  // Remove operation.
  $xslt_id = $entry->xslt_id;
  $url = '/admin/islandora/cwrc-migration-batch/xslt/' . $xslt_id . '/delete';
  $operations .= '&nbsp;&nbsp;&nbsp;';
  $operations .= l(t('Remove'), $url);

  // Associate operation.
  $url = '/admin/islandora/cwrc-migration-batch/xslt/' . $xslt_id . '/associate';
  $operations .= '&nbsp;&nbsp;&nbsp;';
  $operations .= l(t('Associate'), $url);

  return $operations;
}

/**
 * Helper function for an xslt entry add or delete operation.
 */
function _cwrc_migration_batch_xslt_form_association_entry_update_helper($xslt, $cmodel_pid, $associations, $op = 'add') {
  $count = cwrc_migration_batch_xslt_entry_update((array) $xslt);

  if ($count > 0) {
    drupal_set_message(t('Successfully @op <strong>@cmodel</strong> association', array(
      '@op' => $op === 'add' ? 'added' : 'deleted',
      '@cmodel' => $associations[$cmodel_pid],
    )));
  }
  else {
    drupal_set_message(t('Failed to @op <strong>@cmodel</strong> association, please try again!', array(
      '@op' => $op === 'add' ? 'add' : 'delete',
      '@cmodel' => $associations[$cmodel_pid],
    )), 'error');
  }
}
