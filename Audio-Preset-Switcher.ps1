# ============================================================================
# PROJECT: Hcwwmsi_Git27_Sound_Control
# Audio Preset Switcher - GUI Panel v1.0
# Author: Hcwwmsi (Audiophile Edition)
# Description: Lekki, graficzny przełącznik presetów audio THX Spatial
# ============================================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ============================================================================
# CONFIG - Ścieżki i preety
# ============================================================================

$THXConfigPath = "C:\ProgramData\THX\THXV2APOGamePresetConfig.xml"
$PresetBackupFolder = "C:\Presets_Backup"
$PresetSourceFolder = "C:\Presets"

# Definicja presetów
$Presets = @{
    "🎮 Kraken X USB - Balanced" = "Kraken_Balanced.xml"
    "🎵 Buds2 - Hi-Fi Soft Clarity" = "Buds2_HiFi.xml"
    "🎧 Kraken2 Hi-Fi Pulse (HYBRID)" = "Kraken2_Hybrid.xml"
    "🔥 Hardcore Electronica" = "HardcoreElectronika.xml"
    "🎼 Hi-Res Audiophile Reference" = "HiResAudiophile.xml"
}

# ============================================================================
# FUNKCJE
# ============================================================================

# Funkcja: Zmień preset audio
function Switch-AudioPreset {
    param(
        [string]$PresetFile
    )
    
    try {
        $sourcePath = Join-Path $PresetSourceFolder $PresetFile
        
        # Sprawdzenie, czy plik istnieje
        if (-not (Test-Path $sourcePath)) {
            [System.Windows.Forms.MessageBox]::Show(
                "Plik $PresetFile nie znaleziony w folderze $PresetSourceFolder",
                "Błąd",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error
            )
            return $false
        }
        
        # Backup obecnej konfiguracji
        if (Test-Path $THXConfigPath) {
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            Copy-Item $THXConfigPath "$PresetBackupFolder\THXV2APOGamePresetConfig_$timestamp.xml" -Force
        }
        
        # Kopiowanie nowego presetu
        Copy-Item $sourcePath $THXConfigPath -Force
        
        # Restart usługi audio
        Stop-Service -Name "Audiosrv" -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
        Start-Service -Name "Audiosrv"
        
        return $true
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Błąd: $_",
            "Błąd podczas przełączania presetu",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
        return $false
    }
}

# Funkcja: Wyświetl potwierdzenie
function Show-SuccessMessage {
    param([string]$PresetName)
    
    [System.Windows.Forms.MessageBox]::Show(
        "✅ Preset '$PresetName' aktywowany!`n`nUżywasz teraz tego profilu audio.",
        "Sukces!",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    )
}

# ============================================================================
# GUI - Główne okno
# ============================================================================

$form = New-Object System.Windows.Forms.Form
$form.Text = "🎧 Hcwwmsi Audio Preset Switcher v1.0"
$form.Width = 500
$form.Height = 450
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$form.ForeColor = [System.Drawing.Color]::White
$form.Font = New-Object System.Drawing.Font("Segoe UI", 10)

# Title Label
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "🎚️ Wybierz profil audio"
$titleLabel.Location = New-Object System.Drawing.Point(20, 20)
$titleLabel.Size = New-Object System.Drawing.Size(460, 30)
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$titleLabel.ForeColor = [System.Drawing.Color]::Cyan
$form.Controls.Add($titleLabel)

# Kombobox do wyboru presetu
$comboBox = New-Object System.Windows.Forms.ComboBox
$comboBox.Location = New-Object System.Drawing.Point(20, 60)
$comboBox.Size = New-Object System.Drawing.Size(460, 30)
$comboBox.Font = New-Object System.Drawing.Font("Segoe UI", 11)
$comboBox.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 50)
$comboBox.ForeColor = [System.Drawing.Color]::White
$comboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList

# Dodaj presety do comboboxa
foreach ($presetName in $Presets.Keys) {
    $comboBox.Items.Add($presetName) | Out-Null
}
$comboBox.SelectedIndex = 0
$form.Controls.Add($comboBox)

# Przycisk "Aktywuj Preset"
$activateButton = New-Object System.Windows.Forms.Button
$activateButton.Text = "▶️ AKTYWUJ PRESET"
$activateButton.Location = New-Object System.Drawing.Point(20, 110)
$activateButton.Size = New-Object System.Drawing.Size(460, 50)
$activateButton.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$activateButton.BackColor = [System.Drawing.Color]::FromArgb(0, 150, 0)
$activateButton.ForeColor = [System.Drawing.Color]::White
$activateButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$activateButton.FlatAppearance.BorderSize = 0

$activateButton.Add_Click({
    $selectedPreset = $comboBox.SelectedItem
    $presetFile = $Presets[$selectedPreset]
    
    if (Switch-AudioPreset -PresetFile $presetFile) {
        Show-SuccessMessage -PresetName $selectedPreset
    }
})
$form.Controls.Add($activateButton)

# Info Panel
$infoPanel = New-Object System.Windows.Forms.Panel
$infoPanel.Location = New-Object System.Drawing.Point(20, 180)
$infoPanel.Size = New-Object System.Drawing.Size(460, 200)
$infoPanel.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
$infoPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$form.Controls.Add($infoPanel)

# Info tekst
$infoText = New-Object System.Windows.Forms.Label
$infoText.Text = @"
📋 O PRESETACH:

🎮 Kraken X USB - Balanced
   Idealny do gier i muzyki z mocnym basem

🎵 Buds2 - Hi-Fi Soft Clarity
   Ciepły dźwięk, perfekcyjny do streamów

🎧 Kraken2 Hi-Fi Pulse (HYBRID)
   Uniwersalny profil dla obydwu słuchawek

🔥 Hardcore Electronica
   EDM, Techno - potęga i energia!

🎼 Hi-Res Audiophile Reference
   Studyjna czystość i neutralność
"@
$infoText.Location = New-Object System.Drawing.Point(10, 10)
$infoText.Size = New-Object System.Drawing.Size(440, 180)
$infoText.AutoSize = $false
$infoText.ForeColor = [System.Drawing.Color]::LightGreen
$infoText.Font = New-Object System.Drawing.Font("Consolas", 9)
$infoPanel.Controls.Add($infoText)

# Status bar
$statusBar = New-Object System.Windows.Forms.StatusBar
$statusBar.Text = "✅ Panel gotów do użytku | v1.0 | Hcwwmsi Audio Control"
$statusBar.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 40)
$statusBar.ForeColor = [System.Drawing.Color]::Cyan
$form.Controls.Add($statusBar)

# ============================================================================
# URUCHOMIENIE
# ============================================================================

$form.ShowDialog() | Out-Null
