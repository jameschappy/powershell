# creating fileshare using remote session

$FS = "corpserv.corp.local"

#create remoting session

$remote = New-PSSession -ComputerName $FS

$newpath = "C:\shares\newshare"

Invoke-command {mkdir $using:newpath} -session $remote

#using newpath ensure the remote session uses the local newpath variable (doesn't attempt to use $newpath on the remote machine)






# modifying permissions on a share (specifically removing the everyone permission

$path = 'C:\Users\James Chapman\Documents\Share'

#get the acl

$acl = get-acl -path $path

#get specific access rights

$access = $acl.Access 

#specify the user you're interested in (create as ntaccount object)

[System.Security.Principal.NTAccount] $principal="Builtin\Users"

# grab the specific rule you want for 'builtin users'

$rule = $access | where {$_.identityreference -eq $principal}

#use all this to delete the rule

$rule | foreach { $acl.RemoveAccessRuleSpecific($_) }

# set the new ACL

set-acl -path $path -AclObject $acl

#check the outcome

(get-acl $path).access 

#you will see that everyone has gone




# give Everyone Modify rights

$acl = get-acl -path $path

[System.Security.Principal.NTAccount] $principal="Builtin\Users"

$right = "Modify"
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule($Principal,$Right,"Allow")
$rule
$acl.SetAccessRule($rule)
Set-Acl -path $path -AclObject $acl


