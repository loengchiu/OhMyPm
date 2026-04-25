if (-not $script:OhMyPmEncodingLoaded) {
    $script:OhMyPmEncodingLoaded = $true
    $script:OhMyPmUtf8Strict = New-Object System.Text.UTF8Encoding($false, $true)
    $script:OhMyPmUtf8Bom = New-Object System.Text.UTF8Encoding($true)
    [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)
    $OutputEncoding = New-Object System.Text.UTF8Encoding($false)
}

function Read-Utf8Text {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return [System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $Path), $script:OhMyPmUtf8Strict)
}

function Read-Utf8Lines {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return [System.IO.File]::ReadAllLines((Resolve-Path -LiteralPath $Path), $script:OhMyPmUtf8Strict)
}

function Write-Utf8BomText {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [AllowEmptyString()]
        [string]$Content
    )

    $resolved = if (Test-Path -LiteralPath $Path) {
        (Resolve-Path -LiteralPath $Path).Path
    }
    else {
        $Path
    }

    [System.IO.File]::WriteAllText($resolved, $Content, $script:OhMyPmUtf8Bom)
}

function Read-Utf8Json {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return (Read-Utf8Text -Path $Path) | ConvertFrom-Json
}
