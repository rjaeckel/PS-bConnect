Function Invoke-bConnectPatch() {
    <#
        .Synopsis
            INTERNAL - HTTP-PATCH against bConnect
        .Parameter Data
            Hashtable with parameters
        .Parameter Version
            bConnect version to use
    #>

    Param(
        [Parameter(Mandatory=$true)][string]$Controller,
        [Parameter(Mandatory=$true)][PSCustomObject]$Data,
        [string]$objectGuid,
        [string]$Version
    )

    If(!$script:_connectInitialized) {
        Write-Error "bConnect module is not initialized. Use 'Initialize-bConnect' first!"
        return $false
    }

    If([string]::IsNullOrEmpty($Version)) {
        $Version = $script:_bConnectFallbackVersion
    }

    If($verbose){
        $ProgressPreference = "Continue"
    } else {
        $ProgressPreference = "SilentlyContinue"
    }

    try {
        If($Data.Count -gt 0) {
            $_body = ConvertTo-Json $Data

            If(![string]::IsNullOrEmpty($objectGuid)) {
                $_rest = Invoke-RestMethod -Uri "$($script:_connectUri)/$($Version)/$($Controller)?id=$($objectGuid)" -Body $_body -Credential $script:_connectCredentials -Method Patch -ContentType "application/json"
            } else {
                $_rest = Invoke-RestMethod -Uri "$($script:_connectUri)/$($Version)/$($Controller)" -Body $_body -Credential $script:_connectCredentials -Method Patch -ContentType "application/json"
            }

            If($_rest) {
                return $_rest
            } else {
                return $true
            }
        } else {
            return $false
        }
    }

    catch {
        $_errMsg = ""

        Try {
            $_response = ConvertFrom-Json $_
        }

        Catch {
            $_response = $false
        }

        If($_response) {
            $_errMsg = $_response.Message
        } else {
            $_errMsg =  $_
        }

        If($_body) {
            $_errMsg = "$($_errMsg) `nHashtable: $($_body)"
        }

        Write-Error $_errMsg

        return $false
    }
}
