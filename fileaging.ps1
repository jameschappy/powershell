# requires -version 3.0

# demo file aging report

Get-WmiObject win32_share -Filter "type=0"

$path = "C:\Users\James Chapman\Documents\share"

$days =  
gci $path -Recurse | 
select FullName,CreationTime,LastWriteTime,
@{n="Age";e={(get-date) - $_.lastwritetime}}
@{n="Days";e={[int]((Get-Date) - $_.lastwritetime).totaldays}} |
where {$_.days -ge 365} | 
Sort-Object days -Descending

