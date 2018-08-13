C:\ProgramData\PuppetLabs\puppet\cache\state
C:\ProgramData\PuppetLabs\puppet\cache\state\agent_disabled.lock
[Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}; $webClient = New-Object System.Net.WebClient; $webClient.DownloadFile('https://ip-10-98-10-242.us-west-2.compute.internal:8140/packages/current/install.ps1', 'install.ps1'); .\install.ps1 extension_requests:pp_role=win_mysql
puppet agent -t --agent_disabled_lockfile /tmp/puppet_first_run.lock\
del /opt/puppetlabs/puppet/cache/state/agent_disabled.lock"
