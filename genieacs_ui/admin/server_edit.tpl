{include file="sections/header.tpl"}

<div class="row">
    <div class="col-md-8 col-md-offset-2">
        <div class="box box-primary">
            <div class="box-header with-border">
                <h3 class="box-title">Edit GenieACS Server: {$server.name}</h3>
                <div class="box-tools pull-right">
                    <a href="{$_url}plugin/genieacs_servers" class="btn btn-box-tool">
                        <i class="fa fa-arrow-left"></i> Back to Servers
                    </a>
                </div>
            </div>
            
            <div class="box-body">
                {if isset($error)}
                    <div class="alert alert-danger">
                        <i class="fa fa-exclamation-triangle"></i> {$error}
                    </div>
                {/if}
                
                <div class="alert alert-info">
                    <i class="fa fa-server"></i> 
                    <strong>Server Status:</strong> 
                    {if $server.status == 'online'}
                        <span class="label label-success">Online</span>
                    {else}
                        <span class="label label-danger">Offline</span>
                    {/if}
                    Last checked: {$server.last_check|default:'Never'|timeago}
                </div>
                
                <form method="post" role="form" id="serverForm">
                    
                    <div class="form-group">
                        <label for="name">Server Name <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="name" name="name" 
                               value="{$server.name}" required 
                               placeholder="e.g., Main ACS Server">
                    </div>
                    
                    <div class="row">
                        <div class="col-md-4">
                            <div class="form-group">
                                <label for="protocol">Protocol <span class="text-danger">*</span></label>
                                <select class="form-control" id="protocol" name="protocol" required>
                                    <option value="http" {if $server.protocol == 'http'}selected{/if}>HTTP</option>
                                    <option value="https" {if $server.protocol == 'https'}selected{/if}>HTTPS</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="form-group">
                                <label for="host">Host/IP <span class="text-danger">*</span></label>
                                <input type="text" class="form-control" id="host" name="host" 
                                       value="{$server.host}" required 
                                       placeholder="192.168.1.100 or acs.example.com">
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="form-group">
                                <label for="port">Port <span class="text-danger">*</span></label>
                                <input type="number" class="form-control" id="port" name="port" 
                                       value="{$server.port}" required min="1" max="65535">
                            </div>
                        </div>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="username">Username</label>
                                <input type="text" class="form-control" id="username" name="username" 
                                       value="{$server.username|default:''}" 
                                       placeholder="If authentication required">
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="password">Password</label>
                                <div class="input-group">
                                    <input type="password" class="form-control" id="password" name="password" 
                                           placeholder="Leave empty to keep current password">
                                    <span class="input-group-btn">
                                        <button class="btn btn-default" type="button" onclick="togglePassword()">
                                            <i class="fa fa-eye"></i>
                                        </button>
                                    </span>
                                </div>
                                <p class="help-block">Leave empty to keep current password</p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="priority">Priority</label>
                                <input type="number" class="form-control" id="priority" name="priority" 
                                       value="{$server.priority|default:0}" min="0" max="100">
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="max_devices">Max Devices Limit</label>
                                <input type="number" class="form-control" id="max_devices" name="max_devices" 
                                       value="{$server.max_devices|default:1000}" min="1" max="100000">
                            </div>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="timeout">Connection Timeout (seconds)</label>
                        <input type="number" class="form-control" id="timeout" name="timeout" 
                               value="{$server.timeout|default:30}" min="5" max="120">
                    </div>
                    
                    <div class="form-group">
                        <label for="notes">Notes</label>
                        <textarea class="form-control" id="notes" name="notes" rows="3">{$server.notes|default:''}</textarea>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>Created</label>
                                <p class="form-control-static">{$server.created_at|date_format:"Y-m-d H:i:s"}</p>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>Last Updated</label>
                                <p class="form-control-static">{$server.updated_at|date_format:"Y-m-d H:i:s"|default:'Never'}</p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <div class="checkbox">
                            <label>
                                <input type="checkbox" id="test_after_save" name="test_after_save" checked>
                                Test connection after saving
                            </label>
                        </div>
                    </div>
                    
                    <hr>
                    
                    <div class="form-group text-center">
                        <button type="submit" class="btn btn-primary btn-lg">
                            <i class="fa fa-save"></i> Update Server
                        </button>
                        <button type="button" class="btn btn-info btn-lg" onclick="testConnection()" id="testBtn">
                            <i class="fa fa-refresh"></i> Test Connection
                        </button>
                        <a href="{$_url}plugin/genieacs_servers" class="btn btn-default btn-lg">
                            <i class="fa fa-times"></i> Cancel
                        </a>
                    </div>
                    
                </form>
            </div>
        </div>
        
        <!-- Connection Test Results -->
        <div class="box box-info" id="testResultBox" style="display: none;">
            <div class="box-header with-border">
                <h3 class="box-title">Connection Test Result</h3>
            </div>
            <div class="box-body" id="testResult">
                <!-- Result will be displayed here -->
            </div>
        </div>
        
        <!-- Server Statistics -->
        <div class="box box-success">
            <div class="box-header with-border">
                <h3 class="box-title">Server Statistics</h3>
            </div>
            <div class="box-body">
                <div class="row">
                    <div class="col-md-3 col-xs-6">
                        <div class="small-box bg-aqua">
                            <div class="inner">
                                <h3>{$server_stats.total_devices|default:0}</h3>
                                <p>Total Devices</p>
                            </div>
                            <div class="icon">
                                <i class="fa fa-wifi"></i>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 col-xs-6">
                        <div class="small-box bg-green">
                            <div class="inner">
                                <h3>{$server_stats.online_devices|default:0}</h3>
                                <p>Online</p>
                            </div>
                            <div class="icon">
                                <i class="fa fa-signal"></i>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 col-xs-6">
                        <div class="small-box bg-red">
                            <div class="inner">
                                <h3>{$server_stats.offline_devices|default:0}</h3>
                                <p>Offline</p>
                            </div>
                            <div class="icon">
                                <i class="fa fa-exclamation-triangle"></i>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 col-xs-6">
                        <div class="small-box bg-yellow">
                            <div class="inner">
                                <h3>{$server_stats.mapped_devices|default:0}</h3>
                                <p>Mapped</p>
                            </div>
                            <div class="icon">
                                <i class="fa fa-users"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Danger Zone -->
        <div class="box box-danger">
            <div class="box-header with-border">
                <h3 class="box-title">Danger Zone</h3>
            </div>
            <div class="box-body">
                <div class="row">
                    <div class="col-md-6">
                        <h4>Clear Device Cache</h4>
                        <p>Remove all devices from this server from database. They will be re-synced on next cron run.</p>
                        <button class="btn btn-warning" onclick="clearDevices({$server.id})">
                            <i class="fa fa-trash"></i> Clear Devices
                        </button>
                    </div>
                    <div class="col-md-6">
                        <h4>Delete Server</h4>
                        <p>Permanently delete this server and all associated devices. This action cannot be undone.</p>
                        <a href="{$_url}plugin/genieacs_server_delete/{$server.id}" 
                           class="btn btn-danger" 
                           onclick="return confirm('Are you sure? This will delete all devices on this server!')">
                            <i class="fa fa-trash"></i> Delete Server
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
function togglePassword() {
    var input = $('#password');
    if(input.attr('type') == 'password') {
        input.attr('type', 'text');
    } else {
        input.attr('type', 'password');
    }
}

function testConnection() {
    var protocol = $('#protocol').val();
    var host = $('#host').val();
    var port = $('#port').val();
    var username = $('#username').val();
    var password = $('#password').val();
    
    if(!host || !port) {
        toastr.error('Please enter host and port first');
        return;
    }
    
    $('#testBtn').prop('disabled', true).html('<i class="fa fa-spinner fa-spin"></i> Testing...');
    $('#testResultBox').hide();
    
    $.post('{$_url}plugin/genieacs_test_connection', {
        protocol: protocol,
        host: host,
        port: port,
        username: username,
        password: password
    }, function(data) {
        $('#testBtn').prop('disabled', false).html('<i class="fa fa-refresh"></i> Test Connection');
        
        if(data.success) {
            var html = '<div class="alert alert-success">';
            html += '<i class="fa fa-check-circle"></i> ' + data.message;
            if(data.devices !== undefined) {
                html += '<br><strong>Devices found:</strong> ' + data.devices;
            }
            html += '</div>';
            $('#testResult').html(html);
        } else {
            $('#testResult').html('<div class="alert alert-danger">' + data.message + '</div>');
        }
        
        $('#testResultBox').show();
    }, 'json');
}

function clearDevices(serverId) {
    if(confirm('Clear all devices from this server? They will be re-synced automatically.')) {
        $.post('{$_url}plugin/genieacs_server_clear_devices/' + serverId, function(data) {
            if(data.success) {
                toastr.success(data.message);
                setTimeout(function() { location.reload(); }, 2000);
            } else {
                toastr.error(data.message);
            }
        }, 'json');
    }
}
</script>

{include file="sections/footer.tpl"}
