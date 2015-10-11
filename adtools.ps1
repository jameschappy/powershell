#get ad info

Get-addomain | select Forest,Netbiosname,DomainMode,PDCEmulator,RIDMaster,Infratructuremaster

Get-AdForest | select Name,Forestmode,Globalcatalogs,*Master

# get all domain controllers

$domain = get-addomain

$DCs = get-addomaincontroller -filter { domain -eq #domain.dnsroot } 

$DCs | select name,operatingsystem,ipv4address

# verify services

$services = "netlogon","NTDS","KDC","ADWS"."NTFRS"

get-service $services -ComputerName $DCs.name | 
sort machinename,name |
select | name,displayname,status,machinename |
Out-GridView -title "Ad Service Status"

#check logs

$lognames = 'Active Directory Web Services','Directory Service','File Replication Service','System'

# get recent errors and warnings from these logs on all DC's

$mylogs = foreach ($log in $lognames) {
    Write-Host $log -ForegroundColor Yellow
    #add eventlog name to output object
    Get-EventLog $log  -ComputerName $DCs.name -Newest 10 -EntryType Error,Warning |
    Add-Member -MemberType NoteProperty -Name Logname -Value $log -PassThru
    }

# view filter and analyse

$mylogs | sort logname,machinename,timegenerated |
select logname,machinename,timegenerated,eventid,entrytype,source,category,message |
Out-GridView -Title "AD Log info"

