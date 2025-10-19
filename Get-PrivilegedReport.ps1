# ═══════════════════════════════════════════════════════════════════════════════
#  PowerShell Script: Privileged Activities Report Generator
#  Enhanced Edition with Parallel Processing & Interactive UI
#  
#  Author: Adrian Johnson <adrian207@gmail.com>
#  Version: 2.1.0
#  Last Updated: 2025-01-20
# ═══════════════════════════════════════════════════════════════════════════════
#
# Requirements:
# - PowerShell 7.0+ (for parallel processing)
# - Run as domain administrator or with sufficient privileges
# - Active Directory module (Install-Module ActiveDirectory)
# - Auditing enabled on domain controllers
#
# Features:
# ✓ Parallel processing for fast multi-server queries
# ✓ Interactive menu-driven UI
# ✓ Flexible server targeting (All DCs / Any Windows servers / Single server)
# ✓ Log capacity analysis - determines optimal scan frequency
# ✓ Source & target extraction from events
# ✓ Risk scoring (Critical, High, Medium, Low)
# ✓ Actor summary with action counts
# ✓ Time-based analysis (hourly activity)
# ✓ Event ID breakdown per actor
# ✓ System account filtering
# ✓ Timestamped reports for scheduled execution
# ✓ Comprehensive reporting suite (6 CSV + capacity analysis)
# ═══════════════════════════════════════════════════════════════════════════════

#Requires -Version 7.0

using namespace System.Collections.Generic

# ═══════════════════════════════════════════════════════════════════════════════
#  UTILITY FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

function Write-Header {
    param([string]$Title)
    $width = 80
    $padding = [math]::Max(0, ($width - $Title.Length - 2) / 2)
    Write-Host ""
    Write-Host ("═" * $width) -ForegroundColor Cyan
    Write-Host (" " * [math]::Floor($padding)) -NoNewline
    Write-Host $Title -ForegroundColor White -NoNewline
    Write-Host (" " * [math]::Ceiling($padding))
    Write-Host ("═" * $width) -ForegroundColor Cyan
    Write-Host ""
}

function Write-SubHeader {
    param([string]$Title)
    Write-Host ""
    Write-Host "──────────────────────────────────────" -ForegroundColor DarkCyan
    Write-Host " $Title" -ForegroundColor Yellow
    Write-Host "──────────────────────────────────────" -ForegroundColor DarkCyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ " -ForegroundColor Green -NoNewline
    Write-Host $Message
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ " -ForegroundColor Cyan -NoNewline
    Write-Host $Message
}

function Write-Warning2 {
    param([string]$Message)
    Write-Host "⚠ " -ForegroundColor Yellow -NoNewline
    Write-Host $Message -ForegroundColor Yellow
}

function Write-Error2 {
    param([string]$Message)
    Write-Host "✗ " -ForegroundColor Red -NoNewline
    Write-Host $Message -ForegroundColor Red
}

function Show-Menu {
    param(
        [string]$Title,
        [string[]]$Options
    )
    
    Write-Header $Title
    
    for ($i = 0; $i -lt $Options.Count; $i++) {
        $number = $i + 1
        Write-Host "  [$number] " -ForegroundColor Cyan -NoNewline
        Write-Host $Options[$i]
    }
    Write-Host ""
    Write-Host "  [Q] " -ForegroundColor Red -NoNewline
    Write-Host "Quit"
    Write-Host ""
}

# ═══════════════════════════════════════════════════════════════════════════════
#  CORE FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

function Get-EventRiskScore {
    param([int]$EventID)
    
    $criticalEvents = @(4765, 4794, 4720, 4728, 4732, 4756)
    $highRiskEvents = @(4719, 4713, 4739, 4724, 4726, 4730, 4734, 4758, 4704, 4717)
    $mediumRiskEvents = @(4722, 4725, 4738, 4727, 4731, 4754, 4729, 4733, 4757, 4735, 4737, 4755, 4764, 4705, 4718, 4781, 4767)
    
    if ($EventID -in $criticalEvents) { return @{ Score = 4; Level = "Critical" } }
    elseif ($EventID -in $highRiskEvents) { return @{ Score = 3; Level = "High" } }
    elseif ($EventID -in $mediumRiskEvents) { return @{ Score = 2; Level = "Medium" } }
    else { return @{ Score = 1; Level = "Low" } }
}

function Test-SystemAccount {
    param([string]$AccountName)
    
    $systemAccounts = @(
        'NT AUTHORITY\SYSTEM', 'NT AUTHORITY\LOCAL SERVICE',
        'NT AUTHORITY\NETWORK SERVICE', 'NT AUTHORITY\ANONYMOUS LOGON',
        'ANONYMOUS LOGON', 'LOCAL SERVICE', 'NETWORK SERVICE', 'SYSTEM'
    )
    
    foreach ($sysAccount in $systemAccounts) {
        if ($AccountName -like "*$sysAccount*") { return $true }
    }
    return $false
}

function Get-EventActors {
    param([System.Diagnostics.Eventing.Reader.EventLogRecord]$EventRecord)
    
    $source = "N/A"
    $target = "N/A"
    
    try {
        $eventXml = [xml]$EventRecord.ToXml()
        $eventData = $eventXml.Event.EventData.Data
        
        $props = @{}
        foreach ($data in $eventData) {
            if ($data.Name) {
                $props[$data.Name] = $data.'#text'
            }
        }
        
        # Extract source (actor)
        if ($props['SubjectUserName'] -and $props['SubjectUserName'] -ne '-' -and $props['SubjectUserName'] -notmatch '^[A-Z0-9-]{36}$') {
            if ($props['SubjectDomainName']) {
                $source = "$($props['SubjectDomainName'])\$($props['SubjectUserName'])"
            } else {
                $source = $props['SubjectUserName']
            }
        }
        
        # Extract target
        if ($props['TargetUserName'] -and $props['TargetUserName'] -ne '-') {
            if ($props['TargetDomainName']) {
                $target = "$($props['TargetDomainName'])\$($props['TargetUserName'])"
            } else {
                $target = $props['TargetUserName']
            }
        }
        elseif ($props['TargetSid']) { $target = $props['TargetSid'] }
        elseif ($props['MemberName']) { $target = $props['MemberName'] }
        elseif ($props['GroupName']) { $target = $props['GroupName'] }
        elseif ($props['SamAccountName']) { $target = $props['SamAccountName'] }
        
        if ($EventRecord.Id -eq 4723 -and $target -eq "N/A") {
            $target = $source
        }
    }
    catch {
        Write-Verbose "Failed to parse event $($EventRecord.Id): $_"
    }
    
    return @{ Source = $source; Target = $target }
}

# ═══════════════════════════════════════════════════════════════════════════════
#  SERVER SELECTION
# ═══════════════════════════════════════════════════════════════════════════════

function Get-TargetServers {
    Show-Menu -Title "Select Target Servers" -Options @(
        "All Domain Controllers (Automatic Discovery)"
        "Enter Server Names Manually"
        "Load Server List from File"
        "Single Server"
    ) | Out-Null
    
    Write-Host "Enter your choice: " -ForegroundColor Cyan -NoNewline
    $choice = Read-Host
    Write-Host ""
    
    switch ($choice) {
        '1' {
            Write-Info "Discovering domain controllers..."
            
            # Check if AD module is available
            if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
                Write-Error2 "Active Directory module not found"
                Write-Info "Install with: Install-WindowsFeature RSAT-AD-PowerShell"
                Write-Info "Or use option [2], [3], or [4] to manually specify servers"
                return $null
            }
            
            try {
                Import-Module ActiveDirectory -ErrorAction Stop
                $servers = Get-ADDomainController -Filter * -ErrorAction Stop | 
                    Select-Object -ExpandProperty HostName
                Write-Success "Found $($servers.Count) domain controller(s)"
                return $servers
            }
            catch {
                Write-Error2 "Failed to discover domain controllers: $_"
                Write-Info "Try using option [2], [3], or [4] to manually specify servers"
                return $null
            }
        }
        '2' {
            Write-Host "Enter server names (comma-separated): " -ForegroundColor Cyan -NoNewline
            $userInput = Read-Host
            $servers = $userInput -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }
            Write-Success "Added $($servers.Count) server(s)"
            return $servers
        }
        '3' {
            Write-Host "Enter file path: " -ForegroundColor Cyan -NoNewline
            $filePath = Read-Host
            if (Test-Path $filePath) {
                $servers = Get-Content $filePath | Where-Object { $_ -and $_ -notmatch '^\s*#' }
                Write-Success "Loaded $($servers.Count) server(s) from file"
                return $servers
            }
            else {
                Write-Error2 "File not found: $filePath"
                return $null
            }
        }
        '4' {
            Write-Host "Enter server name: " -ForegroundColor Cyan -NoNewline
            $server = Read-Host
            return @($server.Trim())
        }
        'Q' { return $null }
        default {
            Write-Error2 "Invalid choice"
            return $null
        }
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
#  CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

function Get-ScanConfiguration {
    Write-Header "Scan Configuration"
    
    # Time range
    Write-Host "Time range options:" -ForegroundColor Yellow
    Write-Host "  [1] Last 24 hours (default)"
    Write-Host "  [2] Last 48 hours"
    Write-Host "  [3] Last 7 days"
    Write-Host "  [4] Custom (hours)"
    Write-Host ""
    Write-Host "Select time range [1]: " -ForegroundColor Cyan -NoNewline
    $timeChoice = Read-Host
    if ([string]::IsNullOrWhiteSpace($timeChoice)) { $timeChoice = '1' }
    
    $hours = switch ($timeChoice) {
        '1' { 24 }
        '2' { 48 }
        '3' { 168 }
        '4' {
            Write-Host "Enter hours: " -ForegroundColor Cyan -NoNewline
            [int](Read-Host)
        }
        default { 24 }
    }
    
    Write-Host ""
    
    # System accounts
    Write-Host "Exclude system accounts (SYSTEM, NETWORK SERVICE, etc.)? [Y/n]: " -ForegroundColor Cyan -NoNewline
    $excludeChoice = Read-Host
    $excludeSystem = $excludeChoice -ne 'n' -and $excludeChoice -ne 'N'
    
    Write-Host ""
    
    # Parallel threads
    Write-Host "Number of parallel threads [5]: " -ForegroundColor Cyan -NoNewline
    $threadsInput = Read-Host
    $threads = if ([string]::IsNullOrWhiteSpace($threadsInput)) { 5 } else { [int]$threadsInput }
    
    Write-Host ""
    Write-Success "Configuration complete"
    Write-Host ""
    
    return @{
        Hours = $hours
        ExcludeSystemAccounts = $excludeSystem
        ParallelThreads = $threads
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
#  LOG CAPACITY ANALYSIS
# ═══════════════════════════════════════════════════════════════════════════════

function Invoke-LogCapacityAnalysis {
    param([string[]]$Servers)
    
    Write-Header "Log Capacity Analysis"
    Write-Info "Analyzing event log capacity and generation rates..."
    Write-Host ""
    
    $analysisResults = [List[PSCustomObject]]::new()
    $serverIndex = 0
    
    foreach ($server in $Servers) {
        $serverIndex++
        Write-Host "[$serverIndex/$($Servers.Count)] Analyzing: $server" -ForegroundColor Cyan
        
        try {
            # Get Security log properties
            $logInfo = Get-WinEvent -ComputerName $server -ListLog Security -ErrorAction Stop
            
            # Get event count for last 24 hours
            $yesterday = (Get-Date).AddHours(-24)
            $recentEvents = Get-WinEvent -ComputerName $server -FilterHashtable @{
                LogName = 'Security'
                StartTime = $yesterday
            } -ErrorAction Stop
            
            $eventsPerDay = $recentEvents.Count
            $eventsPerHour = [math]::Round($eventsPerDay / 24, 0)
            
            # Calculate log capacity metrics
            $maxSizeBytes = $logInfo.MaximumSizeInBytes
            $currentSizeBytes = $logInfo.FileSize
            $maxSizeMB = [math]::Round($maxSizeBytes / 1MB, 2)
            $currentSizeMB = [math]::Round($currentSizeBytes / 1MB, 2)
            $percentFull = [math]::Round(($currentSizeBytes / $maxSizeBytes) * 100, 2)
            
            # Estimate average event size (current size / current event count)
            $currentEventCount = (Get-WinEvent -ComputerName $server -LogName Security -MaxEvents 1 -ErrorAction SilentlyContinue).RecordId
            $avgEventSizeBytes = if ($currentEventCount -gt 0) { $currentSizeBytes / $currentEventCount } else { 2000 }
            
            # Calculate capacity metrics
            $remainingCapacityBytes = $maxSizeBytes - $currentSizeBytes
            $eventsUntilFull = [math]::Floor($remainingCapacityBytes / $avgEventSizeBytes)
            $hoursUntilFull = if ($eventsPerHour -gt 0) { [math]::Round($eventsUntilFull / $eventsPerHour, 1) } else { 999 }
            $daysUntilFull = [math]::Round($hoursUntilFull / 24, 1)
            
            # Calculate recommended scan frequency (with 20% safety margin)
            $safeHoursUntilFull = $hoursUntilFull * 0.8
            $recommendedScansPerDay = if ($safeHoursUntilFull -gt 24) { 1 } 
                                     elseif ($safeHoursUntilFull -gt 12) { 2 }
                                     elseif ($safeHoursUntilFull -gt 8) { 3 }
                                     elseif ($safeHoursUntilFull -gt 6) { 4 }
                                     elseif ($safeHoursUntilFull -gt 4) { 6 }
                                     else { 12 }
            
            $recommendedIntervalHours = [math]::Round(24 / $recommendedScansPerDay, 1)
            
            # Determine overwrite mode
            $overwriteMode = switch ($logInfo.LogMode) {
                'Circular' { 'Overwrite (Circular)' }
                'AutoBackup' { 'Archive when full' }
                'Retain' { 'Do not overwrite' }
                default { $logInfo.LogMode }
            }
            
            $analysisResults.Add([PSCustomObject]@{
                Server = $server
                MaxSizeMB = $maxSizeMB
                CurrentSizeMB = $currentSizeMB
                PercentFull = $percentFull
                OverwriteMode = $overwriteMode
                EventsLast24h = $eventsPerDay
                EventsPerHour = $eventsPerHour
                HoursUntilFull = $hoursUntilFull
                DaysUntilFull = $daysUntilFull
                RecommendedScansPerDay = $recommendedScansPerDay
                RecommendedInterval = "$recommendedIntervalHours hours"
                Status = if ($daysUntilFull -lt 1) { 'URGENT' } 
                        elseif ($daysUntilFull -lt 3) { 'WARNING' } 
                        else { 'OK' }
            })
            
            # Display immediate feedback
            $statusColor = if ($daysUntilFull -lt 1) { 'Red' } 
                          elseif ($daysUntilFull -lt 3) { 'Yellow' } 
                          else { 'Green' }
            Write-Host "  Events/day: $eventsPerDay | " -NoNewline
            Write-Host "Days until full: $daysUntilFull | " -NoNewline
            Write-Host "Recommended: ${recommendedScansPerDay}x per day" -ForegroundColor $statusColor
        }
        catch {
            Write-Warning "  Failed to analyze $server : $($_.Exception.Message)"
            $analysisResults.Add([PSCustomObject]@{
                Server = $server
                MaxSizeMB = 'N/A'
                CurrentSizeMB = 'N/A'
                PercentFull = 'N/A'
                OverwriteMode = 'N/A'
                EventsLast24h = 'N/A'
                EventsPerHour = 'N/A'
                HoursUntilFull = 'N/A'
                DaysUntilFull = 'N/A'
                RecommendedScansPerDay = 'N/A'
                RecommendedInterval = 'N/A'
                Status = 'ERROR'
            })
        }
    }
    
    # Display summary
    Write-Host ""
    Write-SubHeader "Capacity Analysis Summary"
    $analysisResults | Format-Table -AutoSize
    
    # Display recommendations
    Write-SubHeader "Scan Frequency Recommendations"
    
    $criticalServers = $analysisResults | Where-Object { $_.DaysUntilFull -ne 'N/A' -and $_.DaysUntilFull -lt 1 }
    $warningServers = $analysisResults | Where-Object { $_.DaysUntilFull -ne 'N/A' -and $_.DaysUntilFull -ge 1 -and $_.DaysUntilFull -lt 3 }
    
    if ($criticalServers.Count -gt 0) {
        Write-Host "🔴 CRITICAL: " -ForegroundColor Red -NoNewline
        Write-Host "$($criticalServers.Count) server(s) will reach capacity within 24 hours!"
        foreach ($server in $criticalServers) {
            Write-Host "   • $($server.Server): Scan every $($server.RecommendedInterval)" -ForegroundColor Red
        }
        Write-Host ""
    }
    
    if ($warningServers.Count -gt 0) {
        Write-Host "🟡 WARNING: " -ForegroundColor Yellow -NoNewline
        Write-Host "$($warningServers.Count) server(s) will reach capacity within 3 days"
        foreach ($server in $warningServers) {
            Write-Host "   • $($server.Server): Scan every $($server.RecommendedInterval)" -ForegroundColor Yellow
        }
        Write-Host ""
    }
    
    # Overall recommendation
    $maxScansNeeded = ($analysisResults | Where-Object { $_.RecommendedScansPerDay -ne 'N/A' } | 
                      Measure-Object -Property RecommendedScansPerDay -Maximum).Maximum
    
    if ($null -ne $maxScansNeeded) {
        Write-Host "📊 OVERALL RECOMMENDATION" -ForegroundColor Cyan
        Write-Host "   To capture all events without data loss:" -ForegroundColor White
        Write-Host "   • Scan frequency: " -NoNewline
        Write-Host "${maxScansNeeded}x per day" -ForegroundColor Green
        Write-Host "   • Scan interval: " -NoNewline
        $overallInterval = [math]::Round(24 / $maxScansNeeded, 1)
        Write-Host "Every $overallInterval hours" -ForegroundColor Green
        Write-Host ""
        
        # Generate sample schedule
        Write-Host "   Sample 24-hour schedule:" -ForegroundColor Gray
        for ($i = 0; $i -lt $maxScansNeeded; $i++) {
            $scanTime = [DateTime]::Today.AddHours($i * $overallInterval)
            Write-Host "      Scan $(($i + 1)): $($scanTime.ToString('HH:mm'))" -ForegroundColor Gray
        }
    }
    
    # Export analysis
    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $exportPath = "$env:USERPROFILE\Desktop\LogCapacityAnalysis_$timestamp.csv"
    $analysisResults | Export-Csv -Path $exportPath -NoTypeInformation
    
    Write-Host ""
    Write-Success "Analysis exported to: $exportPath"
    
    return $analysisResults
}

# ═══════════════════════════════════════════════════════════════════════════════
#  PARALLEL QUERY ENGINE
# ═══════════════════════════════════════════════════════════════════════════════

$eventIDs = @(
    4720, 4722, 4723, 4724, 4725, 4726, 4738, 4740, 4767, 4781,  # Account Management
    4727, 4728, 4729, 4730, 4731, 4732, 4733, 4734, 4735, 4737,  # Group Management
    4754, 4755, 4756, 4757, 4758, 4764,                          # Group Management (cont)
    4713, 4714, 4719, 4739,                                      # Policy Changes
    4672, 4673, 4674, 4704, 4705, 4717, 4718, 4964,             # Privilege Use
    4765, 4766, 4794, 4897                                       # SID History & Other
)

function Invoke-ParallelQuery {
    param(
        [string[]]$Servers,
        [hashtable]$Config
    )
    
    $startTime = (Get-Date).AddHours(-$Config.Hours)
    
    Write-SubHeader "Starting Parallel Query"
    Write-Info "Querying $($Servers.Count) server(s) with $($Config.ParallelThreads) parallel threads"
    Write-Info "Time range: $startTime to $(Get-Date)"
    Write-Host ""
    
    $scriptBlock = {
        param($server, $startTime, $eventIDs, $excludeSystem)
        
        # Import functions in parallel scope
        function Get-EventRiskScore {
            param([int]$EventID)
            $criticalEvents = @(4765, 4794, 4720, 4728, 4732, 4756)
            $highRiskEvents = @(4719, 4713, 4739, 4724, 4726, 4730, 4734, 4758, 4704, 4717)
            $mediumRiskEvents = @(4722, 4725, 4738, 4727, 4731, 4754, 4729, 4733, 4757, 4735, 4737, 4755, 4764, 4705, 4718, 4781, 4767)
            if ($EventID -in $criticalEvents) { return @{ Score = 4; Level = "Critical" } }
            elseif ($EventID -in $highRiskEvents) { return @{ Score = 3; Level = "High" } }
            elseif ($EventID -in $mediumRiskEvents) { return @{ Score = 2; Level = "Medium" } }
            else { return @{ Score = 1; Level = "Low" } }
        }
        
        function Test-SystemAccount {
            param([string]$AccountName)
            $systemAccounts = @('NT AUTHORITY\SYSTEM', 'NT AUTHORITY\LOCAL SERVICE', 'NT AUTHORITY\NETWORK SERVICE', 
                              'NT AUTHORITY\ANONYMOUS LOGON', 'ANONYMOUS LOGON', 'LOCAL SERVICE', 'NETWORK SERVICE', 'SYSTEM')
            foreach ($sysAccount in $systemAccounts) {
                if ($AccountName -like "*$sysAccount*") { return $true }
            }
            return $false
        }
        
        function Get-EventActors {
            param($EventRecord)
            $source = "N/A"
            $target = "N/A"
            try {
                $eventXml = [xml]$EventRecord.ToXml()
                $eventData = $eventXml.Event.EventData.Data
                $props = @{}
                foreach ($data in $eventData) {
                    if ($data.Name) { $props[$data.Name] = $data.'#text' }
                }
                if ($props['SubjectUserName'] -and $props['SubjectUserName'] -ne '-' -and $props['SubjectUserName'] -notmatch '^[A-Z0-9-]{36}$') {
                    if ($props['SubjectDomainName']) {
                        $source = "$($props['SubjectDomainName'])\$($props['SubjectUserName'])"
                    } else { $source = $props['SubjectUserName'] }
                }
                if ($props['TargetUserName'] -and $props['TargetUserName'] -ne '-') {
                    if ($props['TargetDomainName']) {
                        $target = "$($props['TargetDomainName'])\$($props['TargetUserName'])"
                    } else { $target = $props['TargetUserName'] }
                }
                elseif ($props['TargetSid']) { $target = $props['TargetSid'] }
                elseif ($props['MemberName']) { $target = $props['MemberName'] }
                elseif ($props['GroupName']) { $target = $props['GroupName'] }
                elseif ($props['SamAccountName']) { $target = $props['SamAccountName'] }
                if ($EventRecord.Id -eq 4723 -and $target -eq "N/A") { $target = $source }
            } catch {}
            return @{ Source = $source; Target = $target }
        }
        
        $result = @{
            Server = $server
            Events = @()
            Success = $false
            ErrorMessage = $null
            EventCount = 0
        }
        
        try {
            $events = Get-WinEvent -ComputerName $server -FilterHashtable @{
                LogName   = 'Security'
                StartTime = $startTime
                ID        = $eventIDs
            } -ErrorAction Stop
            
            foreach ($evt in $events) {
                $actors = Get-EventActors -EventRecord $evt
                
                if ($excludeSystem -and (Test-SystemAccount -AccountName $actors.Source)) {
                    continue
                }
                
                $riskInfo = Get-EventRiskScore -EventID $evt.Id
                $cleanMessage = $evt.Message -replace "`r`n", " " -replace "`t", " "
                
                $result.Events += [PSCustomObject]@{
                    TimeCreated      = $evt.TimeCreated
                    DomainController = $server
                    EventID          = $evt.Id
                    Level            = $evt.LevelDisplayName
                    RiskLevel        = $riskInfo.Level
                    RiskScore        = $riskInfo.Score
                    Source           = $actors.Source
                    Target           = $actors.Target
                    Message          = $cleanMessage
                }
            }
            
            $result.Success = $true
            $result.EventCount = $result.Events.Count
        }
        catch {
            if ($_.Exception.Message -match "No events were found") {
                $result.Success = $true
                $result.EventCount = 0
            }
            else {
                $result.ErrorMessage = $_.Exception.Message
            }
        }
        
        return $result
    }
    
    # Execute parallel queries with progress
    $collectedEvents = [List[PSCustomObject]]::new()
    $failedServers = [List[string]]::new()
    $completed = 0
    $total = $Servers.Count
    
    $results = $Servers | ForEach-Object -ThrottleLimit $Config.ParallelThreads -Parallel {
        $server = $_
        $sb = $using:scriptBlock
        $startTime = $using:startTime
        $eventIDs = $using:eventIDs
        $excludeSystem = $using:Config.ExcludeSystemAccounts
        
        & $sb -server $server -startTime $startTime -eventIDs $eventIDs -excludeSystem $excludeSystem
    }
    
    # Process results with visual feedback
    Write-Host ""
    foreach ($result in $results) {
        $completed++
        
        if ($result.Success) {
            Write-Host "[$completed/$total] " -ForegroundColor Gray -NoNewline
            Write-Host "✓" -ForegroundColor Green -NoNewline
            Write-Host " $($result.Server): " -NoNewline
            
            if ($result.EventCount -gt 0) {
                Write-Host "$($result.EventCount) events" -ForegroundColor Cyan
                foreach ($evt in $result.Events) {
                    $collectedEvents.Add($evt)
                }
            }
            else {
                Write-Host "0 events" -ForegroundColor DarkGray
            }
        }
        else {
            Write-Host "[$completed/$total] " -ForegroundColor Gray -NoNewline
            Write-Host "✗" -ForegroundColor Red -NoNewline
            Write-Host " $($result.Server): " -NoNewline
            Write-Host $result.ErrorMessage -ForegroundColor Red
            $failedServers.Add($result.Server)
        }
    }
    
    Write-Host ""
    Write-Success "Query completed: $($collectedEvents.Count) total events collected"
    
    if ($failedServers.Count -gt 0) {
        Write-Warning2 "Failed to query $($failedServers.Count) server(s): $($failedServers -join ', ')"
    }
    
    return @{
        Events = $collectedEvents
        FailedServers = $failedServers
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
#  REPORTING ENGINE
# ═══════════════════════════════════════════════════════════════════════════════

function New-ComprehensiveReport {
    param(
        [List[PSCustomObject]]$Events
    )
    
    if ($Events.Count -eq 0) {
        Write-Warning2 "No events found to analyze"
        return
    }
    
    # 1. Risk Level Summary
    Write-SubHeader "Risk Level Distribution"
    $riskSummary = $Events | 
        Group-Object -Property RiskLevel | 
        Select-Object @{Name='RiskLevel';Expression={$_.Name}}, 
                      @{Name='Count';Expression={$_.Count}},
                      @{Name='Percentage';Expression={[math]::Round(($_.Count / $Events.Count) * 100, 2)}} |
        Sort-Object @{Expression={
            switch ($_.RiskLevel) {
                'Critical' { 1 }
                'High' { 2 }
                'Medium' { 3 }
                'Low' { 4 }
            }
        }}
    
    $riskSummary | Format-Table -AutoSize
    
    $criticalEvents = $Events | Where-Object { $_.RiskLevel -eq "Critical" }
    if ($criticalEvents.Count -gt 0) {
        Write-Host "⚠ WARNING: " -ForegroundColor Red -NoNewline
        Write-Host "$($criticalEvents.Count) CRITICAL events detected!" -ForegroundColor Yellow
    }
    
    # 2. Top Actors
    Write-SubHeader "Top 20 Actors by Activity"
    $actorSummary = $Events | 
        Where-Object { $_.Source -ne "N/A" } |
        Group-Object -Property Source | 
        Select-Object @{Name='Actor';Expression={$_.Name}}, 
                      @{Name='Total';Expression={$_.Count}},
                      @{Name='Critical';Expression={($_.Group | Where-Object {$_.RiskLevel -eq 'Critical'}).Count}},
                      @{Name='High';Expression={($_.Group | Where-Object {$_.RiskLevel -eq 'High'}).Count}},
                      @{Name='Medium';Expression={($_.Group | Where-Object {$_.RiskLevel -eq 'Medium'}).Count}},
                      @{Name='Low';Expression={($_.Group | Where-Object {$_.RiskLevel -eq 'Low'}).Count}},
                      @{Name='AvgRisk';Expression={[math]::Round(($_.Group | Measure-Object -Property RiskScore -Average).Average, 2)}} |
        Sort-Object Total -Descending | 
        Select-Object -First 20
    
    $actorSummary | Format-Table -AutoSize
    
    # 3. Hourly Activity
    Write-SubHeader "Activity Timeline (by Hour)"
    $hourlyActivity = $Events | 
        Group-Object -Property @{Expression={$_.TimeCreated.Hour}} |
        Select-Object @{Name='Hour';Expression={"{0:D2}:00" -f [int]$_.Name}},
                      @{Name='Events';Expression={$_.Count}},
                      @{Name='Critical';Expression={($_.Group | Where-Object {$_.RiskLevel -eq 'Critical'}).Count}} |
        Sort-Object @{Expression={[int]($_.Hour -replace ':00','')}}
    
    $maxEvents = ($hourlyActivity | Measure-Object -Property Events -Maximum).Maximum
    foreach ($hour in $hourlyActivity) {
        $barLength = [math]::Round(($hour.Events / $maxEvents) * 40)
        $bar = "█" * $barLength
        $color = if ($hour.Critical -gt 0) { "Red" } elseif ($hour.Events -gt ($maxEvents * 0.7)) { "Yellow" } else { "Green" }
        Write-Host "$($hour.Hour) " -NoNewline -ForegroundColor Gray
        Write-Host "[" -NoNewline -ForegroundColor DarkGray
        Write-Host ("{0,4}" -f $hour.Events) -NoNewline -ForegroundColor White
        Write-Host "] " -NoNewline -ForegroundColor DarkGray
        Write-Host $bar -ForegroundColor $color
    }
    
    # 4. Most Targeted Objects
    Write-SubHeader "Top 15 Targeted Objects"
    $targetSummary = $Events | 
        Where-Object { $_.Target -ne "N/A" } |
        Group-Object -Property Target | 
        Select-Object @{Name='Target';Expression={$_.Name}}, 
                      @{Name='TimesTargeted';Expression={$_.Count}},
                      @{Name='UniqueActors';Expression={($_.Group | Select-Object -Property Source -Unique).Count}} |
        Sort-Object TimesTargeted -Descending |
        Select-Object -First 15
    
    $targetSummary | Format-Table -AutoSize
    
    # 5. Event Breakdown for Top 10 Actors
    Write-SubHeader "Event Type Breakdown (Top 10 Actors)"
    $topActors = $actorSummary | Select-Object -First 10
    $actorEventBreakdown = [List[PSCustomObject]]::new()
    
    foreach ($actor in $topActors) {
        $actorEvents = $Events | Where-Object { $_.Source -eq $actor.Actor }
        $eventGroups = $actorEvents | Group-Object -Property EventID | Sort-Object Count -Descending
        
        foreach ($eventGroup in $eventGroups) {
            $actorEventBreakdown.Add([PSCustomObject]@{
                Actor = $actor.Actor
                EventID = $eventGroup.Name
                Count = $eventGroup.Count
            })
        }
    }
    
    $actorEventBreakdown | Format-Table -AutoSize -GroupBy Actor
    
    # Export Reports
    Write-SubHeader "Exporting Reports"
    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $baseFolder = "$env:USERPROFILE\Desktop\PrivilegedReport_$timestamp"
    
    try {
        New-Item -Path $baseFolder -ItemType Directory -Force | Out-Null
        
        $Events | Export-Csv -Path "$baseFolder\DetailedEvents.csv" -NoTypeInformation
        $actorSummary | Export-Csv -Path "$baseFolder\ActorSummary.csv" -NoTypeInformation
        $actorEventBreakdown | Export-Csv -Path "$baseFolder\ActorEventBreakdown.csv" -NoTypeInformation
        $riskSummary | Export-Csv -Path "$baseFolder\RiskSummary.csv" -NoTypeInformation
        $hourlyActivity | Export-Csv -Path "$baseFolder\HourlyActivity.csv" -NoTypeInformation
        $targetSummary | Export-Csv -Path "$baseFolder\TargetSummary.csv" -NoTypeInformation
        
        Write-Host ""
        Write-Success "Reports exported successfully!"
        Write-Host ""
        Write-Host "  📁 $baseFolder" -ForegroundColor White
        Write-Host ""
        Write-Host "  Files created:" -ForegroundColor Gray
        Write-Host "    • DetailedEvents.csv" -ForegroundColor Cyan
        Write-Host "    • ActorSummary.csv" -ForegroundColor Cyan
        Write-Host "    • ActorEventBreakdown.csv" -ForegroundColor Cyan
        Write-Host "    • RiskSummary.csv" -ForegroundColor Cyan
        Write-Host "    • HourlyActivity.csv" -ForegroundColor Cyan
        Write-Host "    • TargetSummary.csv" -ForegroundColor Cyan
    }
    catch {
        Write-Error2 "Failed to export reports: $_"
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
#  MAIN PROGRAM
# ═══════════════════════════════════════════════════════════════════════════════

Clear-Host

# Banner
Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                                              ║" -ForegroundColor Cyan
Write-Host "║              " -NoNewline -ForegroundColor Cyan
Write-Host "PRIVILEGED ACTIVITIES REPORT GENERATOR" -NoNewline -ForegroundColor White
Write-Host "                      ║" -ForegroundColor Cyan
Write-Host "║                     " -NoNewline -ForegroundColor Cyan
Write-Host "Enhanced Edition v2.0" -NoNewline -ForegroundColor Yellow
Write-Host "                                ║" -ForegroundColor Cyan
Write-Host "║                                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Check PowerShell version
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Error2 "This script requires PowerShell 7.0 or higher for parallel processing"
    Write-Info "Current version: $($PSVersionTable.PSVersion)"
    Write-Info "Download PowerShell 7: https://aka.ms/powershell"
    exit 1
}

# Check if Active Directory module is available (optional, only needed for auto-discovery)
$adModuleAvailable = Get-Module -ListAvailable -Name ActiveDirectory
if ($adModuleAvailable) {
    Write-Success "Active Directory module available (for auto-discovery)"
} else {
    Write-Warning2 "Active Directory module not installed"
    Write-Info "Auto-discovery of DCs will not be available"
    Write-Info "You can still manually specify servers (options 2-4)"
}

Write-Host ""

# Step 1: Select Operation Mode
Write-Header "Operation Mode"
Write-Host "  [1] " -ForegroundColor Cyan -NoNewline
Write-Host "Privileged Activities Scan (Standard)"
Write-Host "  [2] " -ForegroundColor Cyan -NoNewline
Write-Host "Log Capacity Analysis (Determine optimal scan frequency)"
Write-Host "  [3] " -ForegroundColor Cyan -NoNewline
Write-Host "Both (Run capacity analysis, then perform scan)"
Write-Host ""
Write-Host "Enter your choice [1]: " -ForegroundColor Cyan -NoNewline
$modeChoice = Read-Host
if ([string]::IsNullOrWhiteSpace($modeChoice)) { $modeChoice = '1' }
Write-Host ""

# Step 2: Server Selection
$servers = Get-TargetServers
if ($null -eq $servers -or $servers.Count -eq 0) {
    Write-Error2 "No servers selected. Exiting."
    exit 1
}

Write-Host ""

# Step 3: Handle based on mode selection
switch ($modeChoice) {
    '2' {
        # Log Capacity Analysis Only
        $analysisResults = Invoke-LogCapacityAnalysis -Servers $servers
        
        Write-Host ""
        Write-Host ("═" * 80) -ForegroundColor Cyan
        Write-Host ""
        Write-Success "Log capacity analysis completed!"
        Write-Host ""
        Write-Info "Use the recommendations to configure your scan schedule"
        Write-Host ""
        Write-Host "Press any key to exit..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 0
    }
    '3' {
        # Both: Run capacity analysis first
        $analysisResults = Invoke-LogCapacityAnalysis -Servers $servers
        
        Write-Host ""
        Write-Host "Press any key to continue to privileged activities scan..." -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        Write-Host ""
        
        # Continue to configuration for regular scan
        $config = Get-ScanConfiguration
    }
    default {
        # Standard scan only
        $config = Get-ScanConfiguration
    }
}

# If we get here, we're doing a privileged activities scan (mode 1 or 3)
if ($modeChoice -eq '2') {
    # This shouldn't happen due to exit above, but safety check
    exit 0
}

# Step 4: Configuration (already set if mode 3, set now if mode 1)
if ($null -eq $config) {
    $config = Get-ScanConfiguration
}

# Step 5: Confirmation
Write-Header "Scan Summary"
Write-Host "  Target Servers:     " -NoNewline -ForegroundColor Gray
Write-Host $servers.Count -ForegroundColor White
Write-Host "  Time Range:         " -NoNewline -ForegroundColor Gray
Write-Host "Last $($config.Hours) hours" -ForegroundColor White
Write-Host "  Exclude System:     " -NoNewline -ForegroundColor Gray
Write-Host $config.ExcludeSystemAccounts -ForegroundColor White
Write-Host "  Parallel Threads:   " -NoNewline -ForegroundColor Gray
Write-Host $config.ParallelThreads -ForegroundColor White
Write-Host ""
Write-Host "Ready to start scan? [Y/n]: " -ForegroundColor Yellow -NoNewline
$confirm = Read-Host
if ($confirm -eq 'n' -or $confirm -eq 'N') {
    Write-Info "Scan cancelled"
    exit 0
}

# Step 6: Execute Scan
$queryResults = Invoke-ParallelQuery -Servers $servers -Config $config

# Step 7: Generate Reports
if ($queryResults.Events.Count -gt 0) {
    New-ComprehensiveReport -Events $queryResults.Events
}
else {
    Write-Warning2 "No events found in the specified time range"
}

Write-Host ""
Write-Host ("═" * 80) -ForegroundColor Cyan
Write-Host ""
Write-Success "Scan completed successfully!"
Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
