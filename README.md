![License](https://img.shields.io/badge/license-MIT-blue.svg?style=for-the-badge)

# [PeopleHR]([https://](https://github.com/tomaspavlic/people-hr))

PeopleHR is a Windows PowerShell module to interact with PeopleHR via a REST API, while maintaining a consistent PowerShell look and feel.

## Installation

Install PeopleHR from the PowerShell Gallery! Install-Module requires PowerShellGet (included in PS v5, or download for v3/v4 via the gallery link)

```powershell
# One time only install:
Install-Module PeopleHR -Scope CurrentUser

# Check for updates occasionally:
Update-Module PeopleHR
```

## Usage

```powershell
# Import the module
Import-Module PeopleHR

# Configure server settings
Set-PhrConfigServer -ApiKey 'YOUR_API_KEY' -ApiUri 'https://api.peoplehr.net'
```

## Examples 
```powershell
# Configure server settings
Set-PhrConfigServer -ApiKey 'b12cf33b-0c4b-4d9e-9aa0-e238069b3fe7' -ApiUri 'https://api.peoplehr.net'

# Get employee with ID "CZ_111"
Get-PhrEmployee -EmployeeId "CZ_111"
```

### Output
```
APIColumn1     : S-1-5-21-3042408965-452277034-1058515905-2212
LeavingDate    :
Manager        :
EmailId        : test@gmail.com
FirstName      : Tomáš
EmploymentType : Employment Contract-unlimited period, FTE             Title          : Mr
Company        : Topdev s.r.o.
Location       : Brno, CZ
EmployeeId     : CZ_111
LastName       : Pavlič
Department     : IT
JobRole        : Head of IT
ManagerId      : CZ_001
```

### Disclaimer
This project was developed because of need to implement PeopleHR with Active Directory. I'm aware the module does not include all available endpoint functions.

> This is an open source project (under the MIT license), and all contributors are volunteers. All commands are executed at your own risk. Please have good backups before you start, because you can delete a lot of stuff if you're not careful.