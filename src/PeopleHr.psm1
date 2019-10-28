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
        [string]
        $APIColumn1
    )
    
    process {
        $parameters = @{
            "ReasonForChange" = $ReasonForChange;
            "EmployeeId"      = $Id;
        }

        if ($Email) { $parameters += @{ "Email" = $Email } 
        }

        if ($APIColumn1) { $parameters += @{ "APIColumn1" = $APIColumn1 }
        }

        if ($PSCmdlet.ShouldProcess($Id, "Update")) {
            Invoke-PhrMethod -Endpoint "Employee" -ActionName "UpdateEmployeeDetail" -Parameters $parameters
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
#endregion Public

#region Private
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