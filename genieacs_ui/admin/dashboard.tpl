{include file="sections/header.tpl"}

<div class="row">
    <div class="col-lg-3 col-xs-6">
        <div class="small-box bg-primary">
            <div class="inner">
                <h3>{$total_servers}</h3>
                <p>Total Servers</p>
            </div>
            <div class="icon">
                <i class="fa fa-server"></i>
            </div>
            <a href="{$_url}plugin/genieacs_servers" class="small-box-footer">
                Manage <i class="fa fa-arrow-circle-right"></i>
            </a>
        </div>
    </div>
    
    <div class="col-lg-3 col-xs-6">
        <div class="small-box bg-green">
            <div class="inner">
                <h3>{$total_devices}</h3>
                <p>Total Devices</p>
            </div>
            <div class="icon">
                <i class="fa fa-wifi"></i>
            </div>
            <a href="{$_url}plugin/genieacs_devices" class="small-box-footer">
                View <i class="fa fa-arrow-circle-right"></i>
            </a>
        </div>
    </div>
    
    <div class="col-lg-3 col-xs-6">
        <div class="small-box bg-yellow">
            <div class="inner">
                <h3>{$online_devices}</h3>
                <p>Online Devices</p>
            </div>
            <div class="icon">
                <i class="fa fa-signal"></i>
            </div>
        </div>
    </div>
</div>

<div class="row">
    <div class="col-md-12">
        <div class="box box-primary">
            <div class="box-header with-border">
                <h3 class="box-title">Quick Actions</h3>
            </div>
            <div class="box-body">
                <a href="{$_url}plugin/genieacs_server_add" class="btn btn-primary">
                    <i class="fa fa-plus"></i> Add Server
                </a>
                <a href="{$_url}plugin/genieacs_devices" class="btn btn-info">
                    <i class="fa fa-list"></i> View Devices
                </a>
                <a href="{$_url}plugin/genieacs_settings" class="btn btn-default">
                    <i class="fa fa-cog"></i> Settings
                </a>
            </div>
        </div>
    </div>
</div>

{include file="sections/footer.tpl"}
