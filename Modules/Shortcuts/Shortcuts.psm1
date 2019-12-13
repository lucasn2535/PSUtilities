$Global:PreviousLocation = '.\'
$Shortcuts = Import-Clixml $PSScriptRoot\shortcuts.xml
function Get-Shortcut {
    <#
        .Description
        Gets the value associated with a shortcut.
    #>
    [Alias('gs')]
    Param(
        [string]$Shortcut,
        [switch][Alias('e')]$EchoOnNoExist
    )
    if (!$Shortcut) {
        $Shortcuts.GetEnumerator() | sort name
        return
    }

    if ($Shortcuts.Contains($Shortcut)) {
        return $Shortcuts[$Shortcut]
    } elseif ($EchoOnNoExist) {
        return $Shortcut
    }
}

function Set-Shortcut {
    <#
        .Description
        Modifies a shortcut by replacing an existing one or adding a new one.
    #>
    [Alias('ss')]
    Param(
        [Parameter(Mandatory=$true)][string][Alias('s')]$Shortcut,
        [string][Alias('v')]$Value,
        [switch][Alias('r')]$Remove
    )

    $NewShortcuts = $Shortcuts
    try {
        if ($Remove) {
            $NewShortcuts.Remove($Shortcut)
            Write-Output "$Shortcut was removed from shortcuts."
        } else {
            $NewShortcuts.Set_Item($Shortcut, $Value)
            Write-Output "$Shortcut was added to shortcuts."
        }
        $NewShortcuts | Export-Clixml "$PSScriptRoot\shortcuts.xml"
    }
    catch {
        Write-Output "Could not execute request: $_"
    }
}

function Set-Directory {
    <#
        .Description
        Uses shortcuts to change location. If shortcut does not exist,
        The provided value will be used.
    #>
    [Alias('jt')]
    Param(
        [Parameter(Mandatory=$true, Position=1)][string]$Shortcut
    )

    Get-Shortcut $Shortcut -EchoOnNoExist | cd
}

function Set-LocationProxy {
    [CmdletBinding()]
    [Alias('cd')]
    Param(
        [Parameter(ValueFromPipeline=$true)][string]$Path,
        [switch]$PassThru
    )
    $Global:PreviousLocation = Get-Location
    if ($PassThru) {
        Set-Location -Path $Path -PassThru $PassThru
    } else {
        Set-Location -Path $Path
    }
}

function Get-PreviousLocation {
    return $Global:PreviousLocation
}

function Set-PreviousLocation {
    <#
        .Description
        Sets current location to the previous location.
    #>
    cd $Global:PreviousLocation
}

function Open-Location {
    <#
        .Description
        Uses shortcuts to open the location. If the shortcut does not exist,
        The provided value will be used.
    #>
    [Alias('ol')]
    param (
        [Parameter(Mandatory=$true, Position=1)][string]$Shortcut
    )
    $OpenPath = Get-Shortcut $Shortcut -EchoOnNoExist
    Start-Process -FilePath $OpenPath
}

New-Alias -Name jb -Value Set-PreviousLocation -Description "Return to previous location."
del alias:cd -Force
New-Alias -Name cd -Value Set-LocationProxy -Option AllScope -Force -Description "Set location."

Export-ModuleMember -Alias * -Function *
