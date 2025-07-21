<#
.SYNOPSIS
    Retrieves Microsoft Entra Connect version information, including release and retirement dates.

.DESCRIPTION
    Scrapes the Microsoft documentation page for Entra Connect version history,
    extracts version numbers, release dates, and retirement dates, and returns the results as objects.
    You can filter by a specific version, get the latest version, or list all versions.
    The output date format can be customized.

.PARAMETER All
    Returns all available Entra Connect versions.

.PARAMETER EntraConnectVersion
    The specific Entra Connect version to filter results.

.PARAMETER Latest
    Returns only the latest Entra Connect version.

.PARAMETER DateFormat
    Optional. The date format to use for output. Default is 'dd/MM/yyyy'.

.EXAMPLE
    Get-EntraConnectVersionInfo -EntraConnectVersion "2.4.131.0"
    Returns details for version 2.4.131.0.

.EXAMPLE
    Get-EntraConnectVersionInfo -Latest
    Returns details for the latest available version.

.EXAMPLE
    Get-EntraConnectVersionInfo
    Returns details for all available versions.

.EXAMPLE
    Get-EntraConnectVersionInfo -DateFormat "yyyy-MM-dd"
    Returns all versions with dates formatted as yyyy-MM-dd.

.EXAMPLE
    Get-EntraConnectVersionInfo -Latest -DateFormat "yyyy-MM-dd"
    Returns the latest version with dates formatted as yyyy-MM-dd.

.NOTES
    Requires internet access to fetch data from Microsoft Docs.
#>
function Get-EntraConnectVersionInfo 
{
    [CmdletBinding(DefaultParameterSetName = 'All')]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'SpecificVersion')]
        [String]
        $EntraConnectVersion,
        [Parameter(Mandatory = $true, ParameterSetName = 'Latest')]
        [Switch]
        $Latest,
        [Parameter(Mandatory = $false, ParameterSetName = 'All')]
        [Switch]
        $All,
        [Parameter(Mandatory = $false,ParameterSetName = 'All')]
        [Parameter(Mandatory = $false, ParameterSetName = 'SpecificVersion')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Latest')]
        [string]
        $DateFormat = 'dd/MM/yyyy'
    )

    $url = "https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/reference-connect-version-history"
    $html = Invoke-WebRequest -Uri $url -UseBasicParsing | Select-Object -ExpandProperty Content

    $retireMap = @{}
    $retirementStart = $html.IndexOf('<h2 id="retiring-microsoft-entra-connect-2x-versions"')
    if ($retirementStart -gt 0)
    {
        $retirementHtml = $html.Substring($retirementStart, [Math]::Min(15000, $html.Length - $retirementStart))
        $tablePattern = '<table.*?</table>'
        $tableMatch = [regex]::Match($retirementHtml, $tablePattern, 'Singleline')
        if ($tableMatch.Success)
        {
            $tableContent = $tableMatch.Value
            $cleanHtml = $tableContent -replace '&nbsp;', ' ' -replace '<br\s*/?>', "`n"
            $xmlContent = "<root>$cleanHtml</root>"
            $xml = [xml]$xmlContent

            foreach ($row in $xml.root.table.tbody.tr)
            {
                $version = $row.td[0].InnerText.Trim()
                $rawDate = $row.td[1]
                $cleanDate = ($rawDate -replace '\(.*?\)', '').Trim()
                $dateMatch = [regex]::Match($cleanDate, '\d{1,2} \w{3,9} \d{4}')
                $retireDate = "Unknown"
                if ($dateMatch.Success)
                {
                    $retireDate = ([datetime]$dateMatch.Value).ToString($DateFormat)
                }
                $retireMap[$version] = $retireDate
            }
        }
    }

    $results = @()
    $versionPattern = '<h2[^>]*id="(?<id>\d+)"[^>]*>\s*(?<version>\d+\.\d+\.\d+\.\d+)\s*</h2>'
    $releasePattern = '<h3[^>]*>\s*Release status\s*</h3>\s*<p>(?<date>.*?)</p>'

    $versionMatches = [regex]::Matches($html, $versionPattern)

    foreach ($vm in $versionMatches)
    {
        $version = $vm.Groups['version'].Value
        $start = $vm.Index
        $subHtml = $html.Substring($start, [Math]::Min(5000, $html.Length - $start))

        $releaseDate = "Unknown"
        $releaseMatch = [regex]::Match($subHtml, $releasePattern, 'Singleline')
        if ($releaseMatch.Success)
        {
            $text = $releaseMatch.Groups['date'].Value
            $dateMatch = [regex]::Match($text, '(?<date>\d{1,2}/\d{1,2}/\d{4}|\d{1,2} \w+ \d{4}|[A-Za-z]+ \d{1,2}, \d{4})')
            if ($dateMatch.Success)
            {
                $releaseDate = ([datetime]$dateMatch.Groups['date'].Value).ToString($DateFormat)
            }
        }

        if ($retireMap.ContainsKey($version))
        {
            $retirementDate = $retireMap[$version]
        }
        else
        {
            $retirementDate = "Retired"
        }

        $results += [pscustomobject]@{
            Version        = $version
            ReleaseDate    = $releaseDate
            RetirementDate = $retirementDate
        }
    }

    if ($EntraConnectVersion)
    {
        $results = $results | Where-Object { $_.Version -eq $EntraConnectVersion }
        if ($results.Count -eq 0)
        {
            Write-Error "Version '$EntraConnectVersion' not found in the version history."
        }
    }
    if ($Latest)
    {
        $results = $results | Sort-Object {[version]$_.Version} -Descending | Select-Object -First 1
    }
    return $results | Sort-Object {[version]$_.Version} -Descending
}
