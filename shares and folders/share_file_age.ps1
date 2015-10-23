# mega remote share file age report

#region aging buckets

$buckets = {
#get some other properties in case we want to further break down each bucket

$files = dir $using:sharepath -recurse |
select fullname,creationtime,lastwritetime,length,
@{n="Age";e={(get-date) - $_.lastwritetime}},
@{n="Days";e={[int]((get-date) - $_.lastwritetime).totaldays}} 

$hash= @{
Path = $using:sharepath
'Over' = ($files | where {$_.days -gt 365} | Measure-Object).count
'365Days' = ($files | where {$_.days -gt 180 -AND $_.days -le 365} | Measure-Object).count
'180Days' = ($files | where {$_.days -gt 90 -AND $_.days -le 180} | Measure-Object).count
'90Days' = ($files | where {$_.days -gt 30 -AND $_.days -le 90} | Measure-Object).count
'30Days' = ($files | where {$_.days -gt 7 -AND $_.days -le 30} | Measure-Object).count
'7Days' = ($files | where {$_.days -gt 0 -AND $_.days -le 7} | Measure-Object).count
Total = ($files | Measure-Object).Count
}
New-Object -TypeName PSObject -property $hash | 
select Path,Total,Over,365Days,180Days,90Days,30Days,7Days

}

# get all the shares

$shares = Get-WmiObject win32_share -ComputerName "JAMES-WIN10" -filter "type=0"

# create a session

$fp = New-PSSession -ComputerName "JAMES-WIN10"

# create an empty array

$data = @()

foreach ($share in $shares) {


Write-Host "Analysing $($share.name) [$sharepath]" -ForegroundColor Green 
$sharepath = $share.path 

$data += Invoke-Command -ScriptBlock $buckets -Session $fp

}





