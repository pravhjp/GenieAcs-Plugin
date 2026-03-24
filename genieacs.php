<?php

// Register menu items
register_menu("GenieACS Manager", true, "genieacs_dashboard", 'AFTER_REPORTS', '');

/**
 * Dashboard Page
 */
function genieacs_dashboard()
{
    global $ui, $admin;
    _admin();
    $admin = Admin::_info();

    // Create tables if not exists
    genieacs_create_tables();

    // Get statistics
    $total_servers = ORM::forTable('genieacs_servers')->count();
    $total_devices = ORM::forTable('genieacs_devices')->count();
    $online_devices = ORM::forTable('genieacs_devices')->where('status', 'online')->count();
    $offline_devices = ORM::forTable('genieacs_devices')->where('status', 'offline')->count();
    $mapped_devices = ORM::forTable('genieacs_devices')->where_not_null('customer_id')->count();

    // Get servers
    $servers = ORM::forTable('genieacs_servers')->order_by_desc('priority')->find_many();

    // Get recent activity
    $recent_activity = ORM::forTable('genieacs_logs')
        ->order_by_desc('created_at')
        ->limit(10)
        ->find_many();

    $ui->assign('total_servers', $total_servers);
    $ui->assign('total_devices', $total_devices);
    $ui->assign('online_devices', $online_devices);
    $ui->assign('offline_devices', $offline_devices);
    $ui->assign('mapped_devices', $mapped_devices);
    $ui->assign('servers', $servers);
    $ui->assign('recent_activity', $recent_activity);
    $ui->assign('_title', 'GenieACS Dashboard');
    $ui->assign('_system_menu', 'genieacs_dashboard');
    $ui->assign('_admin', $admin);
    $ui->display(dirname(__FILE__) . '/genieacs_ui/admin/dashboard.tpl');
}

/**
 * Servers List Page
 */
function genieacs_servers()
{
    global $ui, $admin;
    _admin();
    $admin = Admin::_info();

    genieacs_create_tables();

    $servers = ORM::forTable('genieacs_servers')
        ->order_by_desc('priority')
        ->order_by_asc('name')
        ->find_many();

    // Get device counts for each server
    foreach ($servers as $server) {
        $server->device_count = ORM::forTable('genieacs_devices')
            ->where('server_id', $server->id)
            ->count();
        $server->online_count = ORM::forTable('genieacs_devices')
            ->where('server_id', $server->id)
            ->where('status', 'online')
            ->count();
    }

    $ui->assign('servers', $servers);
    $ui->assign('_title', 'GenieACS Servers');
    $ui->assign('_system_menu', 'genieacs_servers');
    $ui->assign('_admin', $admin);
    $ui->display(dirname(__FILE__) . '/genieacs_ui/admin/servers.tpl');
}

/**
 * Add Server Page
 */
function genieacs_server_add() {
    global $ui, $admin;
    _admin();
    $admin = Admin::_info();

    genieacs_create_tables();

    // DEBUG: See what's being posted
    error_log("===== SERVER ADD DEBUG =====");
    error_log("Request Method: " . $_SERVER['REQUEST_METHOD']);
    error_log("POST data: " . print_r($_POST, true));
    
    // Check if ORM is working
    try {
        $test_query = ORM::forTable('genieacs_servers')->count();
        error_log("ORM Test: Table has $test_query records");
    } catch (Exception $e) {
        error_log("ORM Test Failed: " . $e->getMessage());
    }
    
    if (_post('save') == 'yes') {
        error_log("Save button clicked - Processing form");
        
        $name = _post('name');
        $host = _post('host');
        $port = _post('port');
        $protocol = _post('protocol');
        $username = _post('username');
        $password = _post('password');
        $priority = _post('priority', 0);
        $max_devices = _post('max_devices', 1000);
        $timeout = _post('timeout', 30);
        $notes = _post('notes');

        error_log("Name: $name, Host: $host, Port: $port");
        error_log("Protocol: $protocol, Priority: $priority");

        // Validate
        if (empty($name) || empty($host) || empty($port)) {
            $error_msg = 'Please fill all required fields';
            error_log("Validation failed: $error_msg");
            $ui->assign('error', $error_msg);
        } else {
            try {
                error_log("Attempting to create server record...");
                
                $server = ORM::forTable('genieacs_servers')->create();
                $server->name = $name;
                $server->host = $host;
                $server->port = intval($port);  // Ensure integer
                $server->protocol = $protocol;
                $server->username = $username;
                if (!empty($password)) {
                    $server->password = encrypt($password);
                    error_log("Password encrypted");
                }
                $server->priority = intval($priority);
                $server->max_devices = intval($max_devices);
                $server->timeout = intval($timeout);
                $server->notes = $notes;
                $server->status = 'offline'; // Default status
                $server->created_at = date('Y-m-d H:i:s');
                
                error_log("Server object created, attempting save...");
                
                if ($server->save()) {
                    $new_id = $server->id();
                    error_log("SUCCESS: Server saved with ID: " . $new_id);
                    
                    // Verify it was saved
                    $check = ORM::forTable('genieacs_servers')->find_one($new_id);
                    if ($check) {
                        error_log("Verified: Record exists in database");
                    } else {
                        error_log("WARNING: Record not found after save!");
                    }
                    
                    genieacs_log('admin', 'add_server', 'success', "Server added: $name", $new_id);
                    
                    if (_post('test_after_save') == 'on') {
                        error_log("Testing connection for new server");
                        genieacs_test_server_connection($new_id);
                    }
                    
                    error_log("Redirecting to servers list");
                    r2(U . "plugin/genieacs_servers", 's', 'Server added successfully');
                } else {
                    error_log("FAILED: save() returned false");
                    $ui->assign('error', 'Database error: Could not save server');
                }
            } catch (Exception $e) {
                error_log("EXCEPTION: " . $e->getMessage());
                error_log("Exception trace: " . $e->getTraceAsString());
                $ui->assign('error', 'Error: ' . $e->getMessage());
            }
        }
    } else {
        error_log("Save condition NOT met. _post('save') = " . var_export(_post('save'), true));
        error_log("Raw POST save value: " . ($_POST['save'] ?? 'not set'));
    }

    // Get any existing error from session
    if (isset($_SESSION['genieacs_error'])) {
        $ui->assign('error', $_SESSION['genieacs_error']);
        unset($_SESSION['genieacs_error']);
    }

    $ui->assign('_title', 'Add GenieACS Server');
    $ui->assign('_system_menu', 'genieacs_servers');
    $ui->assign('_admin', $admin);
    $ui->display(dirname(__FILE__) . '/genieacs_ui/admin/server_add.tpl');
}

/**
 * Edit Server Page
 */
function genieacs_server_edit($id)
{
    global $ui, $admin;
    _admin();
    $admin = Admin::_info();

    genieacs_create_tables();

    $server = ORM::forTable('genieacs_servers')->find_one($id);
    if (!$server) {
        r2(U . "plugin/genieacs_servers", 'e', 'Server not found');
    }

    if (_post('save') == 'yes') {
        $server->name = _post('name');
        $server->host = _post('host');
        $server->port = _post('port');
        $server->protocol = _post('protocol');
        $server->username = _post('username');
        $password = _post('password');
        if (!empty($password)) {
            $server->password = encrypt($password);
        }
        $server->priority = _post('priority', 0);
        $server->max_devices = _post('max_devices', 1000);
        $server->timeout = _post('timeout', 30);
        $server->notes = _post('notes');
        $server->save();

        genieacs_log('admin', 'edit_server', 'success', "Server edited: {$server->name}", $server->id());

        if (_post('test_after_save') == 'on') {
            genieacs_test_server_connection($server->id());
        }

        r2(U . "plugin/genieacs_servers", 's', 'Server updated successfully');
    }

    // Get server stats
    $server_stats = [
        'total_devices' => ORM::forTable('genieacs_devices')->where('server_id', $server->id)->count(),
        'online_devices' => ORM::forTable('genieacs_devices')->where('server_id', $server->id)->where('status', 'online')->count(),
        'offline_devices' => ORM::forTable('genieacs_devices')->where('server_id', $server->id)->where('status', 'offline')->count(),
        'mapped_devices' => ORM::forTable('genieacs_devices')->where('server_id', $server->id)->where_not_null('customer_id')->count()
    ];

    $ui->assign('server', $server);
    $ui->assign('server_stats', $server_stats);
    $ui->assign('_title', 'Edit GenieACS Server');
    $ui->assign('_system_menu', 'genieacs_servers');
    $ui->assign('_admin', $admin);
    $ui->display(dirname(__FILE__) . '/genieacs_ui/admin/server_edit.tpl');
}

/**
 * Delete Server
 */
function genieacs_server_delete($id)
{
    _admin();

    $server = ORM::forTable('genieacs_servers')->find_one($id);
    if ($server) {
        $name = $server->name;
        // Delete all devices for this server first (cascade not working in some setups)
        ORM::forTable('genieacs_devices')->where('server_id', $id)->delete_many();
        $server->delete();

        genieacs_log('admin', 'delete_server', 'success', "Server deleted: $name");
        r2(U . "plugin/genieacs_servers", 's', 'Server deleted successfully');
    } else {
        r2(U . "plugin/genieacs_servers", 'e', 'Server not found');
    }
}

/**
 * Test Server Connection
 */
function genieacs_server_test() {
    _admin();
    
    $id = _req('id');
    
    if (!$id) {
        r2(U . "plugin/genieacs_servers", 'e', 'Server ID required');
        return;
    }
    
    $result = genieacs_test_server_connection($id);
    
    if ($result['success']) {
        r2(U . "plugin/genieacs_servers", 's', $result['message']);
    } else {
        r2(U . "plugin/genieacs_servers", 'e', $result['message']);
    }
}
/**
 * Sync Devices from Server
 */
function genieacs_server_sync($id)
{
    _admin();

    $result = genieacs_sync_devices_from_server($id);

    if ($result['success']) {
        r2(U . "plugin/genieacs_devices", 's', "Sync completed: {$result['added']} added, {$result['updated']} updated");
    } else {
        r2(U . "plugin/genieacs_servers", 'e', "Sync failed: {$result['message']}");
    }
}

/**
 * Clear Devices from Server
 */
function genieacs_server_clear_devices($id)
{
    _admin();

    $count = ORM::forTable('genieacs_devices')->where('server_id', $id)->count();
    ORM::forTable('genieacs_devices')->where('server_id', $id)->delete_many();

    genieacs_log('admin', 'clear_devices', 'success', "Cleared $count devices from server ID: $id");

    echo json_encode([
        'success' => true,
        'message' => "Cleared $count devices"
    ]);
    die();
}

/**
 * Devices List Page
 */
function genieacs_devices()
{
    global $ui, $admin;
    _admin();
    $admin = Admin::_info();

    genieacs_create_tables();

    $search = _req('search');
    $server_id = _req('server_id');
    $status = _req('status');
    $mapped = _req('mapped');
    $page = _req('page', 1);
    $limit = 20;
    $offset = ($page - 1) * $limit;

    $query = ORM::forTable('genieacs_devices')
        ->table_alias('d')
        ->select('d.*')
        ->select('s.name', 'server_name')
        ->select('c.username', 'customer_username')
        ->select('c.fullname', 'customer_name')
        ->left_outer_join('genieacs_servers', ['d.server_id', '=', 's.id'], 's')
        ->left_outer_join('tbl_customers', ['d.customer_id', '=', 'c.id'], 'c')
        ->order_by_desc('d.last_contact');

    $count_query = ORM::forTable('genieacs_devices');

    if (!empty($search)) {
        $query->where_raw("(d.device_id LIKE ? OR d.serial_number LIKE ? OR d.mac_address LIKE ? OR d.username LIKE ?)", 
            ["%$search%", "%$search%", "%$search%", "%$search%"]);
        $count_query->where_raw("(device_id LIKE ? OR serial_number LIKE ? OR mac_address LIKE ? OR username LIKE ?)", 
            ["%$search%", "%$search%", "%$search%", "%$search%"]);
    }

    if (!empty($server_id)) {
        $query->where('d.server_id', $server_id);
        $count_query->where('server_id', $server_id);
    }

    if (!empty($status)) {
        $query->where('d.status', $status);
        $count_query->where('status', $status);
    }

    if ($mapped == 'yes') {
        $query->where_not_null('d.customer_id');
        $count_query->where_not_null('customer_id');
    } elseif ($mapped == 'no') {
        $query->where_null('d.customer_id');
        $count_query->where_null('customer_id');
    }

    $total = $count_query->count();
    $pages = ceil($total / $limit);

    $devices = $query->limit($limit)->offset($offset)->find_many();

    // Get servers for filter
    $servers = ORM::forTable('genieacs_servers')->order_by_asc('name')->find_many();

    // Get statistics
    $stats = [
        'total' => ORM::forTable('genieacs_devices')->count(),
        'online' => ORM::forTable('genieacs_devices')->where('status', 'online')->count(),
        'offline' => ORM::forTable('genieacs_devices')->where('status', 'offline')->count(),
        'mapped' => ORM::forTable('genieacs_devices')->where_not_null('customer_id')->count()
    ];

    $ui->assign('devices', $devices);
    $ui->assign('servers', $servers);
    $ui->assign('stats', $stats);
    $ui->assign('total', $total);
    $ui->assign('pages', $pages);
    $ui->assign('page', $page);
    $ui->assign('search', $search);
    $ui->assign('server_id', $server_id);
    $ui->assign('status', $status);
    $ui->assign('mapped', $mapped);
    $ui->assign('_title', 'GenieACS Devices');
    $ui->assign('_system_menu', 'genieacs_devices');
    $ui->assign('_admin', $admin);
    $ui->display(dirname(__FILE__) . '/genieacs_ui/admin/devices.tpl');
}

/**
 * View Device Details
 */
function genieacs_device_view($id)
{
    global $ui, $admin;
    _admin();
    $admin = Admin::_info();

    genieacs_create_tables();

    $device = ORM::forTable('genieacs_devices')
        ->table_alias('d')
        ->select('d.*')
        ->select('s.name', 'server_name')
        ->select('s.host', 'host')
        ->select('s.port', 'port')
        ->select('s.protocol', 'protocol')
        ->select('c.username', 'customer_username')
        ->select('c.fullname', 'customer_name')
        ->select('c.phone', 'customer_phone')
        ->select('c.email', 'customer_email')
        ->left_outer_join('genieacs_servers', ['d.server_id', '=', 's.id'], 's')
        ->left_outer_join('tbl_customers', ['d.customer_id', '=', 'c.id'], 'c')
        ->where('d.id', $id)
        ->find_one();

    if (!$device) {
        r2(U . "plugin/genieacs_devices", 'e', 'Device not found');
    }

    // Decrypt passwords
    if (!empty($device->wifi_password)) {
        $device->wifi_password_plain = decrypt($device->wifi_password);
    }

    // Get command history
    $commands = ORM::forTable('genieacs_commands')
        ->where('device_id', $id)
        ->order_by_desc('requested_at')
        ->limit(20)
        ->find_many();

    // Get password history
    $password_history = ORM::forTable('genieacs_password_history')
        ->where('device_id', $id)
        ->order_by_desc('created_at')
        ->limit(10)
        ->find_many();

    // Get customers for assign modal
    $customers = ORM::forTable('tbl_customers')
        ->order_by_asc('username')
        ->find_many();

    $ui->assign('device', $device);
    $ui->assign('commands', $commands);
    $ui->assign('password_history', $password_history);
    $ui->assign('customers', $customers);
    $ui->assign('_title', 'Device Details');
    $ui->assign('_system_menu', 'genieacs_devices');
    $ui->assign('_admin', $admin);
    $ui->display(dirname(__FILE__) . '/genieacs_ui/admin/device_view.tpl');
}

/**
 * Reboot Device
 */
function genieacs_device_reboot($id)
{
    _admin();

    $device = ORM::forTable('genieacs_devices')->find_one($id);
    if (!$device) {
        echo json_encode(['success' => false, 'message' => 'Device not found']);
        die();
    }

    $server = ORM::forTable('genieacs_servers')->find_one($device->server_id);
    if (!$server) {
        echo json_encode(['success' => false, 'message' => 'Server not found']);
        die();
    }

    require_once 'genieacs_lib/GenieACSAPI.php';
    $api = new GenieACSAPI($server);

    $result = $api->rebootDevice($device->device_id);

    if ($result['success']) {
        // Log command
        $cmd = ORM::forTable('genieacs_commands')->create();
        $cmd->device_id = $id;
        $cmd->command = 'reboot';
        $cmd->status = 'sent';
        $cmd->requested_by = $_SESSION['uid'];
        $cmd->requested_at = date('Y-m-d H:i:s');
        $cmd->response = json_encode($result);
        $cmd->save();

        genieacs_log('admin', 'device_reboot', 'success', "Device rebooted: {$device->device_id}", null, $id);

        echo json_encode(['success' => true, 'message' => 'Reboot command sent']);
    } else {
        echo json_encode(['success' => false, 'message' => $result['message']]);
    }
    die();
}

/**
 * Factory Reset Device
 */
function genieacs_device_factory_reset($id)
{
    _admin();

    $device = ORM::forTable('genieacs_devices')->find_one($id);
    if (!$device) {
        echo json_encode(['success' => false, 'message' => 'Device not found']);
        die();
    }

    $server = ORM::forTable('genieacs_servers')->find_one($device->server_id);
    if (!$server) {
        echo json_encode(['success' => false, 'message' => 'Server not found']);
        die();
    }

    require_once 'genieacs_lib/GenieACSAPI.php';
    $api = new GenieACSAPI($server);

    $result = $api->factoryReset($device->device_id);

    if ($result['success']) {
        $cmd = ORM::forTable('genieacs_commands')->create();
        $cmd->device_id = $id;
        $cmd->command = 'factory_reset';
        $cmd->status = 'sent';
        $cmd->requested_by = $_SESSION['uid'];
        $cmd->requested_at = date('Y-m-d H:i:s');
        $cmd->response = json_encode($result);
        $cmd->save();

        genieacs_log('admin', 'device_factory_reset', 'success', "Factory reset: {$device->device_id}", null, $id);

        echo json_encode(['success' => true, 'message' => 'Factory reset command sent']);
    } else {
        echo json_encode(['success' => false, 'message' => $result['message']]);
    }
    die();
}

/**
 * Update Device WiFi
 */
function genieacs_device_wifi($id)
{
    _admin();

    if (_post('ssid') && _post('password')) {
        $device = ORM::forTable('genieacs_devices')->find_one($id);
        if (!$device) {
            echo json_encode(['success' => false, 'message' => 'Device not found']);
            die();
        }

        $server = ORM::forTable('genieacs_servers')->find_one($device->server_id);
        if (!$server) {
            echo json_encode(['success' => false, 'message' => 'Server not found']);
            die();
        }

        $ssid = _post('ssid');
        $password = _post('password');
        $security = _post('security', 'WPA2');

        require_once 'genieacs_lib/GenieACSAPI.php';
        $api = new GenieACSAPI($server);

        $result = $api->setWiFiSettings($device->device_id, $ssid, $password, $security);

        if ($result['success']) {
            // Save old password
            if (!empty($device->wifi_password)) {
                $ph = ORM::forTable('genieacs_password_history')->create();
                $ph->device_id = $id;
                $ph->old_password = $device->wifi_password;
                $ph->new_password = encrypt($password);
                $ph->changed_by = $_SESSION['uid'];
                $ph->change_type = 'wifi';
                $ph->save();
            }

            // Update device
            $device->wifi_ssid = $ssid;
            $device->wifi_password = encrypt($password);
            $device->wifi_security = $security;
            $device->save();

            $cmd = ORM::forTable('genieacs_commands')->create();
            $cmd->device_id = $id;
            $cmd->command = 'set_wifi';
            $cmd->status = 'success';
            $cmd->requested_by = $_SESSION['uid'];
            $cmd->requested_at = date('Y-m-d H:i:s');
            $cmd->response = json_encode($result);
            $cmd->save();

            genieacs_log('admin', 'device_wifi', 'success', "WiFi updated for: {$device->device_id}", null, $id);

            echo json_encode(['success' => true, 'message' => 'WiFi settings updated']);
        } else {
            echo json_encode(['success' => false, 'message' => $result['message']]);
        }
        die();
    }
}

/**
 * Update Device Password
 */
function genieacs_device_update_password($id)
{
    _admin();

    if (_post('password')) {
        $device = ORM::forTable('genieacs_devices')->find_one($id);
        if (!$device) {
            echo json_encode(['success' => false, 'message' => 'Device not found']);
            die();
        }

        $server = ORM::forTable('genieacs_servers')->find_one($device->server_id);
        if (!$server) {
            echo json_encode(['success' => false, 'message' => 'Server not found']);
            die();
        }

        $password = _post('password');
        $type = _post('type', 'admin');

        require_once 'genieacs_lib/GenieACSAPI.php';
        $api = new GenieACSAPI($server);

        $result = $api->setAdminPassword($device->device_id, $password, $type);

        if ($result['success']) {
            // Save old password
            if (!empty($device->admin_password)) {
                $ph = ORM::forTable('genieacs_password_history')->create();
                $ph->device_id = $id;
                $ph->old_password = $device->admin_password;
                $ph->new_password = encrypt($password);
                $ph->changed_by = $_SESSION['uid'];
                $ph->change_type = $type;
                $ph->save();
            }

            $device->admin_password = encrypt($password);
            $device->save();

            $cmd = ORM::forTable('genieacs_commands')->create();
            $cmd->device_id = $id;
            $cmd->command = "set_{$type}_password";
            $cmd->status = 'success';
            $cmd->requested_by = $_SESSION['uid'];
            $cmd->requested_at = date('Y-m-d H:i:s');
            $cmd->response = json_encode($result);
            $cmd->save();

            genieacs_log('admin', 'device_password', 'success', "Password updated for: {$device->device_id}", null, $id);

            echo json_encode(['success' => true, 'message' => 'Password updated']);
        } else {
            echo json_encode(['success' => false, 'message' => $result['message']]);
        }
        die();
    }
}

/**
 * Summon Device
 */
function genieacs_device_summon($id)
{
    _admin();

    $device = ORM::forTable('genieacs_devices')->find_one($id);
    if (!$device) {
        echo json_encode(['success' => false, 'message' => 'Device not found']);
        die();
    }

    $server = ORM::forTable('genieacs_servers')->find_one($device->server_id);
    if (!$server) {
        echo json_encode(['success' => false, 'message' => 'Server not found']);
        die();
    }

    require_once 'genieacs_lib/GenieACSAPI.php';
    $api = new GenieACSAPI($server);

    $result = $api->summonDevice($device->device_id);

    if ($result['success']) {
        $cmd = ORM::forTable('genieacs_commands')->create();
        $cmd->device_id = $id;
        $cmd->command = 'summon';
        $cmd->status = 'sent';
        $cmd->requested_by = $_SESSION['uid'];
        $cmd->requested_at = date('Y-m-d H:i:s');
        $cmd->response = json_encode($result);
        $cmd->save();

        genieacs_log('admin', 'device_summon', 'success', "Device summoned: {$device->device_id}", null, $id);

        echo json_encode(['success' => true, 'message' => 'Summon command sent']);
    } else {
        echo json_encode(['success' => false, 'message' => $result['message']]);
    }
    die();
}

/**
 * Refresh Device Info
 */
function genieacs_device_refresh($id)
{
    _admin();

    $device = ORM::forTable('genieacs_devices')->find_one($id);
    if (!$device) {
        echo json_encode(['success' => false, 'message' => 'Device not found']);
        die();
    }

    $server = ORM::forTable('genieacs_servers')->find_one($device->server_id);
    if (!$server) {
        echo json_encode(['success' => false, 'message' => 'Server not found']);
        die();
    }

    require_once 'genieacs_lib/GenieACSAPI.php';
    $api = new GenieACSAPI($server);

    $details = $api->getDeviceDetails($device->device_id);

    if ($details) {
        $device->model_name = $details['model'] ?? $device->model_name;
        $device->manufacturer = $details['manufacturer'] ?? $device->manufacturer;
        $device->software_version = $details['software_version'] ?? $device->software_version;
        $device->hardware_version = $details['hardware_version'] ?? $device->hardware_version;
        $device->uptime = $details['uptime'] ?? $device->uptime;
        $device->ip_address = $details['ip'] ?? $device->ip_address;
        $device->status = $details['online'] ? 'online' : 'offline';
        $device->last_contact = date('Y-m-d H:i:s');
        $device->save();

        genieacs_log('admin', 'device_refresh', 'success', "Device refreshed: {$device->device_id}", null, $id);

        echo json_encode(['success' => true, 'message' => 'Device info refreshed']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to refresh device']);
    }
    die();
}

/**
 * Assign Device to Customer
 */
function genieacs_device_assign($id)
{
    _admin();

    $customer_id = _post('customer_id');
    $username = _post('username');

    if (empty($customer_id)) {
        echo json_encode(['success' => false, 'message' => 'Customer ID required']);
        die();
    }

    $device = ORM::forTable('genieacs_devices')->find_one($id);
    if (!$device) {
        echo json_encode(['success' => false, 'message' => 'Device not found']);
        die();
    }

    $device->customer_id = $customer_id;
    $device->username = $username;
    $device->save();

    genieacs_log('admin', 'device_assign', 'success', "Device assigned to customer ID: $customer_id", null, $id);

    echo json_encode(['success' => true, 'message' => 'Device assigned successfully']);
    die();
}

/**
 * Unassign Device from Customer
 */
function genieacs_device_unassign($id)
{
    _admin();

    $device = ORM::forTable('genieacs_devices')->find_one($id);
    if (!$device) {
        echo json_encode(['success' => false, 'message' => 'Device not found']);
        die();
    }

    $device->customer_id = null;
    $device->username = null;
    $device->save();

    genieacs_log('admin', 'device_unassign', 'success', "Device unassigned", null, $id);

    echo json_encode(['success' => true, 'message' => 'Device unassigned successfully']);
    die();
}

/**
 * Update Device Tags
 */
function genieacs_device_tags($id)
{
    _admin();

    $tags = _post('tags');

    $device = ORM::forTable('genieacs_devices')->find_one($id);
    if (!$device) {
        echo json_encode(['success' => false, 'message' => 'Device not found']);
        die();
    }

    $device->tags = $tags;
    $device->save();

    echo json_encode(['success' => true, 'message' => 'Tags updated']);
    die();
}

/**
 * Update Device Notes
 */
function genieacs_device_notes($id)
{
    _admin();

    $notes = _post('notes');

    $device = ORM::forTable('genieacs_devices')->find_one($id);
    if (!$device) {
        echo json_encode(['success' => false, 'message' => 'Device not found']);
        die();
    }

    $device->notes = $notes;
    $device->save();

    echo json_encode(['success' => true, 'message' => 'Notes updated']);
    die();
}

/**
 * Update Device Location
 */
function genieacs_device_location($id)
{
    _admin();

    $location = _post('location');
    $latitude = _post('latitude');
    $longitude = _post('longitude');

    $device = ORM::forTable('genieacs_devices')->find_one($id);
    if (!$device) {
        echo json_encode(['success' => false, 'message' => 'Device not found']);
        die();
    }

    $device->location = $location;
    $device->latitude = $latitude;
    $device->longitude = $longitude;
    $device->save();

    echo json_encode(['success' => true, 'message' => 'Location updated']);
    die();
}

/**
 * Get Device Commands History (AJAX)
 */
function genieacs_device_commands($id)
{
    _admin();

    $commands = ORM::forTable('genieacs_commands')
        ->where('device_id', $id)
        ->order_by_desc('requested_at')
        ->limit(50)
        ->find_array();

    echo json_encode($commands);
    die();
}

/**
 * Get Password History (AJAX)
 */
function genieacs_password_history($id)
{
    _admin();

    $history = ORM::forTable('genieacs_password_history')
        ->where('device_id', $id)
        ->order_by_desc('created_at')
        ->find_array();

    echo json_encode($history);
    die();
}

/**
 * Get Customer Activity (AJAX)
 */
function genieacs_customer_activity($id)
{
    _admin();

    $device = ORM::forTable('genieacs_devices')->find_one($id);
    if (!$device || !$device->customer_id) {
        echo json_encode([]);
        die();
    }

    $activity = ORM::forTable('genieacs_logs')
        ->where('device_id', $id)
        ->order_by_desc('created_at')
        ->limit(20)
        ->find_array();

    echo json_encode($activity);
    die();
}

/**
 * Get WiFi Status (AJAX)
 */
function genieacs_wifi_status($id)
{
    _admin();

    $device = ORM::forTable('genieacs_devices')->find_one($id);
    if (!$device) {
        echo json_encode(['success' => false]);
        die();
    }

    $server = ORM::forTable('genieacs_servers')->find_one($device->server_id);
    if (!$server) {
        echo json_encode(['success' => false]);
        die();
    }

    require_once 'genieacs_lib/GenieACSAPI.php';
    $api = new GenieACSAPI($server);

    $status = $api->getWiFiStatus($device->device_id);

    echo json_encode($status);
    die();
}

/**
 * Test WiFi Settings (AJAX)
 */
function genieacs_test_wifi($id)
{
    _admin();

    $device = ORM::forTable('genieacs_devices')->find_one($id);
    if (!$device) {
        echo json_encode(['success' => false, 'message' => 'Device not found']);
        die();
    }

    $server = ORM::forTable('genieacs_servers')->find_one($device->server_id);
    if (!$server) {
        echo json_encode(['success' => false, 'message' => 'Server not found']);
        die();
    }

    require_once 'genieacs_lib/GenieACSAPI.php';
    $api = new GenieACSAPI($server);

    $result = $api->testWiFi($device->device_id);

    echo json_encode($result);
    die();
}

/**
 * Settings Page
 */
function genieacs_settings()
{
    global $ui, $admin;
    _admin();
    $admin = Admin::_info();

    genieacs_create_tables();

    $settings = ORM::forTable('genieacs_settings')->find_many();
    $settings_arr = [];
    foreach ($settings as $s) {
        $settings_arr[$s->setting_key] = $s->setting_value;
    }

    $total_devices = ORM::forTable('genieacs_devices')->count();
    $total_servers = ORM::forTable('genieacs_servers')->count();
    $last_sync = ORM::forTable('genieacs_logs')
        ->where('action', 'sync_devices')
        ->where('status', 'success')
        ->order_by_desc('created_at')
        ->find_one();

    $ui->assign('settings', $settings_arr);
    $ui->assign('total_devices', $total_devices);
    $ui->assign('total_servers', $total_servers);
    $ui->assign('last_sync', $last_sync ? $last_sync->created_at : null);
    $ui->assign('_title', 'GenieACS Settings');
    $ui->assign('_system_menu', 'genieacs_settings');
    $ui->assign('_admin', $admin);
    $ui->display(dirname(__FILE__) . '/genieacs_ui/admin/settings.tpl');
}

/**
 * Save Settings
 */
function genieacs_settings_save()
{
    _admin();

    $allowed_keys = [
        'api_timeout', 'max_devices_per_server', 'default_protocol',
        'keep_password_history', 'password_history_days',
        'auto_sync_interval', 'sync_on_login', 'sync_on_demand',
        'full_sync_daily', 'sync_time', 'auto_assign_devices',
        'customer_can_reboot', 'customer_can_change_wifi',
        'customer_can_view_password', 'customer_can_factory_reset',
        'require_strong_password', 'min_password_length',
        'notify_on_device_offline', 'offline_threshold',
        'notify_on_reboot', 'notify_on_wifi_change',
        'admin_email', 'enable_sms', 'admin_phone',
        'max_retries', 'retry_delay', 'batch_size', 'cache_ttl',
        'compression', 'ssl_verify',
        'debug_mode', 'log_level', 'log_retention'
    ];

    foreach ($_POST as $key => $value) {
        if (in_array($key, $allowed_keys)) {
            $setting = ORM::forTable('genieacs_settings')
                ->where('setting_key', $key)
                ->find_one();

            if (!$setting) {
                $setting = ORM::forTable('genieacs_settings')->create();
                $setting->setting_key = $key;
            }

            $setting->setting_value = $value;
            $setting->save();
        }
    }

    genieacs_log('admin', 'settings_save', 'success', 'Settings updated');

    echo json_encode(['success' => true, 'message' => 'Settings saved']);
    die();
}

/**
 * Reset Settings to Default
 */
function genieacs_settings_reset()
{
    _admin();

    $defaults = [
        'api_timeout' => 30,
        'max_devices_per_server' => 1000,
        'default_protocol' => 'http',
        'keep_password_history' => 1,
        'password_history_days' => 30,
        'auto_sync_interval' => 5,
        'sync_on_login' => 1,
        'sync_on_demand' => 1,
        'full_sync_daily' => 1,
        'sync_time' => '02:00',
        'auto_assign_devices' => 1,
        'customer_can_reboot' => 1,
        'customer_can_change_wifi' => 1,
        'customer_can_view_password' => 0,
        'customer_can_factory_reset' => 0,
        'require_strong_password' => 1,
        'min_password_length' => 8,
        'notify_on_device_offline' => 1,
        'offline_threshold' => 30,
        'notify_on_reboot' => 0,
        'notify_on_wifi_change' => 1,
        'max_retries' => 3,
        'retry_delay' => 2,
        'batch_size' => 100,
        'cache_ttl' => 5,
        'compression' => 0,
        'ssl_verify' => 1,
        'debug_mode' => 0,
        'log_level' => 'error',
        'log_retention' => 30
    ];

    foreach ($defaults as $key => $value) {
        $setting = ORM::forTable('genieacs_settings')
            ->where('setting_key', $key)
            ->find_one();

        if (!$setting) {
            $setting = ORM::forTable('genieacs_settings')->create();
            $setting->setting_key = $key;
        }

        $setting->setting_value = $value;
        $setting->save();
    }

    genieacs_log('admin', 'settings_reset', 'success', 'Settings reset to default');

    echo json_encode(['success' => true, 'message' => 'Settings reset to default']);
    die();
}

/**
 * Test Connection (AJAX)
 */
function genieacs_test_connection() {
    _admin();
    
    $protocol = _post('protocol', 'http');
    $host = _post('host');
    $port = _post('port');
    $username = _post('username');
    $password = _post('password');
    
    if (empty($host) || empty($port)) {
        echo json_encode(['success' => false, 'message' => 'Host and port required']);
        die();
    }
    
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, "$protocol://$host:$port/devices/?limit=1");  // Changed
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_TIMEOUT, 10);
    curl_setopt($ch, CURLOPT_HEADER, true);
    
    if (!empty($username)) {
        curl_setopt($ch, CURLOPT_HTTPAUTH, CURLAUTH_BASIC);
        curl_setopt($ch, CURLOPT_USERPWD, "$username:$password");
    }
    
    $response = curl_exec($ch);
    $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $header_size = curl_getinfo($ch, CURLINFO_HEADER_SIZE);
    $body = substr($response, $header_size);
    curl_close($ch);
    
    if ($http_code == 200) {
        $devices = json_decode($body, true);
        $count = is_array($devices) ? count($devices) : 0;
        
        echo json_encode([
            'success' => true,
            'message' => 'Connection successful',
            'devices' => $count,
            'response_time' => 0
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => "HTTP Error $http_code"
        ]);
    }
    die();
}

/**
 * Test All Server Connections (AJAX)
 */
function genieacs_test_all_connections()
{
    _admin();

    $servers = ORM::forTable('genieacs_servers')->find_many();
    $online = 0;
    $offline = 0;

    foreach ($servers as $server) {
        $result = genieacs_test_server_connection($server->id());
        if ($result['success']) {
            $online++;
        } else {
            $offline++;
        }
    }

    echo json_encode([
        'success' => true,
        'online' => $online,
        'offline' => $offline
    ]);
    die();
}

/**
 * Force Full Sync (AJAX)
 */
function genieacs_force_sync()
{
    _admin();

    $servers = ORM::forTable('genieacs_servers')->where('status', 'online')->find_many();
    $total = 0;
    $added = 0;
    $updated = 0;

    foreach ($servers as $server) {
        $result = genieacs_sync_devices_from_server($server->id());
        if ($result['success']) {
            $added += $result['added'];
            $updated += $result['updated'];
            $total++;
        }
    }

    echo json_encode([
        'success' => true,
        'message' => "Synced $total servers: $added added, $updated updated"
    ]);
    die();
}

/**
 * Clear Old Logs (AJAX)
 */
function genieacs_clear_logs()
{
    _admin();

    $settings = genieacs_get_settings();
    $days = $settings['log_retention'] ?? 30;

    $count = ORM::forTable('genieacs_logs')
        ->where_raw("created_at < DATE_SUB(NOW(), INTERVAL ? DAY)", [$days])
        ->delete_many();

    echo json_encode([
        'success' => true,
        'message' => "Cleared $count old logs"
    ]);
    die();
}

/**
 * View Logs Page
 */
function genieacs_logs()
{
    global $ui, $admin;
    _admin();
    $admin = Admin::_info();

    $page = _req('page', 1);
    $limit = 50;
    $offset = ($page - 1) * $limit;

    $query = ORM::forTable('genieacs_logs')->order_by_desc('created_at');

    $total = $query->count();
    $pages = ceil($total / $limit);

    $logs = $query->limit($limit)->offset($offset)->find_many();

    $ui->assign('logs', $logs);
    $ui->assign('total', $total);
    $ui->assign('pages', $pages);
    $ui->assign('page', $page);
    $ui->assign('_title', 'GenieACS Logs');
    $ui->assign('_system_menu', 'genieacs_logs');
    $ui->assign('_admin', $admin);
    $ui->display(dirname(__FILE__) . '/genieacs_ui/admin/logs.tpl');
}

/**
 * Export Devices to CSV
 */
function genieacs_export()
{
    _admin();

    $search = _req('search');
    $server_id = _req('server_id');
    $status = _req('status');
    $mapped = _req('mapped');

    $query = ORM::forTable('genieacs_devices')
        ->table_alias('d')
        ->select('d.*')
        ->select('s.name', 'server_name')
        ->select('c.username', 'customer_username')
        ->left_outer_join('genieacs_servers', ['d.server_id', '=', 's.id'], 's')
        ->left_outer_join('tbl_customers', ['d.customer_id', '=', 'c.id'], 'c');

    if (!empty($search)) {
        $query->where_raw("(d.device_id LIKE ? OR d.serial_number LIKE ? OR d.mac_address LIKE ?)", 
            ["%$search%", "%$search%", "%$search%"]);
    }

    if (!empty($server_id)) {
        $query->where('d.server_id', $server_id);
    }

    if (!empty($status)) {
        $query->where('d.status', $status);
    }

    if ($mapped == 'yes') {
        $query->where_not_null('d.customer_id');
    } elseif ($mapped == 'no') {
        $query->where_null('d.customer_id');
    }

    $devices = $query->find_array();

    $filename = 'genieacs_devices_' . date('Y-m-d_H-i-s') . '.csv';

    header('Content-Type: text/csv');
    header('Content-Disposition: attachment; filename="' . $filename . '"');

    $output = fopen('php://output', 'w');

    // Headers
    fputcsv($output, [
        'ID', 'Device ID', 'Serial Number', 'MAC Address', 'Model',
        'Manufacturer', 'Software Version', 'Server', 'Customer',
        'Status', 'Last Contact', 'WiFi SSID', 'Location', 'Tags'
    ]);

    foreach ($devices as $d) {
        fputcsv($output, [
            $d['id'],
            $d['device_id'],
            $d['serial_number'],
            $d['mac_address'],
            $d['model_name'],
            $d['manufacturer'],
            $d['software_version'],
            $d['server_name'],
            $d['customer_username'],
            $d['status'],
            $d['last_contact'],
            $d['wifi_ssid'],
            $d['location'],
            $d['tags']
        ]);
    }

    fclose($output);
    die();
}

/**
 * Customer Modem Page
 */
function genieacs_my_modem()
{
    global $ui, $user;
    _customer();
    $user = Customer::_info();

    genieacs_create_tables();

    $device = ORM::forTable('genieacs_devices')
        ->where('customer_id', $user['id'])
        ->find_one();

    if ($device) {
        // Get server info
        $server = ORM::forTable('genieacs_servers')->find_one($device->server_id);
        if ($server) {
            $device->server_name = $server->name;
        }

        // Decrypt password if needed
        if (!empty($device->wifi_password)) {
            $device->wifi_password_plain = decrypt($device->wifi_password);
        }
    }

    $settings = genieacs_get_settings();

    $ui->assign('device', $device);
    $ui->assign('settings', $settings);
    $ui->assign('_title', 'My Modem');
    $ui->assign('_system_menu', 'genieacs_my_modem');
    $ui->assign('_user', $user);
    $ui->display(dirname(__FILE__) . '/genieacs_ui/customer/modem.tpl');
}

/**
 * Customer WiFi Page
 */
function genieacs_customer_wifi()
{
    global $ui, $user;
    _customer();
    $user = Customer::_info();

    genieacs_create_tables();

    $settings = genieacs_get_settings();
    if (!$settings['customer_can_change_wifi']) {
        r2(U . "plugin/genieacs_my_modem", 'e', 'WiFi change not allowed');
    }

    $device = ORM::forTable('genieacs_devices')
        ->where('customer_id', $user['id'])
        ->find_one();

    if (!$device) {
        r2(U . "plugin/genieacs_my_modem", 'e', 'No device found');
    }

    if (!empty($device->wifi_password)) {
        $device->wifi_password_plain = decrypt($device->wifi_password);
    }

    $ui->assign('device', $device);
    $ui->assign('_title', 'Change WiFi Settings');
    $ui->assign('_system_menu', 'genieacs_customer_wifi');
    $ui->assign('_user', $user);
    $ui->display(dirname(__FILE__) . '/genieacs_ui/customer/wifi.tpl');
}

/**
 * Customer WiFi Save (AJAX)
 */
function genieacs_customer_wifi_save()
{
    _customer();

    $user = Customer::_info();

    $settings = genieacs_get_settings();
    if (!$settings['customer_can_change_wifi']) {
        echo json_encode(['success' => false, 'message' => 'WiFi change not allowed']);
        die();
    }

    $device = ORM::forTable('genieacs_devices')
        ->where('customer_id', $user['id'])
        ->find_one();

    if (!$device) {
        echo json_encode(['success' => false, 'message' => 'No device found']);
        die();
    }

    $server = ORM::forTable('genieacs_servers')->find_one($device->server_id);
    if (!$server) {
        echo json_encode(['success' => false, 'message' => 'Server not found']);
        die();
    }

    $ssid = _post('ssid');
    $password = _post('password');
    $security = _post('security', 'WPA2');

    // Validate
    if (empty($ssid) || empty($password)) {
        echo json_encode(['success' => false, 'message' => 'SSID and password required']);
        die();
    }

    if ($settings['require_strong_password'] && strlen($password) < $settings['min_password_length']) {
        echo json_encode(['success' => false, 'message' => "Password must be at least {$settings['min_password_length']} characters"]);
        die();
    }

    require_once 'genieacs_lib/GenieACSAPI.php';
    $api = new GenieACSAPI($server);

    $result = $api->setWiFiSettings($device->device_id, $ssid, $password, $security);

    if ($result['success']) {
        // Save password history
        if ($settings['keep_password_history']) {
            $ph = ORM::forTable('genieacs_password_history')->create();
            $ph->device_id = $device->id;
            $ph->old_password = $device->wifi_password;
            $ph->new_password = encrypt($password);
            $ph->changed_by = $user['id'];
            $ph->change_type = 'wifi';
            $ph->save();
        }

        // Update device
        $device->wifi_ssid = $ssid;
        $device->wifi_password = encrypt($password);
        $device->wifi_security = $security;
        $device->save();

        genieacs_log('customer', 'wifi_change', 'success', "WiFi changed for device: {$device->device_id}", null, $device->id);

        echo json_encode(['success' => true, 'message' => 'WiFi settings updated']);
    } else {
        echo json_encode(['success' => false, 'message' => $result['message']]);
    }
    die();
}

/**
 * Customer Reboot Device (AJAX)
 */
function genieacs_customer_reboot()
{
    _customer();

    $user = Customer::_info();

    $settings = genieacs_get_settings();
    if (!$settings['customer_can_reboot']) {
        echo json_encode(['success' => false, 'message' => 'Reboot not allowed']);
        die();
    }

    $device = ORM::forTable('genieacs_devices')
        ->where('customer_id', $user['id'])
        ->find_one();

    if (!$device) {
        echo json_encode(['success' => false, 'message' => 'No device found']);
        die();
    }

    $server = ORM::forTable('genieacs_servers')->find_one($device->server_id);
    if (!$server) {
        echo json_encode(['success' => false, 'message' => 'Server not found']);
        die();
    }

    require_once 'genieacs_lib/GenieACSAPI.php';
    $api = new GenieACSAPI($server);

    $result = $api->rebootDevice($device->device_id);

    if ($result['success']) {
        genieacs_log('customer', 'device_reboot', 'success', "Device rebooted: {$device->device_id}", null, $device->id);
        echo json_encode(['success' => true, 'message' => 'Reboot command sent']);
    } else {
        echo json_encode(['success' => false, 'message' => $result['message']]);
    }
    die();
}

/**
 * Get WiFi History (AJAX) for customer
 */
function genieacs_wifi_history()
{
    _customer();

    $user = Customer::_info();

    $device = ORM::forTable('genieacs_devices')
        ->where('customer_id', $user['id'])
        ->find_one();

    if (!$device) {
        echo json_encode([]);
        die();
    }

    $history = ORM::forTable('genieacs_password_history')
        ->where('device_id', $device->id)
        ->where('change_type', 'wifi')
        ->order_by_desc('created_at')
        ->limit(10)
        ->find_array();

    echo json_encode($history);
    die();
}

// ============================================
// HELPER FUNCTIONS
// ============================================

/**
 * Create database tables if not exist
 */
function genieacs_create_tables()
{
    try {
        ORM::forTable('genieacs_servers')->find_one();
    } catch (Exception $e) {
        ORM::forTable('tbl_customer')->raw_execute("
            CREATE TABLE IF NOT EXISTS `genieacs_servers` (
                `id` int(11) NOT NULL AUTO_INCREMENT,
                `name` varchar(100) NOT NULL,
                `host` varchar(255) NOT NULL,
                `port` int(11) NOT NULL DEFAULT 7557,
                `protocol` enum('http','https') DEFAULT 'http',
                `username` varchar(100) DEFAULT NULL,
                `password` varchar(255) DEFAULT NULL,
                `status` enum('online','offline','maintenance') DEFAULT 'offline',
                `priority` int(11) DEFAULT 0,
                `max_devices` int(11) DEFAULT 1000,
                `timeout` int(11) DEFAULT 30,
                `last_check` datetime DEFAULT NULL,
                `response_time` float DEFAULT NULL,
                `notes` text,
                `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
                PRIMARY KEY (`id`),
                KEY `status` (`status`),
                KEY `priority` (`priority`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ");

        ORM::forTable('tbl_customer')->raw_execute("
            CREATE TABLE IF NOT EXISTS `genieacs_devices` (
                `id` int(11) NOT NULL AUTO_INCREMENT,
                `server_id` int(11) NOT NULL,
                `device_id` varchar(255) NOT NULL,
                `serial_number` varchar(100) DEFAULT NULL,
                `mac_address` varchar(17) DEFAULT NULL,
                `model_name` varchar(100) DEFAULT NULL,
                `manufacturer` varchar(100) DEFAULT NULL,
                `software_version` varchar(50) DEFAULT NULL,
                `hardware_version` varchar(50) DEFAULT NULL,
                `customer_id` int(11) DEFAULT NULL,
                `username` varchar(50) DEFAULT NULL,
                `location` varchar(255) DEFAULT NULL,
                `latitude` decimal(10,8) DEFAULT NULL,
                `longitude` decimal(11,8) DEFAULT NULL,
                `status` enum('online','offline','provisioning','disabled') DEFAULT 'offline',
                `last_contact` datetime DEFAULT NULL,
                `first_seen` datetime DEFAULT NULL,
                `uptime` int(11) DEFAULT 0,
                `signal_strength` int(11) DEFAULT NULL,
                `wifi_ssid` varchar(100) DEFAULT NULL,
                `wifi_password` varchar(255) DEFAULT NULL,
                `wifi_security` varchar(20) DEFAULT 'WPA2',
                `admin_password` varchar(255) DEFAULT NULL,
                `connection_type` varchar(50) DEFAULT NULL,
                `ip_address` varchar(45) DEFAULT NULL,
                `tags` text DEFAULT NULL,
                `notes` text DEFAULT NULL,
                `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
                PRIMARY KEY (`id`),
                UNIQUE KEY `device_id` (`device_id`),
                UNIQUE KEY `serial_number` (`serial_number`),
                KEY `server_id` (`server_id`),
                KEY `customer_id` (`customer_id`),
                KEY `status` (`status`),
                KEY `last_contact` (`last_contact`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ");

        ORM::forTable('tbl_customer')->raw_execute("
            CREATE TABLE IF NOT EXISTS `genieacs_password_history` (
                `id` int(11) NOT NULL AUTO_INCREMENT,
                `device_id` int(11) NOT NULL,
                `old_password` varchar(255) NOT NULL,
                `new_password` varchar(255) NOT NULL,
                `changed_by` int(11) DEFAULT NULL,
                `change_type` enum('wifi','admin','user') DEFAULT 'wifi',
                `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                PRIMARY KEY (`id`),
                KEY `device_id` (`device_id`),
                KEY `changed_by` (`changed_by`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ");

        ORM::forTable('tbl_customer')->raw_execute("
            CREATE TABLE IF NOT EXISTS `genieacs_commands` (
                `id` int(11) NOT NULL AUTO_INCREMENT,
                `device_id` int(11) NOT NULL,
                `command` varchar(50) NOT NULL,
                `parameters` text DEFAULT NULL,
                `status` enum('pending','sent','success','failed') DEFAULT 'pending',
                `requested_by` int(11) DEFAULT NULL,
                `requested_at` datetime DEFAULT NULL,
                `executed_at` datetime DEFAULT NULL,
                `response` text DEFAULT NULL,
                `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                PRIMARY KEY (`id`),
                KEY `device_id` (`device_id`),
                KEY `status` (`status`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ");

        ORM::forTable('tbl_customer')->raw_execute("
            CREATE TABLE IF NOT EXISTS `genieacs_logs` (
                `id` int(11) NOT NULL AUTO_INCREMENT,
                `server_id` int(11) DEFAULT NULL,
                `device_id` int(11) DEFAULT NULL,
                `action` varchar(100) NOT NULL,
                `status` varchar(50) DEFAULT NULL,
                `message` text,
                `user_id` int(11) DEFAULT NULL,
                `ip_address` varchar(45) DEFAULT NULL,
                `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                PRIMARY KEY (`id`),
                KEY `server_id` (`server_id`),
                KEY `device_id` (`device_id`),
                KEY `created_at` (`created_at`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ");

        ORM::forTable('tbl_customer')->raw_execute("
            CREATE TABLE IF NOT EXISTS `genieacs_settings` (
                `id` int(11) NOT NULL AUTO_INCREMENT,
                `setting_key` varchar(100) NOT NULL,
                `setting_value` text,
                `description` varchar(255) DEFAULT NULL,
                `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
                PRIMARY KEY (`id`),
                UNIQUE KEY `setting_key` (`setting_key`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ");

        // Insert default settings
        $defaults = [
            'api_timeout' => 30,
            'max_devices_per_server' => 1000,
            'default_protocol' => 'http',
            'keep_password_history' => 1,
            'password_history_days' => 30,
            'auto_sync_interval' => 5,
            'sync_on_login' => 1,
            'sync_on_demand' => 1,
            'full_sync_daily' => 1,
            'sync_time' => '02:00',
            'auto_assign_devices' => 1,
            'customer_can_reboot' => 1,
            'customer_can_change_wifi' => 1,
            'customer_can_view_password' => 0,
            'customer_can_factory_reset' => 0,
            'require_strong_password' => 1,
            'min_password_length' => 8,
            'notify_on_device_offline' => 1,
            'offline_threshold' => 30,
            'notify_on_reboot' => 0,
            'notify_on_wifi_change' => 1,
            'max_retries' => 3,
            'retry_delay' => 2,
            'batch_size' => 100,
            'cache_ttl' => 5,
            'compression' => 0,
            'ssl_verify' => 1,
            'debug_mode' => 0,
            'log_level' => 'error',
            'log_retention' => 30
        ];

        foreach ($defaults as $key => $value) {
            $exists = ORM::forTable('genieacs_settings')
                ->where('setting_key', $key)
                ->count();

            if (!$exists) {
                $setting = ORM::forTable('genieacs_settings')->create();
                $setting->setting_key = $key;
                $setting->setting_value = $value;
                $setting->save();
            }
        }
    }
}

/**
 * Test server connection and update status
 */
function genieacs_test_server_connection($server_id)
{
    $server = ORM::forTable('genieacs_servers')->find_one($server_id);
    if (!$server) {
        return ['success' => false, 'message' => 'Server not found'];
    }

    require_once 'genieacs_lib/GenieACSAPI.php';
    $api = new GenieACSAPI($server);

    $start = microtime(true);
    $result = $api->testConnection();
    $response_time = round((microtime(true) - $start) * 1000);

    $server->status = $result['success'] ? 'online' : 'offline';
    $server->last_check = date('Y-m-d H:i:s');
    $server->response_time = $response_time;
    $server->save();

    if ($result['success']) {
        genieacs_log('system', 'server_test', 'success', "Server {$server->name} is online", $server_id);
        return [
            'success' => true,
            'message' => "Server is online (Response: {$response_time}ms)",
            'response_time' => $response_time
        ];
    } else {
        genieacs_log('system', 'server_test', 'error', "Server {$server->name} is offline: {$result['message']}", $server_id);
        return [
            'success' => false,
            'message' => "Server is offline: {$result['message']}"
        ];
    }
}

/**
 * Sync devices from server
 */
function genieacs_sync_devices_from_server($server_id)
{
    $server = ORM::forTable('genieacs_servers')->find_one($server_id);
    if (!$server) {
        return ['success' => false, 'message' => 'Server not found'];
    }

    if ($server->status != 'online') {
        return ['success' => false, 'message' => 'Server is offline'];
    }

    require_once 'genieacs_lib/GenieACSAPI.php';
    $api = new GenieACSAPI($server);

    $devices = $api->getAllDevices($server->max_devices);

    $stats = ['added' => 0, 'updated' => 0];

    foreach ($devices as $device_data) {
        $existing = ORM::forTable('genieacs_devices')
            ->where('device_id', $device_data['id'])
            ->find_one();

        $device_info = [
            'server_id' => $server_id,
            'device_id' => $device_data['id'],
            'serial_number' => $device_data['serial'] ?? null,
            'mac_address' => $device_data['mac'] ?? null,
            'model_name' => $device_data['model'] ?? null,
            'manufacturer' => $device_data['manufacturer'] ?? null,
            'software_version' => $device_data['software_version'] ?? null,
            'hardware_version' => $device_data['hardware_version'] ?? null,
            'status' => $device_data['online'] ? 'online' : 'offline',
            'last_contact' => $device_data['last_contact'] ?? date('Y-m-d H:i:s'),
            'first_seen' => $device_data['first_seen'] ?? date('Y-m-d H:i:s'),
            'uptime' => $device_data['uptime'] ?? 0,
            'ip_address' => $device_data['ip'] ?? null,
            'connection_type' => $device_data['connection_type'] ?? null
        ];

        if ($existing) {
            $existing->set($device_info);
            $existing->save();
            $stats['updated']++;
        } else {
            $device = ORM::forTable('genieacs_devices')->create();
            $device->set($device_info);
            $device->save();
            $stats['added']++;
        }
    }

    genieacs_log('system', 'sync_devices', 'success', 
        "Synced server {$server->name}: {$stats['added']} added, {$stats['updated']} updated", $server_id);

    return [
        'success' => true,
        'added' => $stats['added'],
        'updated' => $stats['updated'],
        'total' => count($devices)
    ];
}

/**
 * Get plugin settings
 */
function genieacs_get_settings()
{
    $settings = [];
    $rows = ORM::forTable('genieacs_settings')->find_many();

    foreach ($rows as $row) {
        $settings[$row->setting_key] = $row->setting_value;
    }

    // Default values
    $defaults = [
        'auto_sync_interval' => 5,
        'sync_on_login' => 1,
        'keep_password_history' => 1,
        'customer_can_reboot' => 1,
        'customer_can_change_wifi' => 1,
        'notify_on_device_offline' => 1,
        'offline_threshold' => 30,
        'api_timeout' => 30,
        'max_devices_per_server' => 1000,
        'debug_mode' => 0
    ];

    return array_merge($defaults, $settings);
}

/**
 * Log activity
 */
function genieacs_log($user_type, $action, $status, $message, $server_id = null, $device_id = null)
{
    $user_id = null;
    if ($user_type == 'admin' && isset($_SESSION['uid'])) {
        $user_id = $_SESSION['uid'];
    } elseif ($user_type == 'customer' && isset($_SESSION['cid'])) {
        $user_id = $_SESSION['cid'];
    }

    $log = ORM::forTable('genieacs_logs')->create();
    $log->server_id = $server_id;
    $log->device_id = $device_id;
    $log->action = $action;
    $log->status = $status;
    $log->message = $message;
    $log->user_id = $user_id;
    $log->ip_address = $_SERVER['REMOTE_ADDR'] ?? null;
    $log->save();
}

/**
 * Create tables on plugin activation
 */
function genieacs_activate()
{
    genieacs_create_tables();
    genieacs_log('system', 'plugin_activate', 'success', 'Plugin activated');
}

/**
 * Cleanup on plugin deactivation
 */
function genieacs_deactivate()
{
    genieacs_log('system', 'plugin_deactivate', 'success', 'Plugin deactivated');
}

// Register activation/deactivation hooks
register_activation_hook(__FILE__, 'genieacs_activate');
register_deactivation_hook(__FILE__, 'genieacs_deactivate');

// Create tables on load
genieacs_create_tables();

/**
 * Export Logs to CSV
 */
function genieacs_export_logs()
{
    _admin();

    $action = _req('action');
    $status = _req('status');
    $user_type = _req('user_type');
    $date = _req('date');

    $query = ORM::forTable('genieacs_logs')->order_by_desc('created_at');

    if (!empty($action)) {
        $query->where('action', $action);
    }

    if (!empty($status)) {
        $query->where('status', $status);
    }

    if (!empty($date)) {
        $query->where_raw("DATE(created_at) = ?", [$date]);
    }

    if (!empty($user_type)) {
        if ($user_type == 'admin') {
            $query->where_not_null('user_id')->where_raw("user_id IN (SELECT id FROM tbl_users)");
        } elseif ($user_type == 'customer') {
            $query->where_not_null('user_id')->where_raw("user_id IN (SELECT id FROM tbl_customers)");
        } elseif ($user_type == 'system') {
            $query->where_null('user_id');
        }
    }

    $logs = $query->find_array();

    $filename = 'genieacs_logs_' . date('Y-m-d_H-i-s') . '.csv';

    header('Content-Type: text/csv');
    header('Content-Disposition: attachment; filename="' . $filename . '"');

    $output = fopen('php://output', 'w');

    // Headers
    fputcsv($output, [
        'ID', 'Time', 'Action', 'Status', 'Message', 
        'Server ID', 'Device ID', 'User ID', 'IP Address'
    ]);

    foreach ($logs as $log) {
        fputcsv($output, [
            $log['id'],
            $log['created_at'],
            $log['action'],
            $log['status'],
            $log['message'],
            $log['server_id'],
            $log['device_id'],
            $log['user_id'],
            $log['ip_address']
        ]);
    }

    fclose($output);
    die();
}

/**
 * Get Log Details (AJAX)
 */
function genieacs_log_details($id)
{
    _admin();

    $log = ORM::forTable('genieacs_logs')->find_one($id);
    
    if ($log) {
        $log = $log->as_array();
        
        // Add username if available
        if ($log['user_id']) {
            // Check if admin
            $admin = ORM::forTable('tbl_users')->find_one($log['user_id']);
            if ($admin) {
                $log['username'] = $admin->username;
                $log['user_type'] = 'admin';
            } else {
                // Check if customer
                $customer = ORM::forTable('tbl_customers')->find_one($log['user_id']);
                if ($customer) {
                    $log['username'] = $customer->username;
                    $log['user_type'] = 'customer';
                }
            }
        }
        
        // Add server name if available
        if ($log['server_id']) {
            $server = ORM::forTable('genieacs_servers')->find_one($log['server_id']);
            if ($server) {
                $log['server_name'] = $server->name;
            }
        }
        
        // Add device info if available
        if ($log['device_id']) {
            $device = ORM::forTable('genieacs_devices')->find_one($log['device_id']);
            if ($device) {
                $log['device_name'] = $device->device_id;
            }
        }
        
        echo json_encode($log);
    } else {
        echo json_encode(['error' => 'Log not found']);
    }
    die();
}

/**
 * Get Logs Count (AJAX)
 */
function genieacs_logs_count()
{
    _admin();

    $last_check = _req('last_check', date('Y-m-d H:i:s', strtotime('-1 minute')));

    $new = ORM::forTable('genieacs_logs')
        ->where_raw("created_at > ?", [$last_check])
        ->count();

    echo json_encode(['new' => $new]);
    die();
}
