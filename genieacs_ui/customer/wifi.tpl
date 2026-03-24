{include file="sections/header.tpl"}

<div class="row">
    <div class="col-md-8 col-md-offset-2">
        <div class="box box-primary">
            <div class="box-header with-border">
                <h3 class="box-title">Change WiFi Settings</h3>
                <div class="box-tools pull-right">
                    <a href="{$_url}plugin/genieacs_my_modem" class="btn btn-box-tool">
                        <i class="fa fa-arrow-left"></i> Back to Modem
                    </a>
                </div>
            </div>
            <div class="box-body">
                
                <div class="alert alert-info">
                    <i class="fa fa-info-circle"></i> 
                    Changing WiFi settings will temporarily disconnect all devices connected to your WiFi network.
                </div>
                
                <form id="wifiForm" onsubmit="saveWifiSettings(event)">
                    
                    <div class="form-group">
                        <label for="ssid">WiFi Name (SSID) <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="ssid" name="ssid" 
                               value="{$device.wifi_ssid|default:''}" 
                               placeholder="Enter WiFi name" required maxlength="32">
                        <p class="help-block">Between 1-32 characters. This is the name you see when searching for WiFi.</p>
                    </div>
                    
                    <div class="form-group">
                        <label for="password">WiFi Password <span class="text-danger">*</span></label>
                        <div class="input-group">
                            <input type="password" class="form-control" id="password" name="password" 
                                   value="{$device.wifi_password_plain|default:''}" 
                                   placeholder="Enter WiFi password" required minlength="8" maxlength="63">
                            <span class="input-group-btn">
                                <button class="btn btn-default" type="button" onclick="togglePassword()">
                                    <i class="fa fa-eye"></i>
                                </button>
                                <button class="btn btn-default" type="button" onclick="generatePassword()">
                                    <i class="fa fa-random"></i> Generate
                                </button>
                            </span>
                        </div>
                        <p class="help-block">Minimum 8 characters, maximum 63 characters. Use a mix of letters, numbers, and symbols for better security.</p>
                    </div>
                    
                    <div class="form-group">
                        <label>Password Strength</label>
                        <div class="progress" style="height: 20px;">
                            <div id="passwordStrength" class="progress-bar progress-bar-danger" style="width: 0%; height: 20px;">
                                <span id="strengthText">Too Weak</span>
                            </div>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="security">Security Mode</label>
                        <select class="form-control" id="security" name="security">
                            <option value="WPA2" {if $device.wifi_security|default:'WPA2' == 'WPA2'}selected{/if}>WPA2-PSK (Recommended)</option>
                            <option value="WPA3" {if $device.wifi_security|default:'' == 'WPA3'}selected{/if}>WPA3-SAE (More Secure)</option>
                            <option value="WPA" {if $device.wifi_security|default:'' == 'WPA'}selected{/if}>WPA-PSK</option>
                            <option value="None" {if $device.wifi_security|default:'' == 'None'}selected{/if}>Open Network (No Security - Not Recommended)</option>
                        </select>
                        <p class="help-block">WPA2 is compatible with most devices. WPA3 is more secure but may not work with older devices.</p>
                    </div>
                    
                    <div class="form-group">
                        <label>Hide SSID (Network Name)</label>
                        <div class="checkbox">
                            <label>
                                <input type="checkbox" id="hideSsid" name="hide_ssid" value="1" 
                                       {if $device.hide_ssid|default:0 == 1}checked{/if}>
                                Hide my WiFi network (network name won't be broadcasted)
                            </label>
                        </div>
                        <p class="help-block text-warning">If hidden, you'll need to manually enter the network name on your devices.</p>
                    </div>
                    
                    <div class="form-group">
                        <label>Guest Network</label>
                        <div class="checkbox">
                            <label>
                                <input type="checkbox" id="guestNetwork" name="guest_network" value="1"
                                       {if $device.guest_network|default:0 == 1}checked{/if}>
                                Enable guest WiFi network (separate from main network)
                            </label>
                        </div>
                    </div>
                    
                    <div id="guestSettings" style="display: none; margin-top: 15px; padding: 15px; background: #f9f9f9; border-radius: 4px;">
                        <h4>Guest Network Settings</h4>
                        
                        <div class="form-group">
                            <label>Guest SSID</label>
                            <input type="text" class="form-control" id="guest_ssid" name="guest_ssid" 
                                   value="{$device.guest_ssid|default:''}" placeholder="e.g., MyHome-Guest">
                        </div>
                        
                        <div class="form-group">
                            <label>Guest Password</label>
                            <div class="input-group">
                                <input type="password" class="form-control" id="guest_password" name="guest_password" 
                                       value="{$device.guest_password|default:''}">
                                <span class="input-group-btn">
                                    <button class="btn btn-default" type="button" onclick="toggleGuestPassword()">
                                        <i class="fa fa-eye"></i>
                                    </button>
                                </span>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label>Guest Network Bandwidth Limit</label>
                            <select class="form-control" id="guest_bandwidth" name="guest_bandwidth">
                                <option value="0">No Limit</option>
                                <option value="1024">1 Mbps</option>
                                <option value="2048">2 Mbps</option>
                                <option value="5120">5 Mbps</option>
                                <option value="10240">10 Mbps</option>
                            </select>
                        </div>
                    </div>
                    
                    <hr>
                    
                    <div class="form-group">
                        <div class="checkbox">
                            <label>
                                <input type="checkbox" id="confirmChanges" required>
                                <strong class="text-danger">I understand that changing WiFi settings will disconnect all devices immediately and I may need to reconnect them with the new password.</strong>
                            </label>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <div id="countdownMessage" style="display: none;" class="alert alert-warning">
                            <i class="fa fa-clock-o"></i> Please wait <span id="countdown">10</span> seconds before saving...
                        </div>
                    </div>
                    
                    <div class="form-group text-center">
                        <button type="submit" class="btn btn-primary btn-lg" id="saveBtn" disabled>
                            <i class="fa fa-save"></i> Save WiFi Settings
                        </button>
                        <a href="{$_url}plugin/genieacs_my_modem" class="btn btn-default btn-lg">
                            <i class="fa fa-times"></i> Cancel
                        </a>
                    </div>
                    
                </form>
                
                <hr>
                
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <h3 class="panel-title"><i class="fa fa-shield"></i> Security Tips</h3>
                    </div>
                    <div class="panel-body">
                        <ul>
                            <li><strong>Use a strong password:</strong> Mix of uppercase, lowercase, numbers, and symbols</li>
                            <li><strong>Avoid common words:</strong> Don't use your name, address, or phone number</li>
                            <li><strong>Change default passwords:</strong> Always change the default WiFi password</li>
                            <li><strong>Use WPA2 or WPA3:</strong> These are the most secure encryption methods</li>
                            <li><strong>Regular updates:</strong> Change your WiFi password every few months</li>
                        </ul>
                    </div>
                </div>
                
                <div class="panel panel-info">
                    <div class="panel-heading">
                        <h3 class="panel-title"><i class="fa fa-history"></i> Recent WiFi Changes</h3>
                    </div>
                    <div class="panel-body">
                        <table class="table table-striped">
                            <thead>
                                <tr>
                                    <th>Date</th>
                                    <th>SSID</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody id="wifiHistory">
                                <tr><td colspan="3" class="text-center">Loading...</td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>
                
            </div>
        </div>
    </div>
</div>

<script>
var countdownInterval;
var countdownTime = 10;

$(document).ready(function() {
    loadWifiHistory();
    
    $('#password').on('keyup', checkPasswordStrength);
    
    $('#guestNetwork').change(function() {
        if($(this).is(':checked')) {
            $('#guestSettings').slideDown();
        } else {
            $('#guestSettings').slideUp();
        }
    });
    
    $('#confirmChanges').change(function() {
        if($(this).is(':checked')) {
            startCountdown();
        } else {
            stopCountdown();
        }
    });
    
    // Initial strength check
    checkPasswordStrength();
});

function checkPasswordStrength() {
    var password = $('#password').val();
    var strength = 0;
    var strengthBar = $('#passwordStrength');
    var strengthText = $('#strengthText');
    
    if(password.length >= 8) strength += 25;
    if(password.length >= 12) strength += 15;
    if(password.match(/[a-z]+/)) strength += 15;
    if(password.match(/[A-Z]+/)) strength += 15;
    if(password.match(/[0-9]+/)) strength += 15;
    if(password.match(/[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]+/)) strength += 15;
    
    // Cap at 100
    strength = Math.min(strength, 100);
    
    strengthBar.css('width', strength + '%');
    
    if(strength < 30) {
        strengthBar.removeClass('progress-bar-warning progress-bar-success').addClass('progress-bar-danger');
        strengthText.text('Too Weak');
    } else if(strength < 60) {
        strengthBar.removeClass('progress-bar-danger progress-bar-success').addClass('progress-bar-warning');
        strengthText.text('Medium');
    } else if(strength < 80) {
        strengthBar.removeClass('progress-bar-danger progress-bar-warning').addClass('progress-bar-success');
        strengthText.text('Strong');
    } else {
        strengthBar.removeClass('progress-bar-danger progress-bar-warning').addClass('progress-bar-success');
        strengthText.text('Very Strong');
    }
}

function togglePassword() {
    var input = $('#password');
    if(input.attr('type') == 'password') {
        input.attr('type', 'text');
    } else {
        input.attr('type', 'password');
    }
}

function toggleGuestPassword() {
    var input = $('#guest_password');
    if(input.attr('type') == 'password') {
        input.attr('type', 'text');
    } else {
        input.attr('type', 'password');
    }
}

function generatePassword() {
    var length = 12;
    var charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*";
    var password = "";
    
    for(var i = 0; i < length; i++) {
        password += charset.charAt(Math.floor(Math.random() * charset.length));
    }
    
    $('#password').val(password);
    checkPasswordStrength();
}

function startCountdown() {
    countdownTime = 10;
    $('#countdownMessage').show();
    $('#saveBtn').prop('disabled', true);
    
    countdownInterval = setInterval(function() {
        countdownTime--;
        $('#countdown').text(countdownTime);
        
        if(countdownTime <= 0) {
            clearInterval(countdownInterval);
            $('#countdownMessage').hide();
            $('#saveBtn').prop('disabled', false);
        }
    }, 1000);
}

function stopCountdown() {
    clearInterval(countdownInterval);
    $('#countdownMessage').hide();
    $('#saveBtn').prop('disabled', true);
}

function saveWifiSettings(event) {
    event.preventDefault();
    
    var ssid = $('#ssid').val();
    var password = $('#password').val();
    var security = $('#security').val();
    var hideSsid = $('#hideSsid').is(':checked') ? 1 : 0;
    var guestNetwork = $('#guestNetwork').is(':checked') ? 1 : 0;
    
    var guestSsid = $('#guest_ssid').val();
    var guestPassword = $('#guest_password').val();
    var guestBandwidth = $('#guest_bandwidth').val();
    
    if(!ssid || !password) {
        toastr.error('Please fill all required fields');
        return;
    }
    
    if(password.length < 8) {
        toastr.error('Password must be at least 8 characters');
        return;
    }
    
    if(ssid.length > 32) {
        toastr.error('SSID cannot exceed 32 characters');
        return;
    }
    
    $('#saveBtn').prop('disabled', true).html('<i class="fa fa-spinner fa-spin"></i> Saving...');
    
    $.post('{$_url}plugin/genieacs_customer_wifi_save', {
        ssid: ssid,
        password: password,
        security: security,
        hide_ssid: hideSsid,
        guest_network: guestNetwork,
        guest_ssid: guestSsid,
        guest_password: guestPassword,
        guest_bandwidth: guestBandwidth
    }, function(data) {
        if(data.success) {
            toastr.success('WiFi settings updated successfully!');
            toastr.info('Your device will disconnect in a moment. Reconnect with the new settings.');
            
            setTimeout(function() {
                window.location.href = '{$_url}plugin/genieacs_my_modem';
            }, 3000);
        } else {
            toastr.error(data.message || 'Failed to update WiFi settings');
            $('#saveBtn').prop('disabled', false).html('<i class="fa fa-save"></i> Save WiFi Settings');
            $('#confirmChanges').prop('checked', false);
        }
    }, 'json');
}

function loadWifiHistory() {
    $.get('{$_url}plugin/genieacs_wifi_history', function(data) {
        var html = '';
        if(data && data.length > 0) {
            $.each(data, function(i, item) {
                var statusClass = item.success ? 'label-success' : 'label-danger';
                html += '<tr>';
                html += '<td>' + new Date(item.date).toLocaleString() + '</td>';
                html += '<td>' + (item.ssid || 'N/A') + '</td>';
                html += '<td><span class="label ' + statusClass + '">' + (item.success ? 'Success' : 'Failed') + '</span></td>';
                html += '</tr>';
            });
        } else {
            html = '<tr><td colspan="3" class="text-center">No recent changes</td></tr>';
        }
        $('#wifiHistory').html(html);
    }, 'json');
}

// Preview current password strength on load
checkPasswordStrength();
</script>

<style>
.progress {
    margin-bottom: 5px;
}
#passwordStrength {
    transition: width 0.3s ease;
    line-height: 20px;
    color: white;
    text-align: center;
    font-size: 12px;
}
.input-group-btn .btn {
    height: 34px;
}
</style>

{include file="sections/footer.tpl"}
