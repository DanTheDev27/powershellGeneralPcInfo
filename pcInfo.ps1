# Gather system info
function Get-PCInfo {
    # Get the username and computer name
    $userName = $env:USERNAME
    $deviceName = $env:COMPUTERNAME
    $userDomain = $env:USERDOMAIN
    $userLogOnServer = $env:LOGONSERVER
    
    # Get computer information
    $computerInfo = Get-ComputerInfo

    # Format the output for computer information
    $osName = $computerInfo.OsName
    $osVersion = $computerInfo.OSDisplayVersion
    $osInstallDate = $computerInfo.OsInstallDate
    $windowsInstallDate = $computerInfo.WindowsInstallDateFromRegistry
    $biosReleaseDate = $computerInfo.BiosReleaseDate
    $csProcessors = $computerInfo.CsProcessors
    $csUserName = $computerInfo.CsUserName
    $osLocalTime = $computerInfo.OsLocalDateTime
    $osUpTime = $computerInfo.OsLastBootUpTime
    $computerUpTime = $computerInfo.OsUpTime
    $osNumberOfUsers = $computerInfo.OsNumberOfUsers
    $osTimeZone = $computerInfo.TimeZone
    $allUsers = Get-LocalUser
    # Must run as admin for this command
    $getWiFiNetworks = netsh wlan show networks mode=bssid | Select-String "SSID"
    $getEthernetNetwork = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.InterfaceDescription -like '*Ethernet*' } | Select-Object Name
    $getEthernetDetailed = Get-NetIPConfiguration | Where-Object { $_.InterfaceAlias -like '*Ethernet*' }
    $printerInfo = Get-WmiObject -Class Win32_Printer | Select-Object Name, PortName
    $computerRamInfo = Get-WmiObject -Class Win32_PhysicalMemory | Select-Object Manufacturer, Capacity, Speed, PartNumber
    $ram = (computerInfo).TotalPhysicalMemory
    $ramInGB = $ramInGB = [math]::round($ram / 1GB, 2)





    # Extract processor info (e.g., the name of the processor)
    $processorInfo = $csProcessors | ForEach-Object { $_.Name }

    # Output all information
    Write-Output "Username: $userName"
    Write-Output "Device Name: $deviceName"
    Write-Output "User Domain: $userDomain"
    Write-Output "User Logon Server: $userLogOnServer"
    Write-Output "Operating System: $osName"
    Write-Output "Operating System Version: $osVersion"
    Write-Output "OS Install Date: $osInstallDate"
    Write-Output "Windows Install Date (from Registry): $windowsInstallDate"
    Write-Output "Last BIOS Update: $biosReleaseDate"
    Write-Output "Processor Info: $($processorInfo -join ', ')"  # Join processors with comma
    Write-Output "Cs Username: $csUserName"
    Write-Output "Computer Local Time: $osLocalTime"
    Write-Output "Computer Time Zone: $osTimeZone"
    Write-Output "Operating System Last Boot Up: $osUpTime"
    Write-Output "Computer Up Time: $computerUpTime"
    Write-Output "Number of users on computer: $osNumberOfUsers"
    Write-Output "Users: $allUsers"
    write-Output "WiFi Networks: $getWiFiNetworks"
    Write-Output $ram
}

# Call the function to see the output
Get-PCInfo
