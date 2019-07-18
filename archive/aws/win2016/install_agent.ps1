<script>
winrm quickconfig -q 
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
netsh advfirewall firewall add rule name="WinRM in" protocol=TCP dir=in profile=any localport=5985 remoteip=any localip=any action=allow
</script>
<powershell>
[Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}; $webClient = New-Object System.Net.WebClient; $webClient.DownloadFile('https://ip-10-98-10-11.us-west-2.compute.internal:8140/packages/current/install.ps1', 'install.ps1'); .\install.ps1 extension_requests:pp_role=win_mysql
puppet agent -t
</powershell>
