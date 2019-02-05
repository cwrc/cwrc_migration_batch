<?php

/**
 * @file
 * Autocomplete functionality for datastream.
 */

/**
 * Datastream autocomplete callback.
 *
 * @param string $string
 *   The searched text.
 */
function cwrc_migration_batch_datastream_autocomplete($string = '') {
  $output = array();
  $datastreams = cwrc_migration_batch_get_datastreams_by_mime_type();

  if ($string) {
    $string = strtoupper($string);
    foreach ($datastreams as $id => $datastream) {
      if (preg_match("/{$string}/i", $id) !== 0) {
        $output[$id] = $id;
      }
    }
  }
  else {
    $dsids = array_keys($datastreams);
    $output = drupal_map_assoc($dsids);
  }

  return drupal_json_output($output);
}
