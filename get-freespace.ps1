<#
.SYNOPSIS
Get-Freespace lists freespace for drives under a specified threshold.
.DESCRIPTION
Get-Freespace uses WMI to query freespace on a drive and lists drives that are under a specified threshold. 
.PARAMETER computername
The computer name, or names, to query. Default: Localhost.
.PARAMETER threshold
The threshold you want to list under. Default .1 (10%)
.EXAMPLE
Get-freespace -computername SERVER-R2 -threshold .5
#>
[Cmdletbinding()]
param ( 
        [parameter(mandatory=$true,helpmessage="Type the computername to query")]
        [string]$computername,

        $threshold='.1'
)
Write-Verbose "Connecting to $computername"
Write-Verbose "Querying freespace"

Get-WmiObject Win32_LogicalDisk -ComputerName "$computername" -Filter "drivetype=3" |
Where {$_.Freespace / $_.Size -lt "$threshold" } |
Select -Property DeviceID,
@{name='Freespace(MB)';expression={$_.freespace / 1MB -as [int]}},
@{name='% Free';expression={$_.freespace * 100/$_.Size -as [int]}},
@{name='Size(GB)';expression={$_.Size / 1GB -as [int]}} 
