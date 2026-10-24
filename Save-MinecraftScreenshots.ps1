
param(
    [switch]$Preview
)

$SourceRoot = "C:\Users\Olivier\AppData\Roaming\PrismLauncher\instances"
$DestinationRoot = "D:\Jeux\Minecraft\Screenshots"

$Stats = @{
    Profiles   = 0
    Moved      = 0
    Duplicates = 0
    Renamed    = 0
    Errors     = 0
}

function Log($Type, $Message, $Color = "White") {
    Write-Host ("  [{0,-9}] {1}" -f $Type, $Message) -ForegroundColor $Color
}

Clear-Host
Write-Host "`n  MINECRAFT SCREENSHOT MANAGER" -ForegroundColor Cyan
Write-Host ("  " + ("=" * 55)) -ForegroundColor DarkGray
Log "SOURCE" $SourceRoot "Gray"
Log "TARGET" $DestinationRoot "Gray"

if ($Preview) {
    Log "PREVIEW" "Simulation mode - no files will be changed" "Yellow"
}

if (-not (Test-Path -LiteralPath $SourceRoot -PathType Container)) {
    throw "PrismLauncher instances directory not found!"
}

if (-not $Preview) {
    New-Item -ItemType Directory -Path $DestinationRoot -Force | Out-Null
}

$Profiles = @(Get-ChildItem -LiteralPath $SourceRoot -Directory)

foreach ($Profile in $Profiles) {

    # Support both minecraft and .minecraft directories
    $Folders = @(
        "minecraft\screenshots"
        ".minecraft\screenshots"
    ) | ForEach-Object {
        Join-Path $Profile.FullName $_
    } | Where-Object {
        Test-Path -LiteralPath $_ -PathType Container
    }

    if (-not $Folders) { continue }

    $Files = @(
        foreach ($Folder in $Folders) {
            Get-ChildItem -LiteralPath $Folder -File |
                Where-Object {
                    $_.Extension -in @(".png", ".jpg", ".jpeg", ".webp", ".bmp")
                }
        }
    )

    if ($Files.Count -eq 0) { continue }

    $Stats.Profiles++
    $TargetFolder = Join-Path $DestinationRoot $Profile.Name

    Write-Host "`n  -------------------------------------------------------" -ForegroundColor DarkGray
    Log "MODPACK" $Profile.Name "Cyan"
    Log "FOUND" "$($Files.Count) screenshots" "Gray"

    if (-not $Preview) {
        New-Item -ItemType Directory -Path $TargetFolder -Force | Out-Null
    }

    $Index = 0

    foreach ($File in $Files) {
        $Index++

        Write-Progress -Activity "Minecraft Screenshot Manager" `
            -Status "$($Profile.Name) - $Index / $($Files.Count)" `
            -PercentComplete (($Index / $Files.Count) * 100)

        try {
            $TargetFile = Join-Path $TargetFolder $File.Name
            $Renamed = $false

            if (Test-Path -LiteralPath $TargetFile -PathType Leaf) {

                # Verify duplicate content before deletion
                $SourceHash = (Get-FileHash -LiteralPath $File.FullName -Algorithm SHA256).Hash
                $TargetHash = (Get-FileHash -LiteralPath $TargetFile -Algorithm SHA256).Hash

                if ($SourceHash -eq $TargetHash) {
                    if (-not $Preview) {
                        Remove-Item -LiteralPath $File.FullName -Force
                    }

                    $Stats.Duplicates++
                    Log "DUPLICATE" "$($File.Name) - original removed" "Yellow"
                    continue
                }

                # Same filename, different image: preserve both
                $Number = 2
                do {
                    $NewName = "$($File.BaseName) ($Number)$($File.Extension)"
                    $TargetFile = Join-Path $TargetFolder $NewName
                    $Number++
                } while (Test-Path -LiteralPath $TargetFile)

                $Renamed = $true
            }

            if (-not $Preview) {
                Move-Item -LiteralPath $File.FullName -Destination $TargetFile -ErrorAction Stop
            }

            $Stats.Moved++

            if ($Renamed) {
                $Stats.Renamed++
                Log "RENAMED" "$($File.Name) -> $(Split-Path $TargetFile -Leaf)" "Magenta"
            }
            else {
                Log "MOVED" $File.Name "Green"
            }
        }
        catch {
            $Stats.Errors++
            Log "ERROR" "$($File.Name): $($_.Exception.Message)" "Red"
        }
    }
}

Write-Progress -Activity "Minecraft Screenshot Manager" -Completed

Write-Host "`n  =======================================================" -ForegroundColor Cyan
Write-Host "  SUMMARY" -ForegroundColor Cyan
Write-Host "  =======================================================" -ForegroundColor Cyan

Log "MODPACKS" $Stats.Profiles "White"
Log "MOVED" $Stats.Moved "Green"
Log "DUPLICATES" $Stats.Duplicates "Yellow"
Log "RENAMED" $Stats.Renamed "Magenta"
Log "ERRORS" $Stats.Errors $(if ($Stats.Errors) { "Red" } else { "Green" })

if ($Preview) {
    Write-Host "`n  PREVIEW COMPLETE - No files were modified." -ForegroundColor Yellow
}
else {
    Write-Host "`n  SCREENSHOT MERGE COMPLETE!" -ForegroundColor Green
}
