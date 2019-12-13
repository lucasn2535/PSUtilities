function WriteOutputMeasureItems {
    param (
        [string]$Path,
        [int]$Count
    )
    Write-Host "${Path}: $Count"
}

function Measure-Items {
    [Alias("Count")]
    Param(
        [Alias("Loc", "L")]
        [string]$Location='.\',
        [Alias("Rec", "R")]
        [switch]$Recurse,
        [Alias("F")]
        [string]$Filter,
        [Alias("I")]
        [switch]$EachImmediate,
        [Alias("E")]
        [switch]$EachRecusive
    )

    $Items = @{}
    $Parameters = @{}

    if (-not [string]::IsNullOrEmpty($Filter)) {
        $Parameters.add("Filter", $Filter)
    }
    if ($Recurse) {
        $Parameters.add("Recurse", $True)
    }


    $Items.add((Get-Item $Location | Select-Object -ExpandProperty FullName), (Get-ChildItem $Location @Parameters | Measure-Object | Select-Object -ExpandProperty Count))

    if ($EachImmediate -or $EachRecusive) {
        # Have to loop through the directories and display the count
        Get-ChildItem $Location | ForEach-Object {
            if ((Get-Item $_.FullName) -is [System.IO.DirectoryInfo]) {
                if ($EachRecusive) {
                    Measure-Items @Parameters -Location $_.FullName -EachRecusive
                } else {
                    Measure-Items @Parameters -Location $_.FullName
                }
            }
        }
    }

    if (-not $EachImmediate) {
        $Items
    }
}
 Export-ModuleMember -Alias * -Function *
