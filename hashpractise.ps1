# creating or manipulating hash tables.. 

$table = @{name='James';location='New Zealand';computer=$env:COMPUTERNAME}

$table.keys # lists keys
$table.location # gives value of location key

$empty = @{} # empty hash table

$empty.add("Name","James") # adds key/value to empty table
$empty.add("Office","Wellington")

$empty.Office = "Auckland" # Change office value to Auckland

$empty.ContainsKey("Name") #returns true or false if key exists

$empty.remove("Name") # removes name

<#

Following outputs a command to a hash table

#>

$source = Get-EventLog System -Newest 10 | Group-Object source -AsHashTable

$source.EventLog # shows eventlog events out of hash table

<#

Get enumerator is useful 

#>

$source.GetEnumerator() | Sort-Object name | Select-Object -First 2

# that wouldn't work without getenumerator

<# 

hash tables as object properties
    
#>

$os = Get-CimInstance win32_operatingsystem
$cs = Get-CimInstance win32_computersystem

$properties = [ordered] @{
    Computername=$os.csname
    MemoryMB = $cs.TotalPhysicalMemory /1mb -as [int]
    Lastboot = $os.LastBootUpTime
    Uptime = $os.LocalDateTime - $os.LastBootUpTime
    }

# you can then create a custome object.. the long way

New-Object -TypeName computerinfo -Property $properties

# or use the type accelerator

[pscustomobject]$properties

<#

Here is a big useful example
Grabbing a load of WMI data from remote computers and converting thge results into objects. They can then be further manipulated.

#>

$computers = "localhost","corpserv","core1","core2"
$data = ForEach ($computer in $computers) {
    $os = Get-CimInstance win32_operatingsystem -ComputerName $computer
    $cs = Get-CimInstance win32_computersystem -ComputerName $computer
    $cdrive = Get-CimInstance win32_logicaldisk -filter "deviceid='c:'" -ComputerName $computer 
    [PSCustomObject][Ordered]@{
    Computername = $os.CSName
    Operatingsystem = $os.Caption
    Arch = $os.OSArchitecture
    MemoryMB = $cs.TotalPhysicalMemory /1mb -as [int]
    Lastboot = $os.LastBootUpTime
    Uptime = (get-date) - $os.LastBootUpTime
    }
}







