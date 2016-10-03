. .\Convert-WindowsImage.ps1

$VMName = "APP01"
$VMDirectory = "F:\VMs"
$VHDSize = 128GB
$MemorySize = 2048MB
$ProcessorCount = 4

$ConvertWindowsImageParam = @{  
    SourcePath          = "C:\ISO\14393.0.160715-1616.RS1_RELEASE_SERVER_EVAL_X64FRE_EN-US.ISO"  
    RemoteDesktopEnable = $True  
    Passthru            = $True  
    Edition    = @(  
        "ServerDatacenterEval"  
    )
    SizeBytes = $VHDSize
    VHDPath = "$VMDirectory\$VMName\Virtual Hard Disks\$VMName.vhdx"
} 

mkdir "$VMDirectory\$VMName\Virtual Hard Disks\"
Convert-WindowsImage @ConvertWindowsImageParam
$VM = New-VM -Name $VMName -Path $VMDirectory -Generation 2 -VHDPath "$VMDirectory\$VMName\Virtual Hard Disks\$VMName.vhdx" -MemoryStartupBytes $MemorySize
$VM | Set-VMProcessor -Count $ProcessorCount -ExposeVirtualizationExtensions $True
$VM | Get-VMNetworkAdapter | Connect-VMNetworkAdapter -SwitchName External