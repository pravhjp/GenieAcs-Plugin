<?php
// Cron job for auto-syncing devices
define('APP_RUN', true);
require_once dirname(dirname(__DIR__)) . '/system/config.php';

// Load plugin functions
require_once dirname(__DIR__) . '/genieacs.php';

// Run sync
genieacs_sync_all();

_log("GenieACS: Auto sync completed");
?>
