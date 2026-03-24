<?php
/**
 * GenieACS API Wrapper Class
 * Handles all communication with GenieACS server
 * Compatible with GenieACS v1.2.x and above
 */

class GenieACSAPI {
    private $server;
    private $base_url;
    private $timeout = 30;
    private $debug = false;
    private $ssl_verify = true;
    private $max_retries = 3;
    
    /**
     * Constructor
     * @param array $server Server configuration
     * @param bool $debug Enable debug mode
     */
    public function __construct($server, $debug = false) {
        $this->server = $server;
        $this->base_url = $server['protocol'] . '://' . $server['host'] . ':' . $server['port'];
        $this->timeout = isset($server['timeout']) ? $server['timeout'] : 30;
        $this->debug = $debug;
        
        // Get settings if available
        $settings = $this->getSettings();
        if ($settings) {
            $this->timeout = $settings['api_timeout'] ?? $this->timeout;
            $this->debug = $settings['debug_mode'] ?? $this->debug;
            $this->ssl_verify = $settings['ssl_verify'] ?? true;
            $this->max_retries = $settings['max_retries'] ?? 3;
        }
    }
    
    /**
     * Get plugin settings from database
     */
    private function getSettings() {
        try {
            if (function_exists('genieacs_get_settings')) {
                return genieacs_get_settings();
            }
        } catch (Exception $e) {
            if ($this->debug) {
                $this->logError('getSettings', $e->getMessage());
            }
        }
        return null;
    }
    
    /**
     * Test connection to GenieACS
     * @return array Connection test result
     */
    public function testConnection() {
        try {
            // Try different paths to find the correct API endpoint
            $paths = [
                '/devices/?limit=1',      // Found working in v1.2.14
                '/api/devices/?limit=1',
                '/nbi/devices/?limit=1',
                '/rest/devices/?limit=1'
            ];
            
            $success = false;
            $response = null;
            $used_path = '';
            
            foreach ($paths as $path) {
                try {
                    $response = $this->makeRequest($path, 'GET', null, false); // Don't throw on 404
                    if ($response !== null) {
                        $success = true;
                        $used_path = $path;
                        break;
                    }
                } catch (Exception $e) {
                    // Try next path
                    continue;
                }
            }
            
            if ($success) {
                // Try to get server info (optional)
                $version = 'Unknown';
                try {
                    $info = $this->makeRequest('/version', 'GET', null, false);
                    if ($info && isset($info['version'])) {
                        $version = $info['version'];
                    }
                } catch (Exception $e) {
                    // Ignore version fetch error
                }
                
                return [
                    'success' => true,
                    'message' => 'Connection successful',
                    'devices' => is_array($response) ? count($response) : 0,
                    'version' => $version,
                    'path' => $used_path,
                    'details' => $response
                ];
            } else {
                return [
                    'success' => false,
                    'message' => 'Could not find valid API endpoint. Tried: ' . implode(', ', $paths)
                ];
            }
            
        } catch (Exception $e) {
            return [
                'success' => false,
                'message' => $e->getMessage(),
                'details' => $this->debug ? $e->getTraceAsString() : null
            ];
        }
    }
    
    /**
     * Get all devices with pagination
     * @param int $limit Maximum devices to fetch
     * @param int $offset Offset for pagination
     * @return array List of devices
     */
    public function getAllDevices($limit = 1000, $offset = 0) {
        $devices = [];
        $fetched = 0;
        $current_offset = $offset;
        $batch_size = min(100, $limit); // Fetch in batches of 100
        
        try {
            while ($fetched < $limit) {
                $batch_limit = min($batch_size, $limit - $fetched);
                $response = $this->makeRequest("/devices/?limit=$batch_limit&offset=$current_offset");
                
                if (!is_array($response) || empty($response)) {
                    break;
                }
                
                foreach ($response as $device) {
                    $devices[] = $this->parseDeviceData($device);
                    $fetched++;
                }
                
                if (count($response) < $batch_limit) {
                    break; // No more devices
                }
                
                $current_offset += $batch_limit;
            }
            
            return $devices;
            
        } catch (Exception $e) {
            $this->logError('getAllDevices', $e->getMessage());
            return $devices;
        }
    }
    
    /**
     * Get device details by ID
     * @param string $device_id Device ID
     * @return array|null Device details or null
     */
    public function getDeviceDetails($device_id) {
        try {
            $response = $this->makeRequest("/devices/$device_id");
            
            if ($response && is_array($response)) {
                return $this->parseDeviceData($response);
            }
            
            return null;
            
        } catch (Exception $e) {
            $this->logError('getDeviceDetails', $e->getMessage());
            return null;
        }
    }
    
    /**
     * Get device status
     * @param string $device_id Device ID
     * @return array Device status information
     */
    public function getDeviceStatus($device_id) {
        try {
            $response = $this->makeRequest("/devices/$device_id");
            
            $status = [
                'online' => false,
                'last_contact' => null,
                'uptime' => 0,
                'signal' => null,
                'ip' => null,
                'connection_status' => 'unknown'
            ];
            
            if ($response && is_array($response)) {
                // Check last contact time (online if contacted in last 30 minutes)
                if (isset($response['_lastContact'])) {
                    $last_contact = strtotime($response['_lastContact']);
                    $status['last_contact'] = $response['_lastContact'];
                    $status['online'] = (time() - $last_contact) < 1800; // 30 minutes
                }
                
                // Parse parameters if available
                if (isset($response['parameters']) && is_array($response['parameters'])) {
                    $params = $response['parameters'];
                    
                    // Try to get uptime
                    if (isset($params['InternetGatewayDevice.DeviceInfo.Uptime'])) {
                        $status['uptime'] = $params['InternetGatewayDevice.DeviceInfo.Uptime'];
                    }
                    
                    // Try to get IP
                    if (isset($params['InternetGatewayDevice.WANDevice.1.WANConnectionDevice.1.WANIPConnection.1.ExternalIPAddress'])) {
                        $status['ip'] = $params['InternetGatewayDevice.WANDevice.1.WANConnectionDevice.1.WANIPConnection.1.ExternalIPAddress'];
                    }
                    
                    // Try to get connection status
                    if (isset($params['InternetGatewayDevice.WANDevice.1.WANConnectionDevice.1.WANIPConnection.1.ConnectionStatus'])) {
                        $status['connection_status'] = $params['InternetGatewayDevice.WANDevice.1.WANConnectionDevice.1.WANIPConnection.1.ConnectionStatus'];
                    }
                    
                    // Try to get signal strength
                    if (isset($params['Device.Services.X_TELUS_Network.1.X_TELUS_LTE.RSRP'])) {
                        $status['signal'] = $params['Device.Services.X_TELUS_Network.1.X_TELUS_LTE.RSRP'];
                    } elseif (isset($params['InternetGatewayDevice.DeviceInfo.X_ZTE-COM_SignalStrength'])) {
                        $status['signal'] = $params['InternetGatewayDevice.DeviceInfo.X_ZTE-COM_SignalStrength'];
                    }
                }
            }
            
            return $status;
            
        } catch (Exception $e) {
            $this->logError('getDeviceStatus', $e->getMessage());
            return ['online' => false, 'error' => $e->getMessage()];
        }
    }
    
    /**
     * Get WiFi status for device
     * @param string $device_id Device ID
     * @return array WiFi status
     */
    public function getWiFiStatus($device_id) {
        try {
            $response = $this->makeRequest("/devices/$device_id");
            
            $wifi = [
                'success' => false,
                'ssid' => null,
                'security' => null,
                'channel' => null,
                'clients' => 0
            ];
            
            if ($response && is_array($response) && isset($response['parameters'])) {
                $params = $response['parameters'];
                
                // Try to get SSID
                if (isset($params['InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.SSID'])) {
                    $wifi['ssid'] = $params['InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.SSID'];
                    $wifi['success'] = true;
                }
                
                // Try to get security mode
                if (isset($params['InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.BeaconType'])) {
                    $wifi['security'] = $params['InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.BeaconType'];
                }
                
                // Try to get channel
                if (isset($params['InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.Channel'])) {
                    $wifi['channel'] = $params['InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.Channel'];
                }
                
                // Try to get connected clients count
                if (isset($params['InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.AssociatedDeviceNumberOfEntries'])) {
                    $wifi['clients'] = $params['InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.AssociatedDeviceNumberOfEntries'];
                }
            }
            
            return $wifi;
            
        } catch (Exception $e) {
            $this->logError('getWiFiStatus', $e->getMessage());
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }
    
    /**
     * Reboot device
     * @param string $device_id Device ID
     * @return array Result with task ID
     */
    public function rebootDevice($device_id) {
        return $this->sendTask($device_id, 'reboot');
    }
    
    /**
     * Factory reset device
     * @param string $device_id Device ID
     * @return array Result with task ID
     */
    public function factoryReset($device_id) {
        return $this->sendTask($device_id, 'factoryReset');
    }
    
    /**
     * Set WiFi settings
     * @param string $device_id Device ID
     * @param string $ssid WiFi SSID
     * @param string $password WiFi password
     * @param string $security Security mode (WPA2, WPA3, WPA, None)
     * @return array Result
     */
    public function setWiFiSettings($device_id, $ssid, $password, $security = 'WPA2') {
        try {
            $tasks = [];
            
            // Set SSID
            $tasks[] = $this->sendTask($device_id, 'setParameterValues', [
                'parameterValues' => [
                    ['InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.SSID', $ssid, 'xsd:string']
                ]
            ]);
            
            // Set password based on security type
            $password_param = 'InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.KeyPassphrase';
            if ($security == 'WPA3') {
                $password_param = 'InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.WPAPSKKey';
            }
            
            $tasks[] = $this->sendTask($device_id, 'setParameterValues', [
                'parameterValues' => [
                    [$password_param, $password, 'xsd:string']
                ]
            ]);
            
            // Set security mode
            $security_map = [
                'WPA2' => 'WPA2',
                'WPA3' => 'WPA3',
                'WPA' => 'WPA',
                'None' => 'None'
            ];
            
            $tasks[] = $this->sendTask($device_id, 'setParameterValues', [
                'parameterValues' => [
                    ['InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.BeaconType', $security_map[$security] ?? 'WPA2', 'xsd:string']
                ]
            ]);
            
            // Check if all tasks succeeded
            $all_success = true;
            foreach ($tasks as $task) {
                if (!$task['success']) {
                    $all_success = false;
                    break;
                }
            }
            
            return [
                'success' => $all_success,
                'message' => $all_success ? 'WiFi settings applied' : 'Some settings failed',
                'tasks' => $tasks
            ];
            
        } catch (Exception $e) {
            $this->logError('setWiFiSettings', $e->getMessage());
            return [
                'success' => false,
                'message' => $e->getMessage()
            ];
        }
    }
    
    /**
     * Set admin password
     * @param string $device_id Device ID
     * @param string $password New password
     * @param string $type Password type (admin or user)
     * @return array Result
     */
    public function setAdminPassword($device_id, $password, $type = 'admin') {
        try {
            $param = 'InternetGatewayDevice.DeviceInfo.X_AdminPassword';
            if ($type == 'user') {
                $param = 'InternetGatewayDevice.DeviceInfo.X_UserPassword';
            }
            
            return $this->sendTask($device_id, 'setParameterValues', [
                'parameterValues' => [
                    [$param, $password, 'xsd:string']
                ]
            ]);
            
        } catch (Exception $e) {
            $this->logError('setAdminPassword', $e->getMessage());
            return [
                'success' => false,
                'message' => $e->getMessage()
            ];
        }
    }
    
    /**
     * Summon device (force connection)
     * @param string $device_id Device ID
     * @return array Result
     */
    public function summonDevice($device_id) {
        try {
            // Use getParameterValues to force connection
            return $this->sendTask($device_id, 'getParameterValues', [
                'parameterNames' => ['InternetGatewayDevice.DeviceInfo.Summon']
            ]);
            
        } catch (Exception $e) {
            $this->logError('summonDevice', $e->getMessage());
            return [
                'success' => false,
                'message' => $e->getMessage()
            ];
        }
    }
    
    /**
     * Test WiFi connection
     * @param string $device_id Device ID
     * @return array Test result
     */
    public function testWiFi($device_id) {
        try {
            // Try to get WiFi status to test connectivity
            $wifi = $this->getWiFiStatus($device_id);
            
            if ($wifi['success'] && $wifi['ssid']) {
                return [
                    'success' => true,
                    'message' => 'WiFi configuration verified',
                    'ssid' => $wifi['ssid']
                ];
            } else {
                return [
                    'success' => false,
                    'message' => 'Unable to verify WiFi settings'
                ];
            }
            
        } catch (Exception $e) {
            $this->logError('testWiFi', $e->getMessage());
            return [
                'success' => false,
                'message' => $e->getMessage()
            ];
        }
    }
    
    /**
     * Check task status
     * @param string $device_id Device ID
     * @param string $task_id Task ID
     * @return array Task status
     */
    public function checkTaskStatus($device_id, $task_id) {
        try {
            $response = $this->makeRequest("/devices/$device_id/tasks/$task_id");
            
            if ($response && is_array($response)) {
                return [
                    'completed' => isset($response['status']) && $response['status'] != 'pending',
                    'success' => isset($response['status']) && $response['status'] == 'completed',
                    'status' => $response['status'] ?? 'unknown',
                    'fault' => $response['fault'] ?? null,
                    'data' => $response
                ];
            }
            
            return ['completed' => false];
            
        } catch (Exception $e) {
            $this->logError('checkTaskStatus', $e->getMessage());
            return ['completed' => false, 'error' => $e->getMessage()];
        }
    }
    
    /**
     * Send task to device
     * @param string $device_id Device ID
     * @param string $task_name Task name
     * @param array $parameters Task parameters
     * @return array Result with task ID
     */
    private function sendTask($device_id, $task_name, $parameters = []) {
        $attempts = 0;
        $last_error = null;
        
        while ($attempts < $this->max_retries) {
            try {
                $data = ['name' => $task_name];
                if (!empty($parameters)) {
                    $data = array_merge($data, $parameters);
                }
                
                $response = $this->makeRequest("/devices/$device_id/tasks?timeout=$this->timeout", 'POST', $data);
                
                if ($response && isset($response['_id'])) {
                    return [
                        'success' => true,
                        'task_id' => $response['_id'],
                        'task_name' => $task_name,
                        'message' => "$task_name task created"
                    ];
                } else {
                    throw new Exception('Invalid response from server');
                }
                
            } catch (Exception $e) {
                $last_error = $e;
                $attempts++;
                
                if ($attempts < $this->max_retries) {
                    // Wait before retry
                    sleep(1 * $attempts);
                }
            }
        }
        
        return [
            'success' => false,
            'message' => "Failed after $attempts attempts: " . ($last_error ? $last_error->getMessage() : 'Unknown error')
        ];
    }
    
    /**
     * Parse device data from API response
     * @param array $data Raw device data
     * @return array Parsed device data
     */
    private function parseDeviceData($data) {
        $parsed = [
            'id' => $data['_id'] ?? null,
            'serial' => null,
            'mac' => null,
            'model' => null,
            'manufacturer' => null,
            'software_version' => null,
            'hardware_version' => null,
            'online' => false,
            'last_contact' => null,
            'first_seen' => null,
            'uptime' => 0,
            'ip' => null,
            'connection_type' => null,
            'tags' => []
        ];
        
        // Extract from _deviceId if available
        if (isset($data['_deviceId'])) {
            $parsed['serial'] = $data['_deviceId']['_SerialNumber'] ?? null;
            $parsed['mac'] = $data['_deviceId']['_MACAddress'] ?? null;
            $parsed['model'] = $data['_deviceId']['_ProductClass'] ?? null;
            $parsed['manufacturer'] = $data['_deviceId']['_Manufacturer'] ?? null;
        }
        
        // Extract parameters if available
        if (isset($data['parameters']) && is_array($data['parameters'])) {
            $params = $data['parameters'];
            
            // Software/Hardware version
            if (isset($params['InternetGatewayDevice.DeviceInfo.SoftwareVersion'])) {
                $parsed['software_version'] = $params['InternetGatewayDevice.DeviceInfo.SoftwareVersion'];
            }
            if (isset($params['InternetGatewayDevice.DeviceInfo.HardwareVersion'])) {
                $parsed['hardware_version'] = $params['InternetGatewayDevice.DeviceInfo.HardwareVersion'];
            }
            if (isset($params['InternetGatewayDevice.DeviceInfo.Uptime'])) {
                $parsed['uptime'] = $params['InternetGatewayDevice.DeviceInfo.Uptime'];
            }
            if (isset($params['InternetGatewayDevice.WANDevice.1.WANConnectionDevice.1.WANIPConnection.1.ExternalIPAddress'])) {
                $parsed['ip'] = $params['InternetGatewayDevice.WANDevice.1.WANConnectionDevice.1.WANIPConnection.1.ExternalIPAddress'];
            }
        }
        
        // Parse timestamps
        if (isset($data['_lastContact'])) {
            $parsed['last_contact'] = $data['_lastContact'];
            $last_contact_time = strtotime($data['_lastContact']);
            $parsed['online'] = (time() - $last_contact_time) < 1800; // 30 minutes
        }
        
        if (isset($data['_firstSeen'])) {
            $parsed['first_seen'] = $data['_firstSeen'];
        }
        
        if (isset($data['_tags']) && is_array($data['_tags'])) {
            $parsed['tags'] = $data['_tags'];
        }
        
        return $parsed;
    }
    
    /**
     * Make HTTP request to GenieACS API with retry logic
     * @param string $endpoint API endpoint
     * @param string $method HTTP method
     * @param mixed $data Request data
     * @param bool $throw_on_error Whether to throw exception on HTTP errors
     * @return mixed Response data
     * @throws Exception on failure
     */
    private function makeRequest($endpoint, $method = 'GET', $data = null, $throw_on_error = true) {
        $url = $this->base_url . $endpoint;
        
        $ch = curl_init();
        
        $headers = [
            'Content-Type: application/json',
            'Accept: application/json',
            'User-Agent: GenieACS-PHPNuxBill-Plugin/1.0'
        ];
        
        $options = [
            CURLOPT_URL => $url,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT => $this->timeout,
            CURLOPT_CONNECTTIMEOUT => 10,
            CURLOPT_FOLLOWLOCATION => true,
            CURLOPT_MAXREDIRS => 3,
            CURLOPT_SSL_VERIFYPEER => $this->ssl_verify,
            CURLOPT_SSL_VERIFYHOST => $this->ssl_verify ? 2 : 0,
            CURLOPT_HTTPHEADER => $headers
        ];
        
        // Add authentication if provided
        if (!empty($this->server['username']) && !empty($this->server['password'])) {
            $password = $this->decryptPassword($this->server['password']);
            $options[CURLOPT_HTTPAUTH] = CURLAUTH_BASIC | CURLAUTH_DIGEST;
            $options[CURLOPT_USERPWD] = $this->server['username'] . ':' . $password;
        }
        
        // Set request method
        if ($method == 'POST') {
            $options[CURLOPT_POST] = true;
            if ($data) {
                $json_data = json_encode($data);
                $options[CURLOPT_POSTFIELDS] = $json_data;
                $headers[] = 'Content-Length: ' . strlen($json_data);
            }
        } elseif ($method == 'PUT') {
            $options[CURLOPT_CUSTOMREQUEST] = 'PUT';
            if ($data) {
                $options[CURLOPT_POSTFIELDS] = json_encode($data);
            }
        } elseif ($method == 'DELETE') {
            $options[CURLOPT_CUSTOMREQUEST] = 'DELETE';
        }
        
        $options[CURLOPT_HTTPHEADER] = $headers;
        curl_setopt_array($ch, $options);
        
        if ($this->debug) {
            $this->logDebug("Request: $method $url");
            if ($data) {
                $this->logDebug("Request Data: " . json_encode($data));
            }
        }
        
        $response = curl_exec($ch);
        $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $error = curl_error($ch);
        $errno = curl_errno($ch);
        
        curl_close($ch);
        
        if ($this->debug) {
            $this->logDebug("Response: HTTP $http_code");
            if ($response) {
                $this->logDebug("Response Data: " . substr($response, 0, 500));
            }
            if ($error) {
                $this->logDebug("CURL Error ($errno): $error");
            }
        }
        
        // Handle CURL errors
        if ($error) {
            if ($throw_on_error) {
                throw new Exception("CURL Error ($errno): $error");
            }
            return null;
        }
        
        // Handle HTTP errors
        if ($http_code >= 400) {
            if ($throw_on_error) {
                $error_message = "HTTP Error $http_code";
                if ($response) {
                    $error_data = json_decode($response, true);
                    if ($error_data && isset($error_data['message'])) {
                        $error_message .= ": " . $error_data['message'];
                    } else {
                        $error_message .= ": " . substr($response, 0, 200);
                    }
                }
                throw new Exception($error_message);
            }
            return null;
        }
        
        // Parse JSON response
        if ($response) {
            $decoded = json_decode($response, true);
            if ($decoded === null && json_last_error() !== JSON_ERROR_NONE) {
                if ($throw_on_error) {
                    throw new Exception("Invalid JSON response: " . json_last_error_msg());
                }
                return null;
            }
            return $decoded;
        }
        
        return null;
    }
    
    /**
     * Decrypt password
     * @param string $encrypted Encrypted password
     * @return string Decrypted password
     */
    private function decryptPassword($encrypted) {
        if (function_exists('decrypt')) {
            return decrypt($encrypted);
        }
        return $encrypted;
    }
    
    /**
     * Log error message
     * @param string $function Function name
     * @param string $message Error message
     */
    private function logError($function, $message) {
        if ($this->debug) {
            error_log("GenieACS API [$function] Error: $message");
        }
        
        // Also log to plugin logs if function exists
        if (function_exists('genieacs_log')) {
            genieacs_log('system', 'api_error', 'error', "$function: $message");
        }
    }
    
    /**
     * Log debug message
     * @param string $message Debug message
     */
    private function logDebug($message) {
        if ($this->debug) {
            error_log("GenieACS API Debug: $message");
        }
    }
    
    /**
     * Get API version
     * @return string API version
     */
    public function getApiVersion() {
        try {
            $response = $this->makeRequest('/version', 'GET', null, false);
            return $response['version'] ?? 'Unknown';
        } catch (Exception $e) {
            return 'Unknown';
        }
    }
    
    /**
     * Get server statistics
     * @return array Server stats
     */
    public function getServerStats() {
        try {
            $devices = $this->makeRequest('/devices/?limit=1', 'GET', null, false);
            $info = $this->makeRequest('/version', 'GET', null, false);
            
            return [
                'success' => true,
                'total_devices' => is_array($devices) ? '?' : 0,
                'version' => $info['version'] ?? 'Unknown',
                'uptime' => $info['uptime'] ?? 'Unknown'
            ];
        } catch (Exception $e) {
            return [
                'success' => false,
                'message' => $e->getMessage()
            ];
        }
    }
}
