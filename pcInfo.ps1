# Gather system info
$userName = (Get-WmiObject -Class Win32_ComputerSystem).UserName
$deviceName = (Get-WmiObject -Class Win32_ComputerSystem).Name
$serialNumber = (Get-CimInstance -ClassName Win32_BIOS).SerialNumber
$uptime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
$uptimeDuration = New-TimeSpan -Start $uptime -End (Get-Date)
$biosDate = (Get-CimInstance -ClassName Win32_BIOS).ReleaseDate
$computerSystem = Get-WmiObject win32_ComputerSystem
$totalRAM_GB = [math]::Round($computerSystem.TotalPhysicalMemory / 1GB, 2)
$totalRAM_GBString = $totalRAM_GB.ToString()
# Get drive information using CIM for C: drive
$drive = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'"
# Get available wifi networks
$getAvailableWiFiNetworks = netsh wlan show networks
$GetAvailableWiFiNetworkDetailedInfo = netsh wlan show networks mode=bssid

# Get the total space and free space in gigabytes
$totalSpaceGB = [math]::Round($drive.Size / 1GB, 2)
$freeSpaceGB = [math]::Round($drive.FreeSpace / 1GB, 2)

# Calculate the free space percentage
$freeSpacePercent = ($freeSpaceGB / $totalSpaceGB) * 100

# Format the free space percentage to 2 decimal places
$formattedFreeSpacePercent = "{0:F2}" -f $freeSpacePercent

# Format the uptime duration to only include hours, minutes, and seconds
$formattedUptime = "{0:D2}:{1:D2}:{2:D2}" -f $uptimeDuration.Hours, $uptimeDuration.Minutes, $uptimeDuration.Seconds

$batteryStatus = Get-WmiObject -Class Win32_Battery | Select-Object Status, EstimatedChargeRemaining, BatteryStatus, Charging

# Step 1: Generate Battery Report and save it to a file
$reportPath = "$env:USERPROFILE\battery_report.html"
powercfg /batteryreport /output $reportPath

# Step 2: Read the HTML report content
$htmlContent = Get-Content -Path $reportPath -Raw

# Step 3: Remove any unwanted HTML tags to make parsing easier
# Strip out all HTML tags, leaving just the text content
$cleanedContent = $htmlContent -replace '<.*?>', ' '

# Step 4: Use regex to extract the relevant information
$fullChargeCapacity = if ($cleanedContent -match 'FULL CHARGE CAPACITY\s*([\d,]+)') { $matches[1] }
$designCapacity = if ($cleanedContent -match 'DESIGN CAPACITY\s*([\d,]+)') { $matches[1] }
$cycleCount = if ($cleanedContent -match 'Cycle Count\s*(\d+)') { $matches[1] }
$batteryStatus = if ($cleanedContent -match 'BATTERY STATUS\s*([\w\s]+)') { $matches[1] }
$batteryStateOfHealth = $fullChargeCapacity / $designCapacity *100
$formattedBatteryStateOfHealth = "{0:F2}" -f $batteryStateOfHealth
$reportTime = if ($cleanedContent -match 'REPORT TIME\s*([0-9]{4}-[0-9]{2}-[0-9]{2}\s+[0-9]{2}:[0-9]{2}:[0-9]{2})') { $matches[1] }
$getAllLocalUsers = Get-LocalUser

# Query Windows Update history using WMI
$updateHistory = Get-WmiObject -Class "Win32_QuickFixEngineering"

# Get the count of pending updates by checking the status of each update
$pendingUpdates = $updateHistory | Where-Object { $_.HotFixID -eq "Pending" }

# Count the number of pending updates
$pendingUpdatesCount = $pendingUpdates.Count

# Create arrays of PSObjects to represent the data in multiple rows

# System Information Row 1
$systemInfo1 = New-Object PSObject -property @{
    "Category"  = "System Information"
    "Detail"    = "User Name"
    "Value"     = $userName
}
$systemInfo2 = New-Object PSObject -property @{
    "Category"  = "System Information"
    "Detail"    = "Device Name"
    "Value"     = $deviceName
}
$systemInfo3 = New-Object PSObject -property @{
    "Category"  = "System Information"
    "Detail"    = "Serial Number"
    "Value"     = $serialNumber
}
$systemInfo4 = New-Object PSObject -property @{
    "Category"  = "System Information"
    "Detail"    = "Uptime Duration"
    "Value"     = $formattedUptime
}

# Battery Information Row 1
$batteryInfo1 = New-Object PSObject -property @{
    "Category"  = "Battery Information"
    "Detail"    = "Battery Status"
    "Value"     = $batteryStatus.Status
}
$batteryInfo2 = New-Object PSObject -property @{
    "Category"  = "Battery Information"
    "Detail"    = "Battery Charge (%)"
    "Value"     = $batteryStatus.EstimatedChargeRemaining
}
$batteryInfo3 = New-Object PSObject -property @{
    "Category"  = "Battery Information"
    "Detail"    = "Battery Charging"
    "Value"     = $batteryStatus.Charging
}

# Battery Health Information Row 1
$batteryHealth1 = New-Object PSObject -property @{
    "Category"  = "Battery Health"
    "Detail"    = "Full Charge Capacity"
    "Value"     = $fullChargeCapacity + " mWh"
}
$batteryHealth2 = New-Object PSObject -property @{
    "Category"  = "Battery Health"
    "Detail"    = "Design Capacity"
    "Value"     = $designCapacity + " mWh"
}
$batteryHealth3 = New-Object PSObject -property @{
    "Category"  = "Battery Health"
    "Detail"    = "Battery State of Health"
    "Value"     = $formattedBatteryStateOfHealth + "%"
}

$batteryHealth4 = New-Object PSObject -property @{
    "Category" = "Battery Health"
    "Detail"   = "Battery Cycle Count"
    "Value"    =$cycleCount
}

# Report Time Row
$reportTimeInfo = New-Object PSObject -property @{
    "Category"  = "Battery Health"
    "Detail"    = "Report Time"
    "Value"     = $reportTime
}

# Pending Updates Row
$pendingUpdatesInfo = New-Object PSObject -property @{
    "Category"  = "Updates"
    "Detail"    = "Pending Windows Updates Count"
    "Value"     = $pendingUpdatesCount
}

# Total Ram GB
$totalAvailableRam = New-Object PSObject -property @{
    "Category"  = "RAM"
    "Detail"    = "Total RAM"
    "Value"     = $totalRAM_GBString + " GB"
}

# C drive free space
$freeCDriveSpace = New-Object PSObject -property @{
    "Category"  = "Hard Drive"
    "Detail"    = "C: Usage Percent"
    "Value"     = $formattedFreeSpacePercent + "%"
}

# BIOS release date
$biosReleaseDate = New-Object PSObject -property @{
    "Category"  = "BIOS Age"
    "Detail"    = "Approx pc age"
    "Value"     = $biosDate
}

# All Local users
$allUsersLocally = New-Object PSObject -property @{
    "Category"   = "All Local Users"
    "Detail"     = "All Local Users"
    "Value"      = $getAllLocalUsers
}

# Combine all rows into an array
$allInfo = @(
    $systemInfo1, $systemInfo2, $systemInfo3, $systemInfo4,
    $batteryHealth1, $batteryHealth2, $batteryHealth3, $batteryHealth4,
    $reportTimeInfo, $totalAvailableRam,  $freeCDriveSpace, $biosReleaseDate, $allUsersLocally
)

# Output the information in a table format
$allInfo | Format-Table -Property "Category", "Detail", "Value" -AutoSize
