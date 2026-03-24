{include file="sections/header.tpl"}

<div class="row">
    <div class="col-md-12">
        <div class="box box-primary">
            <div class="box-header with-border">
                <h3 class="box-title">My Modem</h3>
            </div>
            <div class="box-body">
                {if $device}
                    <div class="row">
                        <div class="col-md-6">
                            <div class="info-box bg-{if $device.status == 'online'}green{else}red{/if}">
                                <span class="info-box-icon">
                                    <i class="fa fa-wifi"></i>
                                </span>
                                <div class="info-box-content">
                                    <span class="info-box-text">Status</span>
                                    <span class="info-box-number">
                                        {if $device.status == 'online'}Online{else}Offline{/if}
                                    </span>
                                </div>
                            </div>
                        </div>
                        
                        <div class="col-md-6">
                            <div class="info-box bg-aqua">
                                <span class="info-box-icon">
                                    <i class="fa fa-clock-o"></i>
                                </span>
                                <div class="info-box-content">
                                    <span class="info-box-text">Last Contact</span>
                                    <span class="info-box-number">
                                        {$device.last_contact|timeago}
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <table class="table table-striped">
                        <tr>
                            <th>Device ID</th>
                            <td>{$device.device_id}</td>
                        </tr>
                        <tr>
                            <th>Serial Number</th>
                            <td>{$device.serial_number|default:'N/A'}</td>
                        </tr>
                        <tr>
                            <th>Model</th>
                            <td>{$device.model_name|default:'N/A'}</td>
                        </tr>
                        <tr>
                            <th>WiFi SSID</th>
                            <td>{$device.wifi_ssid|default:'Not Set'}</td>
                        </tr>
                    </table>
                    
                    <hr>
                    
                    <div class="row">
                        <div class="col-md-6">
                            <button onclick="rebootModem()" class="btn btn-warning btn-block">
                                <i class="fa fa-power-off"></i> Reboot Modem
                            </button>
                        </div>
                        <div class="col-md-6">
                            <a href="{$_url}plugin/genieacs_customer_wifi" class="btn btn-primary btn-block">
                                <i class="fa fa-wifi"></i> Change WiFi
                            </a>
                        </div>
                    </div>
                    
                {else}
                    <div class="alert alert-info">
                        <i class="fa fa-info-circle"></i> No modem assigned to your account.
                    </div>
                {/if}
            </div>
        </div>
    </div>
</div>

<script>
function rebootModem() {
    if(confirm('Reboot your modem? Connection will be lost for a few minutes.')) {
        $.post('{$_url}plugin/genieacs_customer_reboot', function(data) {
            if(data.success) {
                alert('Reboot command sent successfully');
            } else {
                alert('Failed to send reboot command');
            }
        });
    }
}
</script>

{include file="sections/footer.tpl"}
