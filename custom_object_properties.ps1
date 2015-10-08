<# example to create 'DEFAULT PROPERTY DISPLAY' for custom object

This sets which property's are listed by default.

Usually custom objects display all properties which is a bit messy/annoying

#>

# create an object

$object = [pscustomobject]@{
    Firstname = 'James'
    Lastname = 'Chapman'
    City = 'Wellington'
    Country = 'NZ'
    Phone = '0211661547'
}

# you then have to set a custom typename (in this instance user.information)

$object.psobject.TypeNames.Insert(0,'User.Information')

<#

You end up with:

   TypeName: User.Information

Name        MemberType   Definition                    
----        ----------   ----------                    
Equals      Method       bool Equals(System.Object obj)
GetHashCode Method       int GetHashCode()             
GetType     Method       type GetType()                
ToString    Method       string ToString()             
City        NoteProperty string City=Wellington        
Country     NoteProperty string Country=NZ             
Firstname   NoteProperty string Firstname=James        
Lastname    NoteProperty string Lastname=Chapman       
Phone       NoteProperty string Phone=0211661547     

#>

# Then define the default properties

$defaultdisplayset = 'Firstname','Lastname','Phone'

# Then create a default property display set

$defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet(‘DefaultDisplayPropertySet’,[string[]]$defaultDisplaySet)

# Now create the member info objects for add-member

$PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)

# finally use add-member to add the new member set into the existing object

$object | Add-Member MemberSet PSStandardMembers $PSStandardMembers

<#

Even easier way!!

Update-TypeData -TypeName User.Information -DefaultDisplayPropertySet FirstName,LastName,Phone

#>