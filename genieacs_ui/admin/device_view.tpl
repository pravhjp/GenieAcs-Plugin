{include file="sections/header.tpl"}

<div class="row">
    <div class="col-md-12">
        <div class="box box-primary">
            <div class="box-header with-border">
                <h3 class="box-title">Device Details: {$device.device_id}</h3>
                <div class="box-tools pull-right">
                    <div class="btn-group">
                        <button type="button" class="btn btn-box-tool dropdown-toggle" data-toggle="dropdown">
                            <i class="fa fa-wrench"></i> Actions <span class="caret"></span>
                        </button>
                        <ul class="dropdown-menu" role="menu">
                            <li><a href="#" onclick="rebootDevice({$device.id})"><i class="fa fa-power-off"></i> Reboot Device</a></li>
                            <li><a href="#" onclick="refreshDevice({$device.id})"><i class="fa fa-refresh"></i> Refresh Info</a></li>
                            <li><a href="#" onclick="summonDevice({$device.id})"><i class="fa fa-bell"></i> Summon Device</a></li>
                            <li class="divider"></li>
                            <li><a href="#" onclick="factoryReset({$device.id})"><i class="fa fa-undo"></i> Factory Reset</a></li>
                            <li class="divider"></li>
                            <li><a href="{$_url}plugin/genieacs_device_wifi/{$device.id}"><i class="fa fa-wifi"></i> WiFi Settings</a></li>
                            <li><a href="#" onclick="showPasswordModal({$device.id})"><i class="fa fa-lock"></i> Change Password</a></li>
                        </ul>
                    </div>
                    <a href="{$_url}plugin/genieacs_devices" class="btn btn-box-tool">
                        <i class="fa fa-arrow-left"></i> Back
                    </a>
                </div>
            </div>
            <div class="box-body">
                
                <!-- Status Cards -->
                <div class="row">
                    <div class="col-md-3 col-sm-6">
                        <div class="info-box bg-{if $device.status == 'online'}green{else}red{/if}">
                            <span class="info-box-icon"><i class="fa fa-wifi"></i></span>
                            <div class="info-box-content">
                                <span class="info-box-text">Device Status</span>
                                <span class="info-box-number">
                                    {if $device.status == 'online'}Online{else}Offline{/if}
                                </span>
                                <div class="progress">
                                    <div class="progress-bar" style="width: {if $device.status == 'online'}100{else}0{/if}%"></div>
                                </div>
                                <span class="progress-description">
                                    Last seen: {$device.last_contact|timeago}
                                </span>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-3 col-sm-6">
                        <div class="info-box bg-aqua">
                            <span class="info-box-icon"><i class="fa fa-clock-o"></i></span>
                            <div class="info-box-content">
                                <span class="info-box-text">Uptime</span>
                                <span class="info-box-number">
                                    {if $device.uptime > 0}
                                        {floor($device.uptime/86400)}d {floor(($device.uptime%86400)/3600)}h
                                    {else}
                                        Unknown
                                    {/if}
                                </span>
                                <span class="progress-description">
                                    First seen: {$device.first_seen|date_format:"Y-m-d"}
                                </span>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-3 col-sm-6">
                        <div class="info-box bg-yellow">
                            <span class="info-box-icon"><i class="fa fa-signal"></i></span>
                            <div class="info-box-content">
                                <span class="info-box-text">Signal Strength</span>
                                <span class="info-box-number">
                                    {if $device.signal_strength}
                                        {$device.signal_strength} dBm
                                    {else}
                                        N/A
                                    {/if}
                                </span>
                                <div class="progress">
                                    {if $device.signal_strength}
                                        {assign var=signal_percent value=($device.signal_strength + 100) * 2}
                                        <div class="progress-bar progress-bar-success" style="width: {$signal_percent}%"></div>
                                    {/if}
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-3 col-sm-6">
                        <div class="info-box bg-purple">
                            <span class="info-box-icon"><i class="fa fa-globe"></i></span>
                            <div class="info-box-content">
                                <span class="info-box-text">IP Address</span>
                                <span class="info-box-number">
                                    {if $device.ip_address}
                                        {$device.ip_address}
                                    {else}
                                        Unknown
                                    {/if}
                                </span>
                                <span class="progress-description">
                                    {$device.connection_type|default:'Unknown'} Connection
                                </span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Main Info Tabs -->
                <div class="nav-tabs-custom">
                    <ul class="nav nav-tabs">
                        <li class="active"><a href="#basic" data-toggle="tab">Basic Info</a></li>
                        <li><a href="#wifi" data-toggle="tab">WiFi Settings</a></li>
                        <li><a href="#admin" data-toggle="tab">Admin Settings</a></li>
                        <li><a href="#location" data-toggle="tab">Location</a></li>
                        <li><a href="#customer" data-toggle="tab">Customer Info</a></li>
                        <li><a href="#commands" data-toggle="tab">Command History</a></li>
                    </ul>
                    
                    <div class="tab-content">
                        <!-- Basic Info Tab -->
                        <div class="tab-pane active" id="basic">
                            <table class="table table-striped table-bordered">
                                <tr>
                                    <th width="200">Device ID</th>
                                    <td>{$device.device_id}</td>
                                </tr>
                                <tr>
                                    <th>Serial Number</th>
                                    <td>
                                        {$device.serial_number|default:'<span class="text-muted">Not Available</span>'}
                                        {if $device.serial_number}
                                            <button class="btn btn-xs btn-default pull-right" onclick="copyToClipboard('{$device.serial_number}')">
                                                <i class="fa fa-copy"></i>
                                            </button>
                                        {/if}
                                    </td>
                                </tr>
                                <tr>
                                    <th>MAC Address</th>
                                    <td>
                                        {$device.mac_address|default:'<span class="text-muted">Not Available</span>'}
                                        {if $device.mac_address}
                                            <button class="btn btn-xs btn-default pull-right" onclick="copyToClipboard('{$device.mac_address}')">
                                                <i class="fa fa-copy"></i>
                                            </button>
                                        {/if}
                                    </td>
                                </tr>
                                <tr>
                                    <th>Model</th>
                                    <td>{$device.model_name|default:'<span class="text-muted">Unknown</span>'}</td>
                                </tr>
                                <tr>
                                    <th>Manufacturer</th>
                                    <td>{$device.manufacturer|default:'<span class="text-muted">Unknown</span>'}</td>
                                </tr>
                                <tr>
                                    <th>Software Version</th>
                                    <td>{$device.software_version|default:'<span class="text-muted">Unknown</span>'}</td>
                                </tr>
                                <tr>
                                    <th>Hardware Version</th>
                                    <td>{$device.hardware_version|default:'<span class="text-muted">Unknown</span>'}</td>
                                </tr>
                                <tr>
                                    <th>Server</th>
                                    <td>
                                        <strong>{$device.server_name}</strong> 
                                        <span class="label label-info">{$device.protocol|upper}</span>
                                        <small class="text-muted">({$device.host}:{$device.port})</small>
                                    </td>
                                </tr>
                                <tr>
                                    <th>Connection Type</th>
                                    <td>
                                        {if $device.connection_type}
                                            <span class="label label-primary">{$device.connection_type}</span>
                                        {else}
                                            <span class="text-muted">Unknown</span>
                                        {/if}
                                    </td>
                                </tr>
                                <tr>
                                    <th>Tags</th>
                                    <td>
                                        {if $device.tags}
                                            {foreach explode(',', $device.tags) as $tag}
                                                <span class="label label-info">{$tag}</span>
                                            {/foreach}
                                        {else}
                                            <span class="text-muted">No tags</span>
                                            <button class="btn btn-xs btn-default pull-right" onclick="showTagsModal({$device.id})">
                                                <i class="fa fa-plus"></i> Add Tags
                                            </button>
                                        {/if}
                                    </td>
                                </tr>
                                <tr>
                                    <th>First Seen</th>
                                    <td>{$device.first_seen|date_format:"Y-m-d H:i:s"}</td>
                                </tr>
                                <tr>
                                    <th>Last Contact</th>
                                    <td>
                                        {$device.last_contact|date_format:"Y-m-d H:i:s"}
                                        <span class="text-muted">({$device.last_contact|timeago})</span>
                                    </td>
                                </tr>
                                <tr>
                                    <th>Notes</th>
                                    <td>
                                        <div id="notesDisplay">
                                            {if $device.notes}
                                                {$device.notes}
                                            {else}
                                                <span class="text-muted">No notes</span>
                                            {/if}
                                        </div>
                                        <button class="btn btn-xs btn-default" onclick="editNotes({$device.id})">
                                            <i class="fa fa-edit"></i> Edit Notes
                                        </button>
                                    </td>
                                </tr>
                            </table>
                        </div>
                        
                        <!-- WiFi Settings Tab -->
                        <div class="tab-pane" id="wifi">
                            <form onsubmit="updateWiFi(event, {$device.id})">
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label>WiFi SSID</label>
                                            <input type="text" name="ssid" class="form-control" 
                                                   value="{$device.wifi_ssid|default:''}" required>
                                            <p class="help-block">Between 1-32 characters</p>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label>WiFi Password</label>
                                            <div class="input-group">
                                                <input type="password" name="password" id="wifi_password" class="form-control" 
                                                       value="{$device.wifi_password_plain|default:''}" required>
                                                <span class="input-group-btn">
                                                    <button class="btn btn-default" type="button" onclick="toggleWifiPassword()">
                                                        <i class="fa fa-eye"></i>
                                                    </button>
                                                    <button class="btn btn-default" type="button" onclick="generateWifiPassword()">
                                                        <i class="fa fa-random"></i>
                                                    </button>
                                                </span>
                                            </div>
                                            <p class="help-block">Minimum 8 characters, maximum 63</p>
                                        </div>
                                    </div>
                                </div>
                                
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label>Security Mode</label>
                                            <select name="security" class="form-control">
                                                <option value="WPA2" {if $device.wifi_security == 'WPA2'}selected{/if}>WPA2-PSK</option>
                                                <option value="WPA3" {if $device.wifi_security == 'WPA3'}selected{/if}>WPA3-SAE</option>
                                                <option value="WPA" {if $device.wifi_security == 'WPA'}selected{/if}>WPA-PSK</option>
                                                <option value="None" {if $device.wifi_security == 'None'}selected{/if}>Open (No Security)</option>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label>Password Strength</label>
                                            <div class="progress" style="margin-bottom: 0;">
                                                <div id="wifiStrength" class="progress-bar progress-bar-success" style="width: 0%"></div>
                                            </div>
                                            <p class="help-block">Use strong password for security</p>
                                        </div>
                                    </div>
                                </div>
                                
                                <div class="checkbox">
                                    <label>
                                        <input type="checkbox" id="wifiConfirm" required> 
                                        I understand that changing WiFi settings will temporarily disconnect devices
                                    </label>
                                </div>
                                
                                <button type="submit" class="btn btn-primary" id="saveWifiBtn" disabled>
                                    <i class="fa fa-save"></i> Update WiFi Settings
                                </button>
                                <button type="button" class="btn btn-info" onclick="testWifiSettings({$device.id})">
                                    <i class="fa fa-bolt"></i> Test Connection
                                </button>
                            </form>
                            
                            <hr>
                            
                            <h4>Current WiFi Status</h4>
                            <div id="wifiStatus" class="text-muted">
                                Loading current WiFi status...
                            </div>
                        </div>
                        
                        <!-- Admin Settings Tab -->
                        <div class="tab-pane" id="admin">
                            <form onsubmit="updateAdminPassword(event, {$device.id})">
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label>New Admin Password</label>
                                            <div class="input-group">
                                                <input type="password" name="password" id="admin_password" class="form-control" required>
                                                <span class="input-group-btn">
                                                    <button class="btn btn-default" type="button" onclick="toggleAdminPassword()">
                                                        <i class="fa fa-eye"></i>
                                                    </button>
                                                </span>
                                            </div>
                                            <p class="help-block">Minimum 6 characters</p>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label>Password Type</label>
                                            <select name="type" class="form-control">
                                                <option value="admin">Admin/Super User</option>
                                                <option value="user">Regular User</option>
                                            </select>
                                        </div>
                                    </div>
                                </div>
                                
                                <div class="checkbox">
                                    <label>
                                        <input type="checkbox" id="adminConfirm" required>
                                        I confirm changing the device password
                                    </label>
                                </div>
                                
                                <button type="submit" class="btn btn-warning" id="saveAdminBtn" disabled>
                                    <i class="fa fa-lock"></i> Update Password
                                </button>
                            </form>
                            
                            <hr>
                            
                            <h4>Password History</h4>
                            <table class="table table-striped">
                                <thead>
                                    <tr>
                                        <th>Date</th>
                                        <th>Type</th>
                                        <th>Changed By</th>
                                    </tr>
                                </thead>
                                <tbody id="passwordHistory">
                                    <tr><td colspan="3" class="text-center">Loading...</td></tr>
                                </tbody>
                            </table>
                        </div>
                        
                        <!-- Location Tab -->
                        <div class="tab-pane" id="location">
                            <div class="row">
                                <div class="col-md-6">
                                    <form onsubmit="updateLocation(event, {$device.id})">
                                        <div class="form-group">
                                            <label>Location Description</label>
                                            <input type="text" name="location" class="form-control" 
                                                   value="{$device.location|default:''}" 
                                                   placeholder="e.g., Main Office, Room 101">
                                        </div>
                                        
                                        <div class="form-group">
                                            <label>Latitude</label>
                                            <input type="text" name="latitude" class="form-control" 
                                                   value="{$device.latitude|default:''}" 
                                                   placeholder="e.g., -6.2088">
                                        </div>
                                        
                                        <div class="form-group">
                                            <label>Longitude</label>
                                            <input type="text" name="longitude" class="form-control" 
                                                   value="{$device.longitude|default:''}" 
                                                   placeholder="e.g., 106.8456">
                                        </div>
                                        
                                        <button type="submit" class="btn btn-primary">
                                            <i class="fa fa-map-marker"></i> Update Location
                                        </button>
                                    </form>
                                </div>
                                
                                <div class="col-md-6">
                                    <div class="box box-solid">
                                        <div class="box-header with-border">
                                            <h3 class="box-title">Location Map</h3>
                                        </div>
                                        <div class="box-body">
                                            <div id="map" style="height: 300px;"></div>
                                            <p class="help-block">
                                                <a href="#" onclick="getCurrentLocation()">
                                                    <i class="fa fa-crosshairs"></i> Get Current Location
                                                </a>
                                            </p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Customer Info Tab -->
                        <div class="tab-pane" id="customer">
                            {if $device.customer_id}
                                <div class="box box-success">
                                    <div class="box-header with-border">
                                        <h3 class="box-title">Assigned Customer</h3>
                                        <div class="box-tools pull-right">
                                            <button class="btn btn-danger btn-xs" onclick="unassignDevice({$device.id})">
                                                <i class="fa fa-chain-broken"></i> Unassign
                                            </button>
                                        </div>
                                    </div>
                                    <div class="box-body">
                                        <table class="table table-bordered">
                                            <tr>
                                                <th width="150">Customer ID</th>
                                                <td>{$device.customer_id}</td>
                                            </tr>
                                            <tr>
                                                <th>Username</th>
                                                <td>
                                                    <strong>{$device.customer_username}</strong>
                                                    <a href="{$_url}customers/edit/{$device.customer_id}" class="btn btn-xs btn-default pull-right">
                                                        <i class="fa fa-external-link"></i> View Customer
                                                    </a>
                                                </td>
                                            </tr>
                                            <tr>
                                                <th>Full Name</th>
                                                <td>{$device.customer_name|default:'N/A'}</td>
                                            </tr>
                                            <tr>
                                                <th>Phone</th>
                                                <td>{$device.customer_phone|default:'N/A'}</td>
                                            </tr>
                                            <tr>
                                                <th>Email</th>
                                                <td>{$device.customer_email|default:'N/A'}</td>
                                            </tr>
                                            <tr>
                                                <th>Assigned Since</th>
                                                <td>{$device.updated_at|date_format:"Y-m-d H:i:s"}</td>
                                            </tr>
                                        </table>
                                    </div>
                                </div>
                            {else}
                                <div class="alert alert-warning">
                                    <i class="fa fa-exclamation-triangle"></i> 
                                    This device is not assigned to any customer.
                                </div>
                                <button class="btn btn-success" onclick="showAssignModal({$device.id})">
                                    <i class="fa fa-chain"></i> Assign to Customer
                                </button>
                            {/if}
                            
                            <hr>
                            
                            <h4>Recent Activity by Customer</h4>
                            <table class="table table-striped">
                                <thead>
                                    <tr>
                                        <th>Date</th>
                                        <th>Action</th>
                                        <th>Status</th>
                                    </tr>
                                </thead>
                                <tbody id="customerActivity">
                                    <tr><td colspan="3" class="text-center">Loading...</td></tr>
                                </tbody>
                            </table>
                        </div>
                        
                        <!-- Command History Tab -->
                        <div class="tab-pane" id="commands">
                            <table class="table table-striped table-bordered">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Command</th>
                                        <th>Status</th>
                                        <th>Requested By</th>
                                        <th>Requested At</th>
                                        <th>Executed At</th>
                                        <th>Response</th>
                                    </tr>
                                </thead>
                                <tbody id="commandHistory">
                                    <tr><td colspan="7" class="text-center">Loading...</td></tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Assign Customer Modal -->
<div class="modal fade" id="assignModal" tabindex="-1" role="dialog">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">&times;</button>
                <h4 class="modal-title">Assign Device to Customer</h4>
            </div>
            <div class="modal-body">
                <form id="assignForm">
                    <div class="form-group">
                        <label>Select Customer</label>
                        <select name="customer_id" class="form-control" required>
                            <option value="">-- Select Customer --</option>
                            {foreach $customers as $c}
                                <option value="{$c.id}">{$c.username} - {$c.fullname}</option>
                            {/foreach}
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Device Username (Optional)</label>
                        <input type="text" name="username" class="form-control" 
                               value="{$device.username|default:''}" 
                               placeholder="If different from customer username">
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-primary" onclick="assignDevice({$device.id})">Assign</button>
            </div>
        </div>
    </div>
</div>

<!-- Tags Modal -->
<div class="modal fade" id="tagsModal" tabindex="-1" role="dialog">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">&times;</button>
                <h4 class="modal-title">Manage Tags</h4>
            </div>
            <div class="modal-body">
                <div class="form-group">
                    <label>Tags (comma separated)</label>
                    <input type="text" id="deviceTags" class="form-control" value="{$device.tags|default:''}">
                    <p class="help-block">Example: office, main, vip, customer1</p>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-primary" onclick="saveTags({$device.id})">Save Tags</button>
            </div>
        </div>
    </div>
</div>

<!-- Notes Modal -->
<div class="modal fade" id="notesModal" tabindex="-1" role="dialog">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">&times;</button>
                <h4 class="modal-title">Edit Notes</h4>
            </div>
            <div class="modal-body">
                <textarea id="deviceNotes" class="form-control" rows="5">{$device.notes|default:''}</textarea>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-primary" onclick="saveNotes({$device.id})">Save Notes</button>
            </div>
        </div>
    </div>
</div>

<script>
var deviceId = {$device.id};

$(document).ready(function() {
    loadCommandHistory();
    loadPasswordHistory();
    loadCustomerActivity();
    checkWifiStatus();
    
    // Password strength checker
    $('#wifi_password').on('keyup', checkWifiPasswordStrength);
    
    // Enable save button when confirm is checked
    $('#wifiConfirm').change(function() {
        $('#saveWifiBtn').prop('disabled', !this.checked);
    });
    
    $('#adminConfirm').change(function() {
        $('#saveAdminBtn').prop('disabled', !this.checked);
    });
});

function rebootDevice(id) {
    if(confirm('Are you sure you want to reboot this device?')) {
        $.post('{$_url}plugin/genieacs_device_reboot/' + id, function(data) {
            if(data.success) {
                toastr.success(data.message);
            } else {
                toastr.error(data.message);
            }
        }, 'json');
    }
}

function refreshDevice(id) {
    $.post('{$_url}plugin/genieacs_device_refresh/' + id, function(data) {
        if(data.success) {
            toastr.success(data.message);
            setTimeout(function() { location.reload(); }, 2000);
        } else {
            toastr.error(data.message);
        }
    }, 'json');
}

function summonDevice(id) {
    $.post('{$_url}plugin/genieacs_device_summon/' + id, function(data) {
        if(data.success) {
            toastr.success(data.message);
        } else {
            toastr.error(data.message);
        }
    }, 'json');
}

function factoryReset(id) {
    if(confirm('WARNING: This will reset the device to factory settings. All configurations will be lost. Continue?')) {
        $.post('{$_url}plugin/genieacs_device_factory_reset/' + id, function(data) {
            if(data.success) {
                toastr.success(data.message);
            } else {
                toastr.error(data.message);
            }
        }, 'json');
    }
}

function updateWiFi(event, id) {
    event.preventDefault();
    
    var ssid = $('input[name="ssid"]').val();
    var password = $('#wifi_password').val();
    var security = $('select[name="security"]').val();
    
    if(!ssid || !password) {
        toastr.error('Please fill all fields');
        return;
    }
    
    if(password.length < 8) {
        toastr.error('Password must be at least 8 characters');
        return;
    }
    
    $('#saveWifiBtn').prop('disabled', true).html('<i class="fa fa-spinner fa-spin"></i> Updating...');
    
    $.post('{$_url}plugin/genieacs_device_wifi/' + id, {
        ssid: ssid,
        password: password,
        security: security
    }, function(data) {
        if(data.success) {
            toastr.success('WiFi settings updated successfully');
            setTimeout(function() { location.reload(); }, 2000);
        } else {
            toastr.error(data.message);
            $('#saveWifiBtn').prop('disabled', false).html('<i class="fa fa-save"></i> Update WiFi Settings');
        }
    }, 'json');
}

function updateAdminPassword(event, id) {
    event.preventDefault();
    
    var password = $('#admin_password').val();
    var type = $('select[name="type"]').val();
    
    if(!password) {
        toastr.error('Please enter password');
        return;
    }
    
    if(password.length < 6) {
        toastr.error('Password must be at least 6 characters');
        return;
    }
    
    $('#saveAdminBtn').prop('disabled', true).html('<i class="fa fa-spinner fa-spin"></i> Updating...');
    
    $.post('{$_url}plugin/genieacs_device_update_password/' + id, {
        password: password,
        type: type
    }, function(data) {
        if(data.success) {
            toastr.success(data.message);
            loadPasswordHistory();
            $('#admin_password').val('');
            $('#saveAdminBtn').prop('disabled', true).html('<i class="fa fa-lock"></i> Update Password');
            $('#adminConfirm').prop('checked', false);
        } else {
            toastr.error(data.message);
            $('#saveAdminBtn').prop('disabled', false).html('<i class="fa fa-lock"></i> Update Password');
        }
    }, 'json');
}

function updateLocation(event, id) {
    event.preventDefault();
    
    var location = $('input[name="location"]').val();
    var latitude = $('input[name="latitude"]').val();
    var longitude = $('input[name="longitude"]').val();
    
    $.post('{$_url}plugin/genieacs_device_location/' + id, {
        location: location,
        latitude: latitude,
        longitude: longitude
    }, function(data) {
        if(data.success) {
            toastr.success('Location updated');
            updateMap(latitude, longitude);
        } else {
            toastr.error(data.message);
        }
    }, 'json');
}

function loadCommandHistory() {
    $.get('{$_url}plugin/genieacs_device_commands/' + deviceId, function(data) {
        var html = '';
        if(data.length > 0) {
            $.each(data, function(i, cmd) {
                var statusClass = '';
                var statusText = cmd.status;
                
                if(cmd.status == 'success') statusClass = 'label-success';
                else if(cmd.status == 'failed') statusClass = 'label-danger';
                else if(cmd.status == 'pending') statusClass = 'label-warning';
                else statusClass = 'label-info';
                
                html += '<tr>';
                html += '<td>' + cmd.id + '</td>';
                html += '<td><strong>' + cmd.command + '</strong></td>';
                html += '<td><span class="label ' + statusClass + '">' + cmd.status + '</span></td>';
                html += '<td>' + (cmd.requested_by || 'System') + '</td>';
                html += '<td>' + (cmd.requested_at ? new Date(cmd.requested_at).toLocaleString() : '-') + '</td>';
                html += '<td>' + (cmd.executed_at ? new Date(cmd.executed_at).toLocaleString() : '-') + '</td>';
                html += '<td>';
                if(cmd.response) {
                    html += '<button class="btn btn-xs btn-info" onclick="showResponse(\'' + cmd.response.replace(/'/g, "\\'") + '\')">View</button>';
                } else {
                    html += '-';
                }
                html += '</td>';
                html += '</tr>';
            });
        } else {
            html = '<tr><td colspan="7" class="text-center">No command history</td></tr>';
        }
        $('#commandHistory').html(html);
    }, 'json');
}

function loadPasswordHistory() {
    $.get('{$_url}plugin/genieacs_password_history/' + deviceId, function(data) {
        var html = '';
        if(data.length > 0) {
            $.each(data, function(i, ph) {
                var typeClass = (ph.change_type == 'wifi') ? 'label-success' : 'label-info';
                html += '<tr>';
                html += '<td>' + new Date(ph.created_at).toLocaleString() + '</td>';
                html += '<td><span class="label ' + typeClass + '">' + ph.change_type + '</span></td>';
                html += '<td>' + (ph.changed_by || 'System') + '</td>';
                html += '</tr>';
            });
        } else {
            html = '<tr><td colspan="3" class="text-center">No password history</td></tr>';
        }
        $('#passwordHistory').html(html);
    }, 'json');
}

function loadCustomerActivity() {
    $.get('{$_url}plugin/genieacs_customer_activity/' + deviceId, function(data) {
        var html = '';
        if(data.length > 0) {
            $.each(data, function(i, act) {
                var statusClass = (act.status == 'success') ? 'label-success' : (act.status == 'error' ? 'label-danger' : 'label-info');
                html += '<tr>';
                html += '<td>' + new Date(act.created_at).toLocaleString() + '</td>';
                html += '<td>' + act.action + '</td>';
                html += '<td><span class="label ' + statusClass + '">' + act.status + '</span></td>';
                html += '</tr>';
            });
        } else {
            html = '<tr><td colspan="3" class="text-center">No activity</td></tr>';
        }
        $('#customerActivity').html(html);
    }, 'json');
}

function checkWifiStatus() {
    $.get('{$_url}plugin/genieacs_wifi_status/' + deviceId, function(data) {
        if(data.success) {
            var html = '<p><strong>SSID:</strong> ' + (data.ssid || 'N/A') + '</p>';
            html += '<p><strong>Security:</strong> ' + (data.security || 'N/A') + '</p>';
            html += '<p><strong>Channel:</strong> ' + (data.channel || 'N/A') + '</p>';
            html += '<p><strong>Connected Devices:</strong> ' + (data.clients || '0') + '</p>';
            $('#wifiStatus').html(html);
        } else {
            $('#wifiStatus').html('<p class="text-muted">Unable to fetch WiFi status</p>');
        }
    }, 'json');
}

function checkWifiPasswordStrength() {
    var password = $('#wifi_password').val();
    var strength = 0;
    
    if(password.length >= 8) strength += 25;
    if(password.length >= 12) strength += 25;
    if(password.match(/[a-z]/) && password.match(/[A-Z]/)) strength += 25;
    if(password.match(/[0-9]/) && password.match(/[^a-zA-Z0-9]/)) strength += 25;
    
    $('#wifiStrength').css('width', strength + '%');
    
    if(strength < 50) {
        $('#wifiStrength').removeClass('progress-bar-success progress-bar-warning').addClass('progress-bar-danger');
    } else if(strength < 75) {
        $('#wifiStrength').removeClass('progress-bar-danger progress-bar-success').addClass('progress-bar-warning');
    } else {
        $('#wifiStrength').removeClass('progress-bar-danger progress-bar-warning').addClass('progress-bar-success');
    }
}

function toggleWifiPassword() {
    var input = $('#wifi_password');
    if(input.attr('type') == 'password') {
        input.attr('type', 'text');
    } else {
        input.attr('type', 'password');
    }
}

function toggleAdminPassword() {
    var input = $('#admin_password');
    if(input.attr('type') == 'password') {
        input.attr('type', 'text');
    } else {
        input.attr('type', 'password');
    }
}

function generateWifiPassword() {
    var length = 12;
    var charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*";
    var password = "";
    
    for(var i = 0; i < length; i++) {
        password += charset.charAt(Math.floor(Math.random() * charset.length));
    }
    
    $('#wifi_password').val(password);
    checkWifiPasswordStrength();
}

function testWifiSettings(id) {
    $.post('{$_url}plugin/genieacs_test_wifi/' + id, function(data) {
        if(data.success) {
            toastr.success('WiFi connection test successful');
        } else {
            toastr.error(data.message || 'Test failed');
        }
    }, 'json');
}

function showAssignModal(id) {
    $('#assignModal').modal('show');
}

function assignDevice(id) {
    var customerId = $('select[name="customer_id"]').val();
    var username = $('input[name="username"]').val();
    
    if(!customerId) {
        toastr.error('Please select a customer');
        return;
    }
    
    $.post('{$_url}plugin/genieacs_device_assign/' + id, {
        customer_id: customerId,
        username: username
    }, function(data) {
        if(data.success) {
            toastr.success(data.message);
            $('#assignModal').modal('hide');
            setTimeout(function() { location.reload(); }, 2000);
        } else {
            toastr.error(data.message);
        }
    }, 'json');
}

function unassignDevice(id) {
    if(confirm('Unassign this device from customer?')) {
        $.post('{$_url}plugin/genieacs_device_unassign/' + id, function(data) {
            if(data.success) {
                toastr.success(data.message);
                setTimeout(function() { location.reload(); }, 2000);
            } else {
                toastr.error(data.message);
            }
        }, 'json');
    }
}

function showTagsModal(id) {
    $('#tagsModal').modal('show');
}

function saveTags(id) {
    var tags = $('#deviceTags').val();
    
    $.post('{$_url}plugin/genieacs_device_tags/' + id, {tags: tags}, function(data) {
        if(data.success) {
            toastr.success('Tags updated');
            $('#tagsModal').modal('hide');
            setTimeout(function() { location.reload(); }, 2000);
        } else {
            toastr.error(data.message);
        }
    }, 'json');
}

function editNotes(id) {
    $('#notesModal').modal('show');
}

function saveNotes(id) {
    var notes = $('#deviceNotes').val();
    
    $.post('{$_url}plugin/genieacs_device_notes/' + id, {notes: notes}, function(data) {
        if(data.success) {
            toastr.success('Notes updated');
            $('#notesModal').modal('hide');
            $('#notesDisplay').html(notes || '<span class="text-muted">No notes</span>');
        } else {
            toastr.error(data.message);
        }
    }, 'json');
}

function showResponse(response) {
    try {
        var data = JSON.parse(response);
        alert(JSON.stringify(data, null, 2));
    } catch(e) {
        alert(response);
    }
}

function copyToClipboard(text) {
    var $temp = $("<input>");
    $("body").append($temp);
    $temp.val(text).select();
    document.execCommand("copy");
    $temp.remove();
    toastr.success('Copied to clipboard');
}

function getCurrentLocation() {
    if(navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(function(position) {
            $('input[name="latitude"]').val(position.coords.latitude);
            $('input[name="longitude"]').val(position.coords.longitude);
            toastr.success('Location detected');
        }, function() {
            toastr.error('Unable to get location');
        });
    } else {
        toastr.error('Geolocation not supported');
    }
}

function updateMap(lat, lng) {
    if(lat && lng && window.map) {
        map.setView([lat, lng], 15);
        L.marker([lat, lng]).addTo(map);
    }
}

// Initialize map if lat/lng exist
{if $device.latitude && $device.longitude}
    var map = L.map('map').setView([{$device.latitude}, {$device.longitude}], 13);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© OpenStreetMap contributors'
    }).addTo(map);
    L.marker([{$device.latitude}, {$device.longitude}]).addTo(map);
{/if}
</script>

{include file="sections/footer.tpl"}
