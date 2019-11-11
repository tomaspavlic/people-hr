#region Public
function Get-PhrEmployee {
    [CmdletBinding()]
    param(
        [Parameter(
            Position = 0,
            Mandatory = $false
        )]
        [string]
        $EmployeeId = "",

        [Parameter(
            Mandatory = $false
        )]
        [switch]
        $IncludeLeavers = $false
    )

    process {
        $params = @{}
        $actionName = "GetAllEmployeeDetail"

        if ($IncludeLeavers) {
            $params.Add("IncludeLeavers", "true")
        } else {
            $params.Add("IncludeLeavers", "false")
        }

        if ($employeeId -ne "") {
            $params.Add("EmployeeId", $employeeId)
            $actionName = "GetEmployeeDetailById"
        }
        
        try {
            $response = Invoke-PhrMethod -Endpoint "Employee" -ActionName $actionName -Parameters $params -ErrorAction Stop

            $employees = @()

            foreach ($obj in $response) {
                $employees += New-Object PSObject -Property @{
                    EmployeeId  = $obj.EmployeeId.DisplayValue
                    EmailId     = $obj.EmailId.DisplayValue
                    Company     = $obj.Company.DisplayValue
                    FirstName   = $obj.FirstName.DisplayValue
                    LastName    = $obj.LastName.DisplayValue
                    Title       = $obj.Title.DisplayValue
                    JobRole     = $obj.JobRole.DisplayValue
                    Department  = $obj.Department.DisplayValue
                    Manager     = $null
                    ManagerId   = $obj.ReportsToEmployeeId.DisplayValue
                    Location    = $obj.Location.DisplayValue
                    APIColumn1  = $obj.APIColumn1
                    LeavingDate = if ($obj.LeavingDate -ne "") { (Get-Date $obj.LeavingDate) } else { $null }
                    StartDate   = if ($obj.StartDate.DisplayValue -ne "") { (Get-Date $obj.StartDate.DisplayValue) } else { $null }
                    EmploymentType = $obj.EmploymentType.DisplayValue
                }
            }

            foreach($emp in $employees) {
                
                if ($emp.EmployeeId -ne "") {
                    $emp.Manager = $employees | Where-Object { $_.EmployeeId -eq $emp.ManagerId } | Select-Object -First 1
                }

                $emp
            }
            
        } 
        catch {
            Write-Error $_.Exception.Message
        }
    }

}
function Get-PhrQuery {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        $QueryName
    )

    process {
        $parameters = @{
            "QueryName" = $QueryName;
        }

        Invoke-PhrMethod -Endpoint "Query" -ActionName "GetQueryResult" -Parameters $parameters
    }
}
function Update-PhrEmployee {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Id,

        [Parameter(Mandatory = $true)]
        [string]
        $ReasonForChange,

        [Parameter(Mandatory = $false)]
        [string]
        $Email,

        [Parameter(Mandatory = $false)]
        [ValidateLength(1, 100)]
        [string]
        $Title,

        [Parameter(Mandatory = $false)]
        [string]
        [ValidateLength(1, 50)]
        $FirstName,

        [Parameter(Mandatory = $false)]
        [string]
        [ValidateLength(1, 50)]
        $LastName,

        [Parameter(Mandatory = $false)]
        [string]
        [ValidateSet('Female', 'Male')]
        $Gender,

        [Parameter(Mandatory = $false)]
        [DateTime]
        $DateOfBirth,

        [Parameter(Mandatory = $false)]
        [DateTime]
        $StartDate,

        [Parameter(Mandatory = $false)]
        [string]
        $ReportsTo,

        [Parameter(Mandatory = $false)]
        [DateTime]
        $ReportsToEffectiveDate,

        [Parameter(Mandatory = $false)]
        [string]
        $Company,

        [Parameter(Mandatory = $false)]
        [DateTime]
        $CompanyEffectiveDate,

        [Parameter(Mandatory = $false)]
        [string]
        $JobRole,

        [Parameter(Mandatory = $false)]
        [DateTime]
        $JobRoleEffectiveDate,

        [Parameter(Mandatory = $false)]
        [string]
        $Location,

        [Parameter(Mandatory = $false)]
        [DateTime]
        $LocationEffectiveDate,

        [Parameter(Mandatory = $false)]
        [string]
        $Department,

        [Parameter(Mandatory = $false)]
        [DateTime]
        $DepartmentEffectiveDate,

        [Parameter(Mandatory = $false)]
        [string]
        $EmploymentType,

        [Parameter(Mandatory = $false)]
        [DateTime]
        $EmploymentTypeEffectiveDate,

        [Parameter(Mandatory = $false)]
        [string]
        $Address,

        [Parameter(Mandatory = $false)]
        [string]
        $PersonalPhoneNumber,

        [Parameter(Mandatory = $false)]
        [string]
        $APIColumn1
    )
    
    process {
        $parameters = @{
            "ReasonForChange" = $ReasonForChange;
            "EmployeeId"      = $Id;
        }

        if ($Email) { $parameters += @{ "Email" = $Email }  }
        if ($Title) { $parameters += @{ "Title" = $Title } }
        if ($FirstName) { $parameters += @{ "FirstName" = $FirstName } }
        if ($LastName) { $parameters += @{ "LastName" = $LastName } }
        if ($Gender) { $parameters += @{ "Gender" = $Gender } }
        if ($Address) { $parameters += @{ "Address" = $Address } }
        if ($PersonalPhoneNumber) { $parameters += @{ "PersonalPhoneNumber" = $PersonalPhoneNumber }}

        if (Test-EffectiveDateDependancy -Parameter $Company -EffectiveDate $CompanyEffectiveDate) {
            $parameters += @{ "CompanyEffectiveDate" = ('{0:yyyy-MM-dd}' -f $CompanyEffectiveDate) }
            $parameters += @{ "Company" = $Company } 
        }

        if (Test-EffectiveDateDependancy -Parameter $JobRole -EffectiveDate $JobRoleEffectiveDate) { 
            $parameters += @{ "JobRoleEffectiveDate" = ('{0:yyyy-MM-dd}' -f $JobRoleEffectiveDate) }
            $parameters += @{ "JobRole" = $JobRole } 
        }

        if (Test-EffectiveDateDependancy -Parameter $Location -EffectiveDate $LocationEffectiveDate) { 
            $parameters += @{ "LocationEffectiveDate" = ('{0:yyyy-MM-dd}' -f $LocationEffectiveDate) }
            $parameters += @{ "Location" = $Location } 
        }

        if (Test-EffectiveDateDependancy -Parameter $Department -EffectiveDate $DepartmentEffectiveDate) { 
            $parameters += @{ "DepartmentEffectiveDate" = ('{0:yyyy-MM-dd}' -f $DepartmentEffectiveDate) }
            $parameters += @{ "Department" = $Department } 
        }

        if (Test-EffectiveDateDependancy -Parameter $EmploymentType -EffectiveDate $EmploymentTypeEffectiveDate) { 
            $parameters += @{ "EmploymentTypeEffectiveDate" = ('{0:yyyy-MM-dd}' -f $EmploymentTypeEffectiveDate) }
            $parameters += @{ "EmploymentType" = $EmploymentType } 
        }
        
        if ($DateOfBirth) { $parameters += @{ "DateOfBirth" = ('{0:yyyy-MM-dd}' -f $DateOfBirth) } }
        if ($StartDate) { $parameters += @{ "StartDate" = ('{0:yyyy-MM-dd}' -f $StartDate) } }
        if ($ReportsToEffectiveDate) { $parameters += @{ "ReportsToEffectiveDate" = ('{0:yyyy-MM-dd}' -f $ReportsToEffectiveDate) } }
        if ($APIColumn1) { $parameters += @{ "APIColumn1" = $APIColumn1 } }
        if ($ReportsTo) { $parameters += @{ "ReportsTo" = $ReportsTo } }

        if ($PSCmdlet.ShouldProcess($Id, "Update")) {
            Invoke-PhrMethod -Endpoint "Employee" -ActionName "UpdateEmployeeDetail" -Parameters $parameters
        }
    }
}
function Update-PhrEmployeeId {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $OldId,

        [Parameter(Mandatory = $true)]
        [string]
        $NewId,

        [Parameter(Mandatory = $true)]
        [string]
        $ReasonForChange
    )
    
    process {
        $parameters = @{
            "ReasonForChange" = $ReasonForChange;
            "OldEmployeeId" = $OldId;
            "NewEmployeeId" = $NewId;
        }

        if ($PSCmdlet.ShouldProcess($OldId, "Update Employee ID")) {
            Invoke-PhrMethod -Endpoint "Employee" -ActionName "UpdateEmployeeId" -Parameters $parameters
        }
    }
}
function Test-Authentication {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $EmailAddress,

        [Parameter(Mandatory = $true)]
        [SecureString]
        $Password
    )

    process {
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
        $unsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

        Invoke-PhrMethod -Endpoint "Employee" -ActionName "CheckAuthentication" -Parameters @{
            "EmailAddress" = $EmailAddress
            "Password" = $unsecurePassword
        }
    }
}
function Set-PhrConfigServer {
    [CmdletBinding()]
    param(
        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [Alias('ApiUri')]
        $Server = "https://api.peoplehr.net/",

        [Parameter( Mandatory = $true )]
        [ValidateNotNullOrEmpty()]
        $ApiKey
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        if ($MyInvocation.MyCommand.Module.PrivateData) {
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Adding session result to existing module PrivateData"
            $MyInvocation.MyCommand.Module.PrivateData.ApiKey = $ApiKey
            $MyInvocation.MyCommand.Module.PrivateData.ApiUri = $Server
        }
        else {
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Creating module PrivateData"
            $MyInvocation.MyCommand.Module.PrivateData = @{
                'ApiKey' = $ApiKey
                'ApiUri' = $Server
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
function Get-PhrOtherEvent {
    [CmdletBinding()]
    param(
        [Parameter(
            Position = 0,
            Mandatory = $true
        )]
        [string]
        $EmployeeId,

        [Parameter(
            Position = 1,
            Mandatory = $true
        )]
        [string]
        $Start,

        [Parameter(
            Position = 2,
            Mandatory = $true
        )]
        [string]
        $End
    )

    $params = @{}
    $actionName = "GetOtherEventDetail"

    $params.Add("EmployeeId", $EmployeeId)
    $params.Add("StartDate", $Start)
    $params.Add("EndDate", $End)

    Invoke-PhrMethod -Endpoint "OtherEvent" -ActionName $actionName -Parameters $params -ErrorAction Stop
}

function New-PhrOtherEvent {
    [CmdletBinding()]
    param(
        [Parameter(
            Position = 0,
            Mandatory = $true
        )]
        [string]
        $EmployeeId,
        [Parameter(
            Position = 0,
            Mandatory = $true
        )]
        [string]
        $Start,

        [Parameter(
            Position = 0,
            Mandatory = $true
        )]
        [string]
        $End,
        
        [Parameter(
            Position = 0,
            Mandatory = $true
        )]
        [string]
        $DurationInDays,

        [Parameter(
            Position = 0,
            Mandatory = $true
        )]
        [string]
        $Reason,

        [Parameter(
            Position = 0,
            Mandatory = $true
        )]
        [ValidateSet("Days", "Hours")]
        [string]
        $DurationType,

        [Parameter(
            Position = 0,
            Mandatory = $false
        )]
        [string]
        $Comment
    )

    $params = @{}
    $actionName = "AddOtherEventLeave" #addothereventleave
    $durationTypeId = if ($DurationType -eq "Days") { "1" } else { "2" }

    $params.Add("EmployeeId", $EmployeeId)
    $params.Add("StartDate", $Start)
    $params.Add("EndDate", $End)
    $params.Add("DurationInDays", $durationInDays)
    $params.Add("Other Event Reason", $Reason)
    $params.Add("DurationType", $durationTypeId)

    if ($Comment -ne $null) {
        $params.Add("Comments", $Comment)
    }

    Invoke-PhrMethod -Endpoint "OtherEvent" -ActionName $actionName -Parameters $params -ErrorAction Stop
}

#endregion Public

#region Private

function Test-EffectiveDateDependancy
{
    param(
        [Parameter(Mandatory = $true)]
        [object]
        [AllowNull()]
        $Parameter,

        [Parameter(Mandatory = $true)]
        [object]
        [AllowNull()]
        $EffectiveDate
    )

    process {
        if ($Parameter) {
            if (!$EffectiveDate) {
                Write-Error "Missing parameter: Effective Date" -ErrorAction Stop
            }
        } else {
            return $false
        }

        return $true
    }
}

function Invoke-PhrMethod {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string] 
        $Endpoint,

        [Parameter(Mandatory = $true, Position = 1)]
        [string] 
        $ActionName,

        [Parameter(Mandatory = $false, Position = 2)]
        [object] 
        $Parameters
    )

    begin {
        if (!($MyInvocation.MyCommand.Module.PrivateData)) {
            Write-Error "Missing api-key and/or api-url. Run Set-PhrConfigServer first."
        }

        $apiKey = $MyInvocation.MyCommand.Module.PrivateData.ApiKey
        $apiUri = $MyInvocation.MyCommand.Module.PrivateData.ApiUri
    }

    process {
        $request = @{"APIKey" = $apiKey; "Action" = $ActionName}
        $request += $Parameters

        try {
            Write-Progress -Activity ("Fetching data from PeopleHR API. ({0})" -f $ActionName)

            $response = Invoke-RestMethod -Uri "$apiUri/$Endpoint" `
                -Body ( $request | ConvertTo-Json ) `
                -ContentType "application/json; charset=utf-8" `
                -Method "POST"

            if ($response.Status -ne "0") {
                Write-Error $response.Message -ErrorAction Stop
            }

            Write-Progress -Activity ("Fetching data from PeopleHR API. ({0})" -f $ActionName) -Completed

            return $response.Result
        }
        catch {
            Write-Error -Message $_.Exception.Message
        }
    }
}
#endregion Private