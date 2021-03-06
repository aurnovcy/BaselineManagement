if (Get-Module -ListAvailable -Name â€˜securitypolicydscâ€™) {
    Uninstall-Module -Name 'securitypolicydsc' -Force }
if (Get-Module -ListAvailable -Name â€˜auditpolicydscâ€™) {
    Uninstall-Module -Name 'auditpolicydsc' -Force }

Install-Module baselinemanagement -scope currentuser -Repository psgallery -AllowClobber -Force

Function Get-PackageName()
{
	Add-Type -AssemblyName System.Windows.Forms
	Add-Type -AssemblyName System.Drawing

	$form = New-Object System.Windows.Forms.Form
	$form.Text = 'Enter DSC Name'
	$form.Size = New-Object System.Drawing.Size(300,200)
	$form.StartPosition = 'CenterScreen'

	$okButton = New-Object System.Windows.Forms.Button
	$okButton.Location = New-Object System.Drawing.Point(75,120)
	$okButton.Size = New-Object System.Drawing.Size(75,23)
	$okButton.Text = 'OK'
	$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
	$form.AcceptButton = $okButton
	$form.Controls.Add($okButton)

	$cancelButton = New-Object System.Windows.Forms.Button
	$cancelButton.Location = New-Object System.Drawing.Point(150,120)
	$cancelButton.Size = New-Object System.Drawing.Size(75,23)
	$cancelButton.Text = 'Cancel'
	$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
	$form.CancelButton = $cancelButton
	$form.Controls.Add($cancelButton)

	$label = New-Object System.Windows.Forms.Label
	$label.Location = New-Object System.Drawing.Point(10,20)
	$label.Size = New-Object System.Drawing.Size(280,20)
	$label.Text = 'Please enter the name of the resultant DSC script:'
	$form.Controls.Add($label)

	$textBox = New-Object System.Windows.Forms.TextBox
	$textBox.Location = New-Object System.Drawing.Point(10,40)
	$textBox.Size = New-Object System.Drawing.Size(260,20)
	$form.Controls.Add($textBox)

	$form.Topmost = $true

	$form.Add_Shown({$textBox.Select()})
	$result = $form.ShowDialog()

	if ($result -eq [System.Windows.Forms.DialogResult]::OK)
	{
    	$x = $textBox.Text
	}
	return $x
}

Function Get-InputFolder($initialDirectory="")
{
     [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null

     $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
     $foldername.Description = "Select a folder with group policy object"
     $foldername.rootfolder = "MyComputer"
     $foldername.SelectedPath = $initialDirectory

     if($foldername.ShowDialog() -eq "OK")
     {
         $folder += $foldername.SelectedPath
     }
     return $folder
}

Function Get-OutputFolder($initialDirectory="")
{
     [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null

     $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
     $foldername.Description = "Select output folder for conversion output"
     $foldername.rootfolder = "MyComputer"
     $foldername.SelectedPath = $initialDirectory

     if($foldername.ShowDialog() -eq "OK")
     {
         $folder += $foldername.SelectedPath
     }
     return $folder
}

$inputpath = Get-InputFolder
$outputpath = Get-OutputFolder

Import-Module baselinemanagement
ConvertFrom-GPO -Path $inputpath -OutputPath $outputpath -OutputConfigurationScript -Verbose

$newscriptname = Get-PackageName
$oldname = $outputpath + '\DSCFromGPO.ps1'
$newname = $outputpath + '\' + $newscriptname + '.ps1'
Rename-Item -Path $oldname -NewName $newname
(Get-Content -Path $newname).Replace('PSDesiredStateConfiguration', 'PSDscResources') | Set-Content -Path $newname
