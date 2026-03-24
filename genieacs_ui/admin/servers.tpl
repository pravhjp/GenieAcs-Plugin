{include file="sections/header.tpl"}

<div class="row">
    <div class="col-md-12">
        <div class="box box-primary">
            <div class="box-header with-border">
                <h3 class="box-title">GenieACS Servers</h3>
                <div class="pull-right">
                    <a href="{$_url}plugin/genieacs_server_add" class="btn btn-primary btn-sm">
                        <i class="fa fa-plus"></i> Add New
                    </a>
                </div>
            </div>
            <div class="box-body">
                <table class="table table-bordered table-striped">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Host</th>
                            <th>Port</th>
                            <th>Protocol</th>
                            <th>Status</th>
                            <th>Last Check</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach $servers as $s}
                        <tr>
                            <td>{$s.id}</td>
                            <td>{$s.name}</td>
                            <td>{$s.host}</td>
                            <td>{$s.port}</td>
                            <td>{$s.protocol|upper}</td>
                            <td>
                                {if $s.status == 'online'}
                                    <span class="label label-success">Online</span>
                                {else}
                                    <span class="label label-danger">Offline</span>
                                {/if}
                            </td>
                            <td>{$s.last_check|default:'Never'}</td>
                            <td>
                                <a href="{$_url}plugin/genieacs_server_edit/{$s.id}" class="btn btn-info btn-xs">
                                    <i class="fa fa-edit"></i>
                                </a>
                                <a href="{$_url}plugin/genieacs_server_test&id={$s.id}" class="btn btn-success btn-xs">
                                    <i class="fa fa-refresh"></i> Test
                                </a>
                                </a>
                                <a href="{$_url}plugin/genieacs_server_delete/{$s.id}" 
                                   onclick="return confirm('Delete this server?')" 
                                   class="btn btn-danger btn-xs">
                                    <i class="fa fa-trash"></i>
                                </a>
                            </td>
                        </tr>
                        {foreachelse}
                        <tr>
                            <td colspan="8" class="text-center">No servers found</td>
                        </tr>
                        {/foreach}
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

{include file="sections/footer.tpl"}
