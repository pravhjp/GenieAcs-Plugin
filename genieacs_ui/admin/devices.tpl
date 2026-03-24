{include file="sections/header.tpl"}

<div class="row">
    <div class="col-md-12">
        <div class="box box-primary">
            <div class="box-header with-border">
                <h3 class="box-title">Devices</h3>
            </div>
            <div class="box-body">
                <form method="get" class="form-inline">
                    <input type="hidden" name="page" value="plugin">
                    <input type="hidden" name="view" value="genieacs_devices">
                    
                    <div class="form-group">
                        <input type="text" name="search" class="form-control" 
                               placeholder="Search device..." value="{$search}">
                    </div>
                    
                    <div class="form-group">
                        <select name="status" class="form-control">
                            <option value="">All Status</option>
                            <option value="online" {if $status == 'online'}selected{/if}>Online</option>
                            <option value="offline" {if $status == 'offline'}selected{/if}>Offline</option>
                        </select>
                    </div>
                    
                    <button type="submit" class="btn btn-primary">Filter</button>
                    <a href="{$_url}plugin/genieacs_devices" class="btn btn-default">Reset</a>
                </form>
                
                <hr>
                
                <table class="table table-bordered table-striped">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Device ID</th>
                            <th>Serial</th>
                            <th>Server</th>
                            <th>Customer</th>
                            <th>Status</th>
                            <th>Last Contact</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach $devices as $d}
                        <tr>
                            <td>{$d.id}</td>
                            <td>{$d.device_id}</td>
                            <td>{$d.serial_number|default:'N/A'}</td>
                            <td>{$d.server_name}</td>
                            <td>
                                {if $d.customer_name}
                                    {$d.customer_name}
                                {else}
                                    <span class="text-muted">Unassigned</span>
                                {/if}
                            </td>
                            <td>
                                {if $d.status == 'online'}
                                    <span class="label label-success">Online</span>
                                {else}
                                    <span class="label label-danger">Offline</span>
                                {/if}
                            </td>
                            <td>
                                {if $d.last_contact}
                                {$d.last_contact|date_format:"Y-m-d H:i:s"}
                                {else}
                                Never
                                {/if}
                            </td>
                            <td>
                                <a href="{$_url}plugin/genieacs_device_view/{$d.id}" class="btn btn-info btn-xs">
                                    <i class="fa fa-eye"></i>
                                </a>
                                <a href="{$_url}plugin/genieacs_device_reboot/{$d.id}" 
                                   onclick="return confirm('Reboot this device?')" 
                                   class="btn btn-warning btn-xs">
                                    <i class="fa fa-power-off"></i>
                                </a>
                                <a href="{$_url}plugin/genieacs_device_wifi/{$d.id}" 
                                   class="btn btn-primary btn-xs">
                                    <i class="fa fa-wifi"></i>
                                </a>
                            </td>
                        </tr>
                        {foreachelse}
                        <tr>
                            <td colspan="8" class="text-center">No devices found</td>
                        </tr>
                        {/foreach}
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

{include file="sections/footer.tpl"}
