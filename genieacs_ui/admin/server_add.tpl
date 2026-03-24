{include file="sections/header.tpl"}

<div class="row">
    <div class="col-md-8 col-md-offset-2">
        <div class="box box-primary">
            <div class="box-header with-border">
                <h3 class="box-title">Add GenieACS Server</h3>
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
                
                <form method="post" role="form" id="serverForm">
                    <input type="hidden" name="save" value="yes">
                    <div class="form-group">
                        <label for="name">Server Name <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="name" name="name" 
                               value="{$post.name|default:''}" required 
                               placeholder="e.g., Main ACS Server">
                        <p class="help-block">A friendly name to identify this server</p>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-4">
                            <div class="form-group">
                                <label for="protocol">Protocol <span class="text-danger">*</span></label>
                                <select class="form-control" id="protocol" name="protocol" required>
                                    <option value="http" {if $post.protocol|default:'http' == 'http'}selected{/if}>HTTP</option>
                                    <option value="https" {if $post.protocol|default:'' == 'https'}selected{/if}>HTTPS</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="form-group">
                                <label for="host">Host/IP <span class="text-danger">*</span></label>
                                <input type="text" class="form-control" id="host" name="host" 
                                       value="{$post.host|default:''}" required 
                                       placeholder="192.168.1.100 or acs.example.com">
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="form-group">
                                <label for="port">Port <span class="text-danger">*</span></label>
                                <input type="number" class="form-control" id="port" name="port" 
                                       value="{$post.port|default:7557}" required min="1" max="65535">
                                <p class="help-block">Default: 7557 (HTTP) / 7558 (HTTPS)</p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="username">Username (Optional)</label>
                                <input type="text" class="form-control" id="username" name="username" 
                                       value="{$post.username|default:''}" 
                                       placeholder="If authentication required">
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="password">Password (Optional)</label>
                                <div class="input-group">
                                    <input type="password" class="form-control" id="password" name="password" 
                                           value="{$post.password|default:''}" 
                                           placeholder="Enter password">
                                    <span class="input-group-btn">
                                        <button class="btn btn-default" type="button" onclick="togglePassword()">
                                            <i class="fa fa-eye"></i>
                                        </button>
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="priority">Priority</label>
                                <input type="number" class="form-control" id="priority" name="priority" 
                                       value="{$post.priority|default:0}" min="0" max="100">
                                <p class="help-block">Higher number = higher priority (used for failover)</p>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="max_devices">Max Devices Limit</label>
                                <input type="number" class="form-control" id="max_devices" name="max_devices" 
                                       value="{$post.max_devices|default:1000}" min="1" max="100000">
                                <p class="help-block">Maximum devices this server can handle</p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="timeout">Connection Timeout (seconds)</label>
                        <input type="number" class="form-control" id="timeout" name="timeout" 
                               value="{$post.timeout|default:30}" min="5" max="120">
                        <p class="help-block">Maximum time to wait for server response</p>
                    </div>
                    
                    <div class="form-group">
                        <label for="notes">Notes (Optional)</label>
                        <textarea class="form-control" id="notes" name="notes" rows="3">{$post.notes|default:''}</textarea>
                        <p class="help-block">Any additional information about this server</p>
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
                        <button type="submit" class="btn btn-primary btn-lg" id="saveBtn">
                            <i class="fa fa-save"></i> Save Server
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
        
        <!-- Server Information -->
 
        <div class="box box-default">
            <div class="box-header with-border">
                <h3 class="box-title">GenieACS Server Information</h3>
            </div>
            <div class="box-body">
                <p><strong>Default Ports:</strong></p>
                <ul>
                    <li>HTTP: 7557</li>
                    <li>HTTPS: 7558</li>
                </ul>
                <p><strong>API Endpoints:</strong></p>
                
                {literal}
                <ul>
                    <li><code>/api/v1/devices</code> - List all devices</li>
                    <li><code>/api/v1/devices/{id}</code> - Get device details</li>
                    <li><code>/api/v1/devices/{id}/tasks</code> - Send commands</li>
                </ul>
                {/literal}
                
                <p class="text-muted">
                    <i class="fa fa-info-circle"></i> 
                    Make sure GenieACS is running and accessible from this server.
                </p>
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
            if(data.version) {
                html += '<br><strong>GenieACS version:</strong> ' + data.version;
            }
            if(data.response_time) {
                html += '<br><strong>Response time:</strong> ' + data.response_time + ' ms';
            }
            html += '</div>';
            $('#testResult').html(html);
        } else {
            var html = '<div class="alert alert-danger">';
            html += '<i class="fa fa-times-circle"></i> ' + data.message;
            if(data.details) {
                html += '<br><small>' + data.details + '</small>';
            }
            html += '</div>';
            $('#testResult').html(html);
        }
        
        $('#testResultBox').show();
    }, 'json').fail(function() {
        $('#testBtn').prop('disabled', false).html('<i class="fa fa-refresh"></i> Test Connection');
        $('#testResult').html('<div class="alert alert-danger">Connection failed: Unable to reach server</div>');
        $('#testResultBox').show();
    });
}

// Auto-test when host/port/protocol change
var testTimeout;
$('#host, #port, #protocol').on('change keyup', function() {
    clearTimeout(testTimeout);
    testTimeout = setTimeout(function() {
        if($('#host').val() && $('#port').val()) {
            testConnection();
        }
    }, 1000);
});
</script>

{include file="sections/footer.tpl"}
