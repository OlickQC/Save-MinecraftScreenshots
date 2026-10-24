# Minecraft Screenshot Manager

A PowerShell script that collects screenshots from every **PrismLauncher** modpack into one organized location.

## What it does

- Scans each modpack's `minecraft\screenshots` or `.minecraft\screenshots` folder.
- Moves screenshots to `D:\Jeux\Minecraft\Screenshots\<Modpack Name>\`.
- If a file with the same name already exists, compares their **SHA256 hashes**:
  - **Identical:** deletes the original screenshot.
  - **Different:** renames the incoming screenshot (e.g., `image (2).png`) to keep both.
- Displays color-coded activity, a progress bar, and a final summary.
- Supports PNG, JPG, JPEG, WEBP, and BMP files.

## Usage

Requires **Windows PowerShell 5.1** or **PowerShell 7**.

Save the script as `Merge-MinecraftScreenshots.ps1`, open PowerShell in that folder, and run:

**Preview changes (recommended):**

```powershell
.\Merge-MinecraftScreenshots.ps1 -Preview
```

**Move the screenshots:**

```powershell
.\Merge-MinecraftScreenshots.ps1
```

## Paths

Edit these variables near the top of the script if needed:

```powershell
$SourceRoot = "C:\Users\Olivier\AppData\Roaming\PrismLauncher\instances"
$DestinationRoot = "D:\Jeux\Minecraft\Screenshots"
```

> **Note:** Only the screenshots are moved; modpack folders remain untouched. Duplicate detection compares files with the **same name** within the same modpack's destination folder. Preview mode makes no file changes.
