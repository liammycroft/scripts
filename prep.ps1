### Setup system for Dev

# 1.0 Download Standalone Installers

iwr -Uri "https://github.com/microsoft/winget-cli/releases/download/v1.0.11692/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -OutFile .\Downloads\winget.msixbundle
iwr -Uri "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi" -OutFile .\Downloads\wsl_upd
# 1.1 Install Winget

.\Downloads\winget.msixbundle # GUI Installer complete by user
winget install -e --id Microsoft.WindowsTerminal
winget install -e --id Docker.DockerDesktop
winget install -e --id Microsoft.webpicmd
winget install -e --id Microsoft.VisualStudio.2019.Community
winget install -e --id Microsoft.VisualStudioCode
winget install -e --id Microsoft.SQLServerManagementStudio

webpicmd /install /products:IISManagementConsole,IIS-WindowsAuthentication,ASPNET45,AppWarmUp,UrlRewrite2

$vspath = . 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe' -property installationPath
. 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe' modify --add Microsoft.VisualStudio.Workload.NetWeb --add Microsoft.Net.Component.4.TargetingPack --add Microsoft.Net.Component.4.7.TargetingPack --installPath "$vspath"

## Restart ##

# 2.1 WSL2 Update

.\Downloads\wsl_update.msi
wsl --set-default-version 2
winget install -e --id Canonical.Ubuntu

# 2.2 Init SQL DB and ES

docker run -d --restart unless-stopped --name mssql -p 1433:1433 -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=####.####.####' mcr.microsoft.com/mssql/server
docker run -d --restart unless-stopped --name es732 -p 9200:9200 -e "discovery.type=single-node" docker.elastic.co/elasticsearch/elasticsearch-oss:7.3.2

# 2.3 Self Signed Cert for IIS (Powershell as Admin)

Import-Module IISAdministration;
$hostname = hostname;
$cert = New-SelfSignedCertificate -DnsName $hostname -CertStoreLocation cert:\LocalMachine\My -FriendlyName $hostname;
$certHash = $cert.GetCertHash();
$sm = Get-IISServerManager;
$sm.Sites["Default Web Site"].Bindings.Add("*:443:", $certHash, "My", "0");
$sm.CommitChanges();

$trustedStore = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Store -ArgumentList 'Root','LocalMachine';
$trustedStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite);
$trustedStore.Add($cert);
$trustedStore.Close();
