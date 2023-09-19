# Script to upload files to someones OneDrive.
# Created on 19-09-2023

### FUNCTION MODULE CHECK ###
function Load-Module ($m) {

    # If module is imported say that and do nothing
    if (Get-Module | Where-Object {$_.Name -eq $m}) {
        write-host "Module $m is already imported."
    }
    else {

        # If module is not imported, but available on disk then import
        if (Get-Module -ListAvailable | Where-Object {$_.Name -eq $m}) {
            Import-Module $m -Verbose
        }
        else {

            # If module is not imported, not available on disk, but is in online gallery then install and import
            if (Find-Module -Name $m | Where-Object {$_.Name -eq $m}) {
                Install-Module -Name $m -Force -Verbose -Scope CurrentUser
                Import-Module $m -Verbose
            }
            else {

                # If the module is not imported, not available and not in the online gallery then abort
                write-host "Module $m not imported, not available and not in an online gallery, exiting."
                EXIT 1
            }
        }
    }
}
### END FUNCTION MODULE CHECK ###

### CHECK POWERSHELL MODULE ###

Load-Module "Microsoft.Graph.Files"
Load-Module "Microsoft.Graph.Authentication"

### END CHECK POWERSHELL MODULE ###

# Variables
$CertificateThumbprint = THUMBPRINT
$ClientID = CLIENTID
$TenantID = TENANTID
$Files = Get-ChildItem "C:\temp"
$Username = "User@contoso.onmicrosoft.com"
$UploadLocattion = "FunFolder/AnotherFunFolder/"
$APIEndpointBase = "https://graph.microsoft.com/v1.0/users/$Username/drive/root:/$UploadLocattion"

# Connect to Application inside Azure Tenant
Connect-MgGraph -TenantId $TenantID -ClientId $ClientID -CertificateThumbprint $CertificateThumbprint

# Upload Files to a persons OneDrive
foreach ($File in $Files) {
    $FilePath = $File.fullname
    $FileName = $File.Name
    $FileData = Get-Content -Path $FilePath -Raw
    $APIEndpoint = "${apiEndpointBase}${FileName}:/content"
    Invoke-MgGraphRequest -Method PUT -Uri $apiEndpoint -Body $FileData
}