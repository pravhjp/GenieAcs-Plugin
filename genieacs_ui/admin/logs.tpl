{include file="sections/header.tpl"}

<div class="row">
    <div class="col-md-12">
        <div class="box box-primary">
            <div class="box-header with-border">
                <h3 class="box-title">System Logs</h3>
                <div class="box-tools pull-right">
                    <button class="btn btn-box-tool" onclick="refreshLogs()">
                        <i class="fa fa-refresh"></i> Refresh
                    </button>
                    <button class="btn btn-box-tool" onclick="clearLogs()">
                        <i class="fa fa-trash"></i> Clear Old
                    </button>
                </div>
            </div>
            <div class="box-body">
                
                <!-- Filter Bar -->
                <div class="row" style="margin-bottom: 15px;">
                    <div class="col-md-12">
                        <form method="get" class="form-inline">
                            <input type="hidden" name="page" value="plugin">
                            <input type="hidden" name="view" value="genieacs_logs">
                            
                            <div class="form-group">
                                <select name="action" class="form-control">
                                    <option value="">All Actions</option>
                                    <option value="add_server" {if $smarty.get.action == 'add_server'}selected{/if}>Add Server</option>
                                    <option value="edit_server" {if $smarty.get.action == 'edit_server'}selected{/if}>Edit Server</option>
                                    <option value="delete_server" {if $smarty.get.action == 'delete_server'}selected{/if}>Delete Server</option>
                                    <option value="server_test" {if $smarty.get.action == 'server_test'}selected{/if}>Server Test</option>
                                    <option value="sync_devices" {if $smarty.get.action == 'sync_devices'}selected{/if}>Sync Devices</option>
                                    <option value="device_reboot" {if $smarty.get.action == 'device_reboot'}selected{/if}>Device Reboot</option>
                                    <option value="device_factory_reset" {if $smarty.get.action == 'device_factory_reset'}selected{/if}>Factory Reset</option>
                                    <option value="device_wifi" {if $smarty.get.action == 'device_wifi'}selected{/if}>WiFi Change</option>
                                    <option value="device_password" {if $smarty.get.action == 'device_password'}selected{/if}>Password Change</option>
                                    <option value="device_assign" {if $smarty.get.action == 'device_assign'}selected{/if}>Assign Device</option>
                                </select>
                            </div>
                            
                            <div class="form-group">
                                <select name="status" class="form-control">
                                    <option value="">All Status</option>
                                    <option value="success" {if $smarty.get.status == 'success'}selected{/if}>Success</option>
                                    <option value="error" {if $smarty.get.status == 'error'}selected{/if}>Error</option>
                                    <option value="warning" {if $smarty.get.status == 'warning'}selected{/if}>Warning</option>
                                    <option value="info" {if $smarty.get.status == 'info'}selected{/if}>Info</option>
                                </select>
                            </div>
                            
                            <div class="form-group">
                                <select name="user_type" class="form-control">
                                    <option value="">All Users</option>
                                    <option value="admin" {if $smarty.get.user_type == 'admin'}selected{/if}>Admin</option>
                                    <option value="customer" {if $smarty.get.user_type == 'customer'}selected{/if}>Customer</option>
                                    <option value="system" {if $smarty.get.user_type == 'system'}selected{/if}>System</option>
                                </select>
                            </div>
                            
                            <div class="form-group">
                                <input type="text" name="date" class="form-control datepicker" 
                                       value="{$smarty.get.date|default:''}" placeholder="Date">
                            </div>
                            
                            <button type="submit" class="btn btn-primary">
                                <i class="fa fa-filter"></i> Filter
                            </button>
                            
                            <a href="{$_url}plugin/genieacs_logs" class="btn btn-default">
                                <i class="fa fa-times"></i> Clear
                            </a>
                            
                            <button type="button" class="btn btn-success" onclick="exportLogs()">
                                <i class="fa fa-download"></i> Export
                            </button>
                        </form>
                    </div>
                </div>
                
                <!-- Statistics Cards -->
                <div class="row" style="margin-bottom: 15px;">
                    <div class="col-md-3 col-sm-6">
                        <div class="small-box bg-green">
                            <div class="inner">
                                <h3>{$stats.success|default:0}</h3>
                                <p>Success</p>
                            </div>
                            <div class="icon">
                                <i class="fa fa-check-circle"></i>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 col-sm-6">
                        <div class="small-box bg-red">
                            <div class="inner">
                                <h3>{$stats.error|default:0}</h3>
                                <p>Errors</p>
                            </div>
                            <div class="icon">
                                <i class="fa fa-times-circle"></i>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 col-sm-6">
                        <div class="small-box bg-yellow">
                            <div class="inner">
                                <h3>{$stats.warning|default:0}</h3>
                                <p>Warnings</p>
                            </div>
                            <div class="icon">
                                <i class="fa fa-exclamation-triangle"></i>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 col-sm-6">
                        <div class="small-box bg-aqua">
                            <div class="inner">
                                <h3>{$stats.total|default:0}</h3>
                                <p>Total Logs</p>
                            </div>
                            <div class="icon">
                                <i class="fa fa-file-text"></i>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Logs Table -->
                <div class="table-responsive">
                    <table class="table table-bordered table-striped table-hover">
                        <thead>
                            <tr>
                                <th width="50">ID</th>
                                <th width="150">Time</th>
                                <th width="100">Type</th>
                                <th width="100">User</th>
                                <th width="150">Action</th>
                                <th>Message</th>
                                <th width="80">Status</th>
                                <th width="100">IP Address</th>
                                <th width="80">Details</th>
                            </tr>
                        </thead>
                        <tbody>
                            {foreach $logs as $log}
                            <tr>
                                <td>{$log.id}</td>
                                <td>
                                    {$log.created_at|date_format:"Y-m-d"}<br>
                                    <small class="text-muted">{$log.created_at|date_format:"H:i:s"}</small>
                                    <br><small class="text-muted">({$log.created_at|timeago})</small>
                                </td>
                                <td>
                                    {if $log.user_id && $log.user_type == 'admin'}
                                        <span class="label label-primary">Admin</span>
                                    {elseif $log.user_id && $log.user_type == 'customer'}
                                        <span class="label label-success">Customer</span>
                                    {else}
                                        <span class="label label-default">System</span>
                                    {/if}
                                </td>
                                <td>
                                    {if $log.user_id}
                                        {$log.user_id}
                                        {if $log.username}
                                            <br><small>{$log.username}</small>
                                        {/if}
                                    {else}
                                        <span class="text-muted">-</span>
                                    {/if}
                                </td>
                                <td>
                                    <strong>{$log.action|replace:'_':' '|capitalize}</strong>
                                    {if $log.server_id}
                                        <br><small>Server ID: {$log.server_id}</small>
                                    {/if}
                                    {if $log.device_id}
                                        <br><small>Device ID: {$log.device_id}</small>
                                    {/if}
                                </td>
                                <td>
                                    {$log.message|escape}
                                </td>
                                <td>
                                    {if $log.status == 'success'}
                                        <span class="label label-success">Success</span>
                                    {elseif $log.status == 'error'}
                                        <span class="label label-danger">Error</span>
                                    {elseif $log.status == 'warning'}
                                        <span class="label label-warning">Warning</span>
                                    {else}
                                        <span class="label label-info">{$log.status|capitalize}</span>
                                    {/if}
                                </td>
                                <td>
                                    <small>{$log.ip_address|default:'-'}</small>
                                </td>
                                <td>
                                    <button class="btn btn-xs btn-info" onclick="viewDetails({$log.id})">
                                        <i class="fa fa-eye"></i>
                                    </button>
                                </td>
                            </tr>
                            {foreachelse}
                            <tr>
                                <td colspan="9" class="text-center">
                                    <h4>No logs found</h4>
                                </td>
                            </tr>
                            {/foreach}
                        </tbody>
                    </table>
                </div>
                
                <!-- Pagination -->
                {if $pages > 1}
                <div class="text-center">
                    <ul class="pagination">
                        {for $p=1 to $pages}
                            <li {if $p == $page}class="active"{/if}>
                                <a href="{$_url}plugin/genieacs_logs?page={$p}&action={$smarty.get.action|escape}&status={$smarty.get.status|escape}&user_type={$smarty.get.user_type|escape}&date={$smarty.get.date|escape}">
                                    {$p}
                                </a>
                            </li>
                        {/for}
                    </ul>
                </div>
                {/if}
                
                <div class="text-muted">
                    <small>Showing {$logs|count} of {$total} logs</small>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Log Details Modal -->
<div class="modal fade" id="detailsModal" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">&times;</button>
                <h4 class="modal-title">Log Details</h4>
            </div>
            <div class="modal-body" id="detailsContent">
                Loading...
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>

<script>
function refreshLogs() {
    location.reload();
}

function clearLogs() {
    if(confirm('Clear all logs older than retention period?')) {
        $.post('{$_url}plugin/genieacs_clear_logs', function(data) {
            if(data.success) {
                toastr.success(data.message);
                setTimeout(function() { location.reload(); }, 2000);
            } else {
                toastr.error(data.message);
            }
        }, 'json');
    }
}

function exportLogs() {
    var params = [];
    
    if('{$smarty.get.action}') params.push('action={$smarty.get.action|escape}');
    if('{$smarty.get.status}') params.push('status={$smarty.get.status|escape}');
    if('{$smarty.get.user_type}') params.push('user_type={$smarty.get.user_type|escape}');
    if('{$smarty.get.date}') params.push('date={$smarty.get.date|escape}');
    
    var url = '{$_url}plugin/genieacs_export_logs';
    if(params.length) url += '?' + params.join('&');
    
    window.location.href = url;
}

function viewDetails(id) {
    $('#detailsContent').html('<div class="text-center"><i class="fa fa-spinner fa-spin"></i> Loading...</div>');
    $('#detailsModal').modal('show');
    
    $.get('{$_url}plugin/genieacs_log_details/' + id, function(data) {
        var html = '<div class="table-responsive">';
        html += '<table class="table table-bordered">';
        
        $.each(data, function(key, value) {
            html += '<tr>';
            html += '<th width="150">' + key.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase()) + '</th>';
            
            if(key == 'created_at') {
                html += '<td>' + new Date(value).toLocaleString() + '</td>';
            } else if(key == 'message' || (value && value.length > 100)) {
                html += '<td><pre style="white-space: pre-wrap;">' + (value || '-') + '</pre></td>';
            } else {
                html += '<td>' + (value || '-') + '</td>';
            }
            
            html += '</tr>';
        });
        
        html += '</table></div>';
        $('#detailsContent').html(html);
    }, 'json').fail(function() {
        $('#detailsContent').html('<div class="alert alert-danger">Failed to load details</div>');
    });
}

// Auto refresh every 60 seconds
setInterval(function() {
    if(!$('#detailsModal').is(':visible')) {
        $.get('{$_url}plugin/genieacs_logs_count', function(data) {
            if(data.new > 0) {
                toastr.info(data.new + ' new log entries');
            }
        }, 'json');
    }
}, 60000);

// Date picker
$(document).ready(function() {
    $('.datepicker').datepicker({
        format: 'yyyy-mm-dd',
        autoclose: true,
        todayHighlight: true
    });
});
</script>

<style>
.table > tbody > tr > td {
    vertical-align: middle;
}
pre {
    max-height: 300px;
    overflow: auto;
    background: #f5f5f5;
    border: 1px solid #ccc;
    padding: 10px;
}
</style>

{include file="sections/footer.tpl"}
