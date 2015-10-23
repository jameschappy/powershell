
<#
.Synopsis
    Get-ShareAudit will pull size information, NTFS permissions, and Share permissions for all non-system and non-printer shares on the local computer or a remote server.
    With no parameters, it will pull information from the local computer.
 
.EXAMPLE
    Get-ShareAudit -Computer server1, server2
 
.EXAMPLE
    Get-ShareAudit
#>
 
 
 
   
    Param (
           
            [Parameter(Position=0)][String[]]$Computer = "localhost",
 
            [Parameter()][String]$AuditReport = "C:\ShareReport-Audit.csv",
            [Parameter()][String]$NTFSReport = "C:\ShareReport-NTFSPermissions.csv",
            [Parameter()][String]$ShareReport = "C:\ShareReport-Permissions.csv",
            [Parameter()][String]$ErrorFile = "C:\ShareReport-Errors.txt"
           
            <#[Parameter()][String]$ResultsFolder = "C:\ShareReportResults\"
            Not used right now. Will use in the future to copy all results from all servers to local PC.#>
 
           )
 
    function SubFunction($AuditReport,$NTFSReport,$ShareReport,$ErrorFile){
   
    $Hostname = $env:COMPUTERNAME
 
    $NTFSResults = @()
 
    $ShareResults = @()
 
    $SizeResults = @()
 
    $i = 0

    $ntfsreport = "C:\ShareReport-NTFSPermissions.csv"
 
    # Gets and exports NTFS Permissions
 
        $Shares = Get-WMIObject -Class win32_share  | where {$_.path -ne "$null"} # The where clause filters out system shares and shared printers
 
        If($Shares -eq $null)
        {
            Write-Error "No non-system/non-printer shares found on computer $Hostname."
            Break
        }
 
        $StartTime = Get-Date -format g
        Write-Host "Starting share audit process on computer $Hostname at $StartTime." -ForegroundColor Yellow
 
        ForEach($Share in $Shares)
        {
 
            $i++
            Write-Progress -Activity "Recording NTFS Permissions..." -Status "Recording Share $i of $($Shares.count) " -PercentComplete (($i / $Shares.count) * 100)
 
            $ACLs = (Get-ACL $Share.path).Access
            ForEach($ACL in $ACLs)
            {
 
                $NTFSProperties = @{'Name' = $Share.Name
                                'Path' = $Share.Path
                                'Identity' = $ACL.IdentityReference
                                'Type' = $ACL.AccessControlType
                                'Rights' = $ACL.FileSystemRights
                                }
                $NTFSObj = New-Object -TypeName PSObject -Property $NTFSProperties
                 $NTFSResults += $NTFSObj
            }
 
        }

        $NTFSReportFile = Test-Path $NTFSReport
 
        If($NTFSReportFile -eq "$true")
        {
            Remove-Item $NTFSReport -Force
        }
 
        $NTFSResults | Select Name, Path, Identity, Type, Rights | Export-CSV $NTFSReport -NoClobber -NoTypeInformation -Force
   
    $i = 0
 
    # Gets share name, path, and folder sizes
 
        ForEach($Share in $Shares)
        {
 
            $i++
            Write-Progress -Activity "Recording Share Sizes..." -Status "Recording Share $i of $($Shares.count) " -PercentComplete (($i / $Shares.count) * 100)
                                 
            $Folder = $Share.Path
            $Size = Get-ChildItem $Folder -recurse -force -ErrorVariable +Errors -ErrorAction SilentlyContinue | Measure-Object -property length -sum
 
            $FolderSize = "{0:N2}" -f ($Size.sum / 1GB)
 
            $SizeProperties = @{'Name' = $Share.Name
                                'Path' = $Share.Path
                                'SizeInGB' = $FolderSize
                                }
            $SizeObj = New-Object -TypeName PSObject -Property $SizeProperties
            $SizeResults += $SizeObj
           
        }
 
        $AuditReportFile = Test-Path $AuditReport
 
        If($AuditReportFile -eq "$true")
        {
            Remove-Item $AuditReport
        }
 
        $SizeResults | Select Name, Path, SizeInGB | Export-CSV $AuditReport -NoClobber -NoTypeInformation -Force
 
        $ErrorFileTest = Test-Path $ErrorFile
 
        If($ErrorFileTest -eq "$true")
        {
            Remove-Item $ErrorFile
        }
 
        $Errors | Out-File -FilePath $ErrorFile -Append
 
    $i = 0
 
    # Gets and exports Share Permissions
    # Code borrowed and modified from: https://gallery.technet.microsoft.com/scriptcenter/Lists-all-the-shared-5ebb395a
     
        $SharedFolderSecs = Get-WmiObject -Class Win32_LogicalShareSecuritySetting
 
        foreach ($SharedFolderSec in $SharedFolderSecs)
                {                      
 
                $i++
                Write-Progress -Activity "Recording Share Permissions..." -Status "Recording Share $i of $($SharedFolderSecs.count) " -PercentComplete (($i / $SharedFolderSecs.count) * 100)
 
                $Objs = @() #define the empty array
                       
                    $SecDescriptor = $SharedFolderSec.GetSecurityDescriptor()
                    foreach($DACL in $SecDescriptor.Descriptor.DACL)
                            {  
                                    $DACLDomain = $DACL.Trustee.Domain
                                    $DACLName = $DACL.Trustee.Name
                                    if($DACLDomain -ne $null)
                                    {
                                    $UserName = "$DACLDomain\$DACLName"
                                    }
                                    else
                                    {
                                            $UserName = "$DACLName"
                                    }
                               
                                    #customize the property
                                    $ShareProperties = @{'Name' = $SharedFolderSec.Name
                                                                         'Identity' = $UserName
                                         'Type' = [Security.AccessControl.AceType]$DACL.AceType
                                                                         'Rights' = [Security.AccessControl.FileSystemRights] $($DACL.AccessMask -as [Security.AccessControl.FileSystemRights])}
                                    $SharedACLs = New-Object -TypeName PSObject -Property $ShareProperties
                                    $ShareResults += $SharedACLs
 
                    }
        }
 
        $ShareReportFile = Test-Path $ShareReport
 
        If($ShareReportFile -eq "$true")
        {
            Remove-Item $ShareReport
        }
 
        $ShareResults | Select-Object Name, Identity, Type, Rights | Export-CSV $ShareReport -NoClobber -NoTypeInformation -Force
 
        $EndTime = Get-Date -format g
        Write-Host "Share audit process successfully completed on computer $Hostname at $EndTime." -ForegroundColor Green
        Write-Host "Your output files are as follows:" -ForegroundColor Yellow
        Write-Host "Share Audit Report: $AuditReport" -ForegroundColor Green
        Write-Host "NTFS Permissions: $NTFSReport" -ForegroundColor Green
        Write-Host "Share Permissions: $ShareReport" -ForegroundColor Green
        Write-Host "Error log: $ErrorFile" -ForegroundColor Green
        }
 
    If($Computer -eq "localhost")
    {
        SubFunction
    }
    Else
    {
        $Credential = Get-Credential
        ForEach($Comp in $Computer)
        {
            $TestComp = Test-Connection -ComputerName $Comp -Count 1 -Quiet
            If($TestComp -eq "$true")
            {
                Invoke-Command -ComputerName $Comp -Credential $Credential -ScriptBlock ${function:SubFunction} -ArgumentList $AuditReport,$NTFSReport,$ShareReport,$ErrorFile
            }
            Else
            {
                Write-Error "Computer $Comp is offline."
            }
        }
 
    }
 
