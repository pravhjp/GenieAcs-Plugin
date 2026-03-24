{include file="sections/header.tpl"}

<div class="row">
    <div class="col-md-10 col-md-offset-1">
        <div class="box box-primary">
            <div class="box-header with-border">
                <h3 class="box-title">GenieACS Plugin Settings</h3>
            </div>
            
            <div class="box-body">
                <form method="post" action="{$_url}plugin/genieacs_settings_save" role="form" id="settingsForm">
                    
                    <!-- General Settings -->
                    <div class="nav-tabs-custom">
                        <ul class="nav nav-tabs">
                            <li class="active"><a href="#general" data-toggle="tab">General</a></li>
                            <li><a href="#sync" data-toggle="tab">Synchronization</a></li>
                            <li><a href="#customer" data-toggle="tab">Customer Portal</a></li>
                            <li><a href="#notifications" data-toggle="tab">Notifications</a></li>
                            <li><a href="#advanced" data-toggle="tab">Advanced</a></li>
                            <li><a href="#debug" data-toggle="tab">Debug</a></li>
                        </ul>
                        
                        <div class="tab-content">
                            
                            <!-- General Settings Tab -->
                            <div class="tab-pane active" id="general">
                                <h4>General Settings</h4>
                                
                                <div class="form-group">
                                    <label for="api_timeout">API Timeout (seconds)</label>
                                    <input type="number" class="form-control" id="api_timeout" name="api_timeout" 
                                           value="{$settings.api_timeout|default:30}" min="5" max="120">
                                    <p class="help-block">Maximum time to wait for GenieACS API response</p>
                                </div>
                                
                                <div class="form-group">
                                    <label for="max_devices_per_server">Max Devices Per Server</label>
                                    <input type="number" class="form-control" id="max_devices_per_server" name="max_devices_per_server" 
                                           value="{$settings.max_devices_per_server|default:1000}" min="100" max="100000">
                                    <p class="help-block">Maximum number of devices to fetch per server</p>
                                </div>
                                
                                <div class="form-group">
                                    <label for="default_protocol">Default Protocol</label>
                                    <select class="form-control" id="default_protocol" name="default_protocol">
                                        <option value="http" {if $settings.default_protocol|default:'http' == 'http'}selected{/if}>HTTP</option>
                                        <option value="https" {if $settings.default_protocol|default:'' == 'https'}selected{/if}>HTTPS</option>
                                    </select>
                                </div>
                                
                                <div class="form-group">
                                    <label for="keep_password_history">Password History</label>
                                    <div class="checkbox">
                                        <label>
                                            <input type="checkbox" name="keep_password_history" value="1" 
                                                   {if $settings.keep_password_history|default:1}checked{/if}>
                                            Keep password change history
                                        </label>
                                    </div>
                                    <p class="help-block">Track all WiFi and admin password changes</p>
                                </div>
                                
                                <div class="form-group">
                                    <label for="password_history_days">Keep Password History (days)</label>
                                    <input type="number" class="form-control" id="password_history_days" name="password_history_days" 
                                           value="{$settings.password_history_days|default:30}" min="1" max="365">
                                </div>
                            </div>
                            
                            <!-- Sync Settings Tab -->
                            <div class="tab-pane" id="sync">
                                <h4>Synchronization Settings</h4>
                                
                                <div class="form-group">
                                    <label for="auto_sync_interval">Auto Sync Interval (minutes)</label>
                                    <select class="form-control" id="auto_sync_interval" name="auto_sync_interval">
                                        <option value="1" {if $settings.auto_sync_interval|default:5 == 1}selected{/if}>1 minute</option>
                                        <option value="5" {if $settings.auto_sync_interval|default:5 == 5}selected{/if}>5 minutes</option>
                                        <option value="10" {if $settings.auto_sync_interval|default:5 == 10}selected{/if}>10 minutes</option>
                                        <option value="15" {if $settings.auto_sync_interval|default:5 == 15}selected{/if}>15 minutes</option>
                                        <option value="30" {if $settings.auto_sync_interval|default:5 == 30}selected{/if}>30 minutes</option>
                                        <option value="60" {if $settings.auto_sync_interval|default:5 == 60}selected{/if}>1 hour</option>
                                    </select>
                                    <p class="help-block">How often to sync devices from GenieACS servers</p>
                                </div>
                                
                                <div class="form-group">
                                    <label for="sync_on_login">Sync on Admin Login</label>
                                    <div class="checkbox">
                                        <label>
                                            <input type="checkbox" name="sync_on_login" value="1" 
                                                   {if $settings.sync_on_login|default:1}checked{/if}>
                                            Sync devices when admin logs in
                                        </label>
                                    </div>
                                </div>
                                
                                <div class="form-group">
                                    <label for="sync_on_demand">Allow On-Demand Sync</label>
                                    <div class="checkbox">
                                        <label>
                                            <input type="checkbox" name="sync_on_demand" value="1" 
                                                   {if $settings.sync_on_demand|default:1}checked{/if}>
                                            Allow manual sync from UI
                                        </label>
                                    </div>
                                </div>
                                
                                <div class="form-group">
                                    <label for="full_sync_daily">Full Daily Sync</label>
                                    <div class="checkbox">
                                        <label>
                                            <input type="checkbox" name="full_sync_daily" value="1" 
                                                   {if $settings.full_sync_daily|default:1}checked{/if}>
                                            Perform full sync once per day
                                        </label>
                                    </div>
                                </div>
                                
                                <div class="form-group">
                                    <label for="sync_time">Daily Sync Time</label>
                                    <input type="time" class="form-control" id="sync_time" name="sync_time" 
                                           value="{$settings.sync_time|default:'02:00'}">
                                </div>
                                
                                <div class="form-group">
                                    <label for="auto_assign_devices">Auto-Assign Devices</label>
                                    <div class="checkbox">
                                        <label>
                                            <input type="checkbox" name="auto_assign_devices" value="1" 
                                                   {if $settings.auto_assign_devices|default:1}checked{/if}>
                                            Automatically assign devices to customers based on username
                                        </label>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Customer Portal Settings -->
                            <div class="tab-pane" id="customer">
                                <h4>Customer Portal Permissions</h4>
                                
                                <div class="form-group">
                                    <label for="customer_can_reboot">Allow Reboot</label>
                                    <div class="checkbox">
                                        <label>
                                            <input type="checkbox" name="customer_can_reboot" value="1" 
                                                   {if $settings.customer_can_reboot|default:1}checked{/if}>
                                            Customers can reboot their modem
                                        </label>
                                    </div>
                                </div>
                                
                                <div class="form-group">
                                    <label for="customer_can_change_wifi">Allow WiFi Change</label>
                                    <div class="checkbox">
                                        <label>
                                            <input type="checkbox" name="customer_can_change_wifi" value="1" 
                                                   {if $settings.customer_can_change_wifi|default:1}checked{/if}>
                                            Customers can change WiFi settings
                                        </label>
                                    </div>
                                </div>
                                
                                <div class="form-group">
                                    <label for="customer_can_view_password">View Password</label>
                                    <div class="checkbox">
                                        <label>
                                            <input type="checkbox" name="customer_can_view_password" value="1" 
                                                   {if $settings.customer_can_view_password|default:0}checked{/if}>
                                            Customers can view current WiFi password
                                        </label>
                                    </div>
                                    <p class="help-block text-warning">Security risk: Allows customers to see password in plain text</p>
                                </div>
                                
                                <div class="form-group">
                                    <label for="customer_can_factory_reset">Allow Factory Reset</label>
                                    <div class="checkbox">
                                        <label>
                                            <input type="checkbox" name="customer_can_factory_reset" value="1" 
                                                   {if $settings.customer_can_factory_reset|default:0}checked{/if}>
                                            Customers can factory reset modem
                                        </label>
                                    </div>
                                    <p class="help-block text-danger">Dangerous: This will reset all settings</p>
                                </div>
                                
                                <div class="form-group">
                                    <label for="require_strong_password">Require Strong Password</label>
                                    <div class="checkbox">
                                        <label>
                                            <input type="checkbox" name="require_strong_password" value="1" 
                                                   {if $settings.require_strong_password|default:1}checked{/if}>
                                            Enforce strong password policy for WiFi
                                        </label>
                                    </div>
                                </div>
                                
                                <div class="form-group">
                                    <label for="min_password_length">Minimum Password Length</label>
                                    <input type="number" class="form-control" id="min_password_length" name="min_password_length" 
                                           value="{$settings.min_password_length|default:8}" min="6" max="32">
                                </div>
                            </div>
                            
                            <!-- Notifications Tab -->
                            <div class="tab-pane" id="notifications">
                                <h4>Notification Settings</h4>
                                
                                <div class="form-group">
                                    <label for="notify_on_device_offline">Device Offline Alerts</label>
                                    <div class="checkbox">
                                        <label>
                                            <input type="checkbox" name="notify_on_device_offline" value="1" 
                                                   {if $settings.notify_on_device_offline|default:1}checked{/if}>
                                            Send notification when device goes offline
                                        </label>
                                    </div>
                                </div>
                                
                                <div class="form-group">
                                    <label for="offline_threshold">Offline Threshold (minutes)</label>
                                    <input type="number" class="form-control" id="offline_threshold" name="offline_threshold" 
                                           value="{$settings.offline_threshold|default:30}" min="5" max="1440">
                                    <p class="help-block">Consider device offline after this many minutes of no contact</p>
                                </div>
                                
                                <div class="form-group">
                                    <label for="notify_on_reboot">Reboot Notifications</label>
                                    <div class="checkbox">
                                        <label>
                                            <input type="checkbox" name="notify_on_reboot" value="1" 
                                                   {if $settings.notify_on_reboot|default:0}checked{/if}>
                                            Notify admin on device reboot
                                        </label>
                                    </div>
                                </div>
                                
                                <div class="form-group">
                                    <label for="notify_on_wifi_change">WiFi Change Notifications</label>
                                    <div class="checkbox">
                                        <label>
                                            <input type="checkbox" name="notify_on_wifi_change" value="1" 
                                                   {if $settings.notify_on_wifi_change|default:1}checked{/if}>
                                            Notify admin on WiFi changes
                                        </label>
                                    </div>
                                </div>
                                
                                <div class="form-group">
                                    <label for="admin_email">Admin Email</label>
                                    <input type="email" class="form-control" id="admin_email" name="admin_email" 
                                           value="{$settings.admin_email|default:''}" 
                                           placeholder="admin@example.com">
                                    <p class="help-block">Email to receive notifications</p>
                                </div>
                                
                                <div class="form-group">
                                    <label for="enable_sms">SMS Notifications</label>
                                    <div class="checkbox">
                                        <label>
                                            <input type="checkbox" name="enable_sms" value="1" 
                                                   {if $settings.enable_sms|default:0}checked{/if}>
                                            Enable SMS alerts (requires SMS gateway)
                                        </label>
                                    </div>
                                </div>
                                
                                <div class="form-group">
                                    <label for="admin_phone">Admin Phone</label>
                                    <input type="text" class="form-control" id="admin_phone" name="admin_phone" 
                                           value="{$settings.admin_phone|default:''}" 
                                           placeholder="+1234567890">
                                </div>
                            </div>
                            
                            <!-- Advanced Settings Tab -->
                            <div class="tab-pane" id="advanced">
                                <h4>Advanced Settings</h4>
                                
                                <div class="form-group">
                                    <label for="max_retries">Max API Retries</label>
                                    <input type="number" class="form-control" id="max_retries" name="max_retries" 
                                           value="{$settings.max_retries|default:3}" min="0" max="10">
                                    <p class="help-block">Number of times to retry failed API calls</p>
                                </div>
                                
                                <div class="form-group">
                                    <label for="retry_delay">Retry Delay (seconds)</label>
                                    <input type="number" class="form-control" id="retry_delay" name="retry_delay" 
                                           value="{$settings.retry_delay|default:2}" min="1" max="30">
                                </div>
                                
                                <div class="form-group">
                                    <label for="batch_size">Batch Size for Sync</label>
                                    <input type="number" class="form-control" id="batch_size" name="batch_size" 
                                           value="{$settings.batch_size|default:100}" min="10" max="1000">
                                    <p class="help-block">Number of devices to process in one batch</p>
                                </div>
                                
                                <div class="form-group">
                                    <label for="cache_ttl">Cache TTL (minutes)</label>
                                    <input type="number" class="form-control" id="cache_ttl" name="cache_ttl" 
                                           value="{$settings.cache_ttl|default:5}" min="0" max="60">
                                    <p class="help-block">How long to cache device data (0 = no cache)</p>
                                </div>
                                
                                <div class="form-group">
                                    <label for="compression">Enable Compression</label>
                                    <div class="checkbox">
                                        <label>
                                            <input type="checkbox" name="compression" value="1" 
                                                   {if $settings.compression|default:0}checked{/if}>
                                            Compress API requests/responses
                                        </label>
                                    </div>
                                </div>
                                
                                <div class="form-group">
                                    <label for="ssl_verify">SSL Verification</label>
                                    <div class="checkbox">
                                        <label>
                                            <input type="checkbox" name="ssl_verify" value="1" 
                                                   {if $settings.ssl_verify|default:1}checked{/if}>
                                            Verify SSL certificates (disable for self-signed certs)
                                        </label>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Debug Tab -->
                            <div class="tab-pane" id="debug">
                                <h4>Debug Settings</h4>
                                
                                <div class="form-group">
                                    <label for="debug_mode">Debug Mode</label>
                                    <div class="checkbox">
                                        <label>
                                            <input type="checkbox" name="debug_mode" value="1" 
                                                   {if $settings.debug_mode|default:0}checked{/if}>
                                            Enable debug logging
                                        </label>
                                    </div>
                                    <p class="help-block">Log all API requests and responses</p>
                                </div>
                                
                                <div class="form-group">
                                    <label for="log_level">Log Level</label>
                                    <select class="form-control" id="log_level" name="log_level">
                                        <option value="error" {if $settings.log_level|default:'error' == 'error'}selected{/if}>Error Only</option>
                                        <option value="warning" {if $settings.log_level|default:'' == 'warning'}selected{/if}>Warnings</option>
                                        <option value="info" {if $settings.log_level|default:'' == 'info'}selected{/if}>Info</option>
                                        <option value="debug" {if $settings.log_level|default:'' == 'debug'}selected{/if}>Debug (Verbose)</option>
                                    </select>
                                </div>
                                
                                <div class="form-group">
                                    <label for="log_retention">Log Retention (days)</label>
                                    <input type="number" class="form-control" id="log_retention" name="log_retention" 
                                           value="{$settings.log_retention|default:30}" min="1" max="365">
                                </div>
                                
                                <div class="form-group">
                                    <label>System Information</label>
                                    <div class="well well-sm">
                                        <p><strong>Plugin Version:</strong> 1.0.0</p>
                                        <p><strong>PHP Version:</strong> {phpversion()}</p>
                                        <p><strong>Database:</strong> MySQL</p>
                                        <p><strong>Last Sync:</strong> {$last_sync|default:'Never'}</p>
                                        <p><strong>Total Devices:</strong> {$total_devices|default:0}</p>
                                        <p><strong>Total Servers:</strong> {$total_servers|default:0}</p>
                                    </div>
                                </div>
                                
                                <div class="form-group">
                                    <label>Debug Actions</label>
                                    <div>
                                        <button type="button" class="btn btn-default" onclick="testAllConnections()">
                                            <i class="fa fa-refresh"></i> Test All Connections
                                        </button>
                                        <button type="button" class="btn btn-default" onclick="forceFullSync()">
                                            <i class="fa fa-sync"></i> Force Full Sync
                                        </button>
                                        <button type="button" class="btn btn-default" onclick="clearLogs()">
                                            <i class="fa fa-trash"></i> Clear Old Logs
                                        </button>
                                    </div>
                                </div>
                                
                                <div class="form-group">
                                    <label>View Logs</label>
                                    <div>
                                        <a href="{$_url}plugin/genieacs_logs" class="btn btn-info">
                                            <i class="fa fa-file-text"></i> View System Logs
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <hr>
                    
                    <div class="form-group text-center">
                        <button type="submit" class="btn btn-primary btn-lg">
                            <i class="fa fa-save"></i> Save All Settings
                        </button>
                        <button type="button" class="btn btn-default btn-lg" onclick="resetToDefault()">
                            <i class="fa fa-undo"></i> Reset to Default
                        </button>
                    </div>
                    
                </form>
            </div>
        </div>
    </div>
</div>

<script>
function resetToDefault() {
    if(confirm('Reset all settings to default values?')) {
        $.post('{$_url}plugin/genieacs_settings_reset', function(data) {
            if(data.success) {
                toastr.success('Settings reset to default');
                setTimeout(function() { location.reload(); }, 2000);
            } else {
                toastr.error(data.message);
            }
        }, 'json');
    }
}

function testAllConnections() {
    $('#testAllBtn').prop('disabled', true).html('<i class="fa fa-spinner fa-spin"></i> Testing...');
    
    $.post('{$_url}plugin/genieacs_test_all_connections', function(data) {
        $('#testAllBtn').prop('disabled', false).html('<i class="fa fa-refresh"></i> Test All Connections');
        
        if(data.success) {
            toastr.success('All servers tested: ' + data.online + ' online, ' + data.offline + ' offline');
        } else {
            toastr.error(data.message);
        }
    }, 'json');
}

function forceFullSync() {
    if(confirm('Force full synchronization now? This may take a while.')) {
        $.post('{$_url}plugin/genieacs_force_sync', function(data) {
            if(data.success) {
                toastr.success(data.message);
            } else {
                toastr.error(data.message);
            }
        }, 'json');
    }
}

function clearLogs() {
    if(confirm('Clear all logs older than retention period?')) {
        $.post('{$_url}plugin/genieacs_clear_logs', function(data) {
            if(data.success) {
                toastr.success(data.message);
            } else {
                toastr.error(data.message);
            }
        }, 'json');
    }
}

// Save settings via AJAX
$('#settingsForm').submit(function(e) {
    e.preventDefault();
    
    var formData = $(this).serialize();
    
    $.post('{$_url}plugin/genieacs_settings_save', formData, function(data) {
        if(data.success) {
            toastr.success('Settings saved successfully');
        } else {
            toastr.error(data.message || 'Error saving settings');
        }
    }, 'json');
});
</script>

{include file="sections/footer.tpl"}
