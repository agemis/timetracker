# Charger l'assemblage Windows Forms
Add-Type -AssemblyName System.Windows.Forms

# Initialisation de variables
$categories = @("Réunions", "Incidents", "Tickets", "Changes/maj", "Doc/cmdb", "Améliorations", "Autres")
$currentCategory = $null
$startTime = $null
$totalTimes = @{}
foreach ($category in $categories) {
    $totalTimes[$category] = [TimeSpan]::Zero
}

# Créer le formulaire
$form = New-Object System.Windows.Forms.Form
$form.Text = "Suivi du Temps"
$form.Size = New-Object System.Drawing.Size(300, 500)
# $form.TopMost = $true

# Ajouter les boutons pour les catégories
$buttons = @{}
$yPosition = 10
foreach ($category in $categories) {
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $category
    $button.Width = 200
    $button.Location = New-Object System.Drawing.Point(50, $yPosition)
    $button.Add_Click({ 
        param($sender, $eventArgs)
        $buttonName = $sender.Text
        switchCategory $buttonName 
    })
    
    $form.Controls.Add($button)
    $buttons[$category] = $button
    $yPosition += 40
}

# Bouton de pause
$pauseButton = New-Object System.Windows.Forms.Button
$pauseButton.Text = "Pause"
$pauseButton.Width = 200
$pauseButton.Location = New-Object System.Drawing.Point(50, $yPosition)
$pauseButton.BackColor = [System.Drawing.Color]::LightGray
$pauseButton.Add_Click({ pauseTimer })
$form.Controls.Add($pauseButton)
$yPosition += 40

# Afficher les temps passés par catégorie
$labels = @{}
foreach ($category in $categories) {
    $label = New-Object System.Windows.Forms.Label
    $label.Text = "$category : 00:00:00"
    $label.Width = 200
    $label.Location = New-Object System.Drawing.Point(50, $yPosition)
    $form.Controls.Add($label)
    $labels[$category] = $label
    $yPosition += 25
}

# Bouton de résumé
$summaryButton = New-Object System.Windows.Forms.Button
$summaryButton.Text = "Afficher le Résumé"
$summaryButton.Width = 200
$summaryButton.Location = New-Object System.Drawing.Point(50, $yPosition)
$summaryButton.Add_Click({ showSummary })
$form.Controls.Add($summaryButton)

# Fonction pour changer de catégorie
function switchCategory {
    param ($newCategory)
    $now = Get-Date
    if ($global:currentCategory -ne $null) {
        # Arrêter le chronomètre de la catégorie précédente
        $elapsed = New-TimeSpan -Start $global:startTime -End $now
        $global:totalTimes[$currentCategory] = $global:totalTimes[$currentCategory].Add($elapsed)
        $buttons[$currentCategory].BackColor = [System.Drawing.Color]::LightGray
    }

    # Démarrer le chronomètre pour la nouvelle catégorie
    $global:currentCategory = $newCategory
    $global:startTime = $now
    $buttons[$newCategory].BackColor = [System.Drawing.Color]::Green
    $pauseButton.BackColor = [System.Drawing.Color]::LightGray
}

# Fonction pour mettre en pause le chronomètre
function pauseTimer {
    $now = Get-Date
    if ($global:currentCategory -ne $null) {
        $elapsed = New-TimeSpan -Start $global:startTime -End $now


        $global:totalTimes[$currentCategory] = $global:totalTimes[$currentCategory].Add($elapsed)
        $buttons[$currentCategory].BackColor = [System.Drawing.Color]::LightGray
        $global:currentCategory = $null
        $global:startTime = $null
        $pauseButton.BackColor = [System.Drawing.Color]::Orange
    }
}

# Mettre à jour les labels toutes les secondes
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 1000
$timer.Add_Tick({
    $now = Get-Date
    foreach ($category in $categories) {
        $totalTime = $global:totalTimes[$category]
        if ($category -eq $currentCategory -and $startTime -ne $null) {
            $totalTime += $now - $global:startTime
        }
        $labels[$category].Text = "$category : " + $totalTime.ToString("hh\:mm\:ss")
    }
})
$timer.Start()

# Fonction pour afficher le résumé
function showSummary {
    $summaryForm = New-Object System.Windows.Forms.Form
    $summaryForm.Text = "Résumé du Temps"
    $summaryForm.Size = New-Object System.Drawing.Size(300, 450)

    $summaryText = "Temps total passé par catégorie :`r`n"
    foreach ($category in $categories) {
        # $summaryText += "$category : " + $global:totalTimes[$category].ToString("hh\:mm\:ss") + "`r`n"
        $summaryText += $labels[$category].Text + "`r`n"
    }

    $summaryLabel = New-Object System.Windows.Forms.TextBox 
    $summaryLabel.Multiline = $True;
    $summaryLabel.Text = $summaryText
    $summaryLabel.Width = 250
    $summaryLabel.Height = 250
    $summaryLabel.Scrollbars = "Vertical" 
    $summaryLabel.Location = New-Object System.Drawing.Point(20, 20)
    $summaryForm.Controls.Add($summaryLabel)

    # Bouton pour sauvegarder le résumé
    $saveButton = New-Object System.Windows.Forms.Button
    $saveButton.Text = "Enregistrer le Résumé"
    $saveButton.Width = 200
    $saveButton.Location = New-Object System.Drawing.Point(40, 350)
    $saveButton.Add_Click({ saveSummary })
    $summaryForm.Controls.Add($saveButton)

    $summaryForm.ShowDialog()
}

# Fonction pour sauvegarder le résumé dans un fichier texte
function saveSummary {
    $summaryContent = "Temps total passé par catégorie :`r`n"
    foreach ($category in $categories) {
        # $summaryContent += "$category : " + $global:totalTimes[$category].ToString("hh\:mm\:ss") + "`r`n"
        $summaryContent += $labels[$category].Text + "`r`n"
    }
    $summaryContent | Out-File -Encoding "UTF8" -FilePath "$PSScriptRoot\resume_temps.txt"
    # [System.Windows.Forms.MessageBox]::Show("Résumé enregistré dans 'resume_temps.txt'")
}

# Gérer la fermeture du formulaire
$form.Add_FormClosing({
    saveSummary
})

# Afficher le formulaire
[void]$form.ShowDialog()