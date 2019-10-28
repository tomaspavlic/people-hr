# [PeopleHR]([https://](https://github.com/tomaspavlic/people-hr))

PeopleHR is a Windows PowerShell module to interact with PeopleHR via a REST API, while maintaining a consistent PowerShell look and feel.

## Installation

Install PeopleHR from the PowerShell Gallery! Install-Module requires PowerShellGet (included in PS v5, or download for v3/v4 via the gallery link)

```
# One time only install:
Install-Module PeopleHR -Scope CurrentUser

# Check for updates occasionally:
Update-Module PeopleHR
```

## Usage

```
# To use each session:
Import-Module PeopleHR
Set-PhrConfigServer -ApiKey 'YOUR_API_KEY' -ApiUri 'https://api.peoplehr.net'
```

### Disclaimer
This project was developed because of need to implement PeopleHR with Active Directory. I'm aware the module does not include all available endpoint functions.

> This is an open source project (under the MIT license), and all contributors are volunteers. All commands are executed at your own risk. Please have good backups before you start, because you can delete a lot of stuff if you're not careful.