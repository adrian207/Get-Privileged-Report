# 📘 Usage Guide - Privileged Activities Report Generator

**Author**: Adrian Johnson <adrian207@gmail.com>  
**Version**: 2.1.0

## Quick Start Guide

### 1️⃣ Launch the Script

Open PowerShell 7 and run:

```powershell
cd "C:\Path\To\Get-Privileged-Report"
.\Get-PrivilegedReport.ps1
```

You'll see a beautiful banner:

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║              PRIVILEGED ACTIVITIES REPORT GENERATOR                          ║
║                     Enhanced Edition v2.0                                    ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

---

## 2️⃣ Select Target Servers

You'll see a menu:

```
═══════════════════════════════════════════════════════════════════════════════
 Select Target Servers
═══════════════════════════════════════════════════════════════════════════════

  [1] All Domain Controllers (Automatic Discovery)
  [2] Enter Server Names Manually
  [3] Load Server List from File
  [4] Single Server

  [Q] Quit

Enter your choice:
```

### Option 1: All Domain Controllers (Recommended)
- Automatically discovers all DCs in your domain
- Best for comprehensive domain-wide audits
- Requires Active Directory PowerShell module

**Example:**
```
Enter your choice: 1
ℹ Discovering domain controllers...
✓ Found 5 domain controller(s)
```

### Option 2: Manual Entry
- Enter server names separated by commas
- Supports both FQDN and short names
- Good for ad-hoc queries

**Example:**
```
Enter your choice: 2
Enter server names (comma-separated): DC01, DC02, DC03
✓ Added 3 server(s)
```

### Option 3: Load from File
- Load servers from a text file
- One server per line
- Lines starting with `#` are ignored

**Example:**
```
Enter your choice: 3
Enter file path: C:\servers.txt
✓ Loaded 10 server(s) from file
```

**servers.txt example:**
```
DC01.contoso.com
DC02.contoso.com
FS01.contoso.com
# This is a comment
APP01.contoso.com
```

### Option 4: Single Server
- Focus on one specific server
- Fastest option for targeted investigations

**Example:**
```
Enter your choice: 4
Enter server name: DC01.contoso.com
```

---

## 3️⃣ Configure Scan Parameters

### Time Range Selection

```
Time range options:
  [1] Last 24 hours (default)
  [2] Last 48 hours
  [3] Last 7 days
  [4] Custom (hours)

Select time range [1]:
```

**Recommendations:**
- **Daily audits**: Use 24 hours (option 1)
- **Incident response**: Use 48 hours or 7 days (options 2-3)
- **Compliance reports**: Use custom range for monthly reviews

**Custom hours examples:**
- `1` = Last hour
- `72` = Last 3 days
- `168` = Last week
- `720` = Last 30 days

### System Accounts Filter

```
Exclude system accounts (SYSTEM, NETWORK SERVICE, etc.)? [Y/n]:
```

**Press Enter for Yes (recommended)** or type `n` for No

**When to exclude:**
- ✅ Focus on human actor activities
- ✅ Reduce noise from routine system operations
- ✅ Compliance reports (human actions only)

**When to include:**
- ✅ Investigating potential malware using SYSTEM context
- ✅ Complete forensic analysis
- ✅ Troubleshooting service account issues

### Parallel Threads

```
Number of parallel threads [5]:
```

**Press Enter for default (5)** or enter a number

**Thread count recommendations:**

| Scenario | Servers | Recommended Threads |
|----------|---------|---------------------|
| Small environment | 1-5 | 3-5 |
| Medium environment | 6-15 | 5-10 |
| Large environment | 16-50 | 10-15 |
| Very large | 50+ | 15-20 |

⚠️ **Warning**: Too many threads can:
- Overwhelm network bandwidth
- Trigger security alerts
- Overload target servers

---

## 4️⃣ Review & Confirm

Before starting, you'll see a summary:

```
═══════════════════════════════════════════════════════════════════════════════
 Scan Summary
═══════════════════════════════════════════════════════════════════════════════

  Target Servers:     5
  Time Range:         Last 24 hours
  Exclude System:     True
  Parallel Threads:   5

Ready to start scan? [Y/n]:
```

**Press Enter to start** or `n` to cancel

---

## 5️⃣ Watch the Scan

### Real-Time Progress

As the scan runs, you'll see live updates:

```
──────────────────────────────────────
 Starting Parallel Query
──────────────────────────────────────
ℹ Querying 5 server(s) with 5 parallel threads
ℹ Time range: 1/19/2025 3:00:00 PM to 1/20/2025 3:00:00 PM

[1/5] ✓ DC01.contoso.com: 234 events
[2/5] ✓ DC02.contoso.com: 187 events
[3/5] ✓ DC03.contoso.com: 312 events
[4/5] ✗ DC04.contoso.com: Access Denied
[5/5] ✓ DC05.contoso.com: 156 events

✓ Query completed: 889 total events collected
⚠ Failed to query 1 server(s): DC04.contoso.com
```

**Status indicators:**
- ✓ **Green checkmark** = Success
- ✗ **Red X** = Failed (check permissions/connectivity)
- **Gray numbers** = Progress counter

---

## 6️⃣ View Analysis Results

### 📊 Risk Level Distribution

```
──────────────────────────────────────
 Risk Level Distribution
──────────────────────────────────────

RiskLevel Count Percentage
--------- ----- ----------
Critical     12       1.35
High         89      10.01
Medium      423      47.58
Low         365      41.06
```

If critical events are found:
```
⚠ WARNING: 12 CRITICAL events detected!
```

### 👥 Top Actors by Activity

```
──────────────────────────────────────
 Top 20 Actors by Activity
──────────────────────────────────────

Actor                    Total Critical High Medium Low AvgRisk
-----                    ----- -------- ---- ------ --- -------
CONTOSO\admin.john         234        3   25    156  50    2.45
CONTOSO\ITAdmin            187        0   12     98  77    2.12
CONTOSO\ServiceDesk01      156        0    8     87  61    2.05
CONTOSO\BackupAdmin         98        0    5     45  48    1.98
...
```

**Columns explained:**
- **Total**: Total actions by this actor
- **Critical/High/Medium/Low**: Count by risk level
- **AvgRisk**: Average risk score (1-4)

### ⏰ Activity Timeline (by Hour)

```
──────────────────────────────────────
 Activity Timeline (by Hour)
──────────────────────────────────────

00:00 [  12] ████
01:00 [   5] ██
02:00 [   3] █
03:00 [   8] ███
...
09:00 [ 145] ████████████████████████████████████████
10:00 [ 132] ████████████████████████████████████
11:00 [  98] ███████████████████████████
...
```

**Colors:**
- 🟢 **Green bars** = Normal activity
- 🟡 **Yellow bars** = High activity (>70% of max)
- 🔴 **Red bars** = Contains critical events

### 🎯 Most Targeted Objects

```
──────────────────────────────────────
 Most Frequently Targeted Objects
──────────────────────────────────────

Target                       TimesTargeted UniqueActors
------                       ------------- ------------
CONTOSO\DomainAdmins                    45            8
CONTOSO\EnterpriseAdmins                23            5
CONTOSO\user.test                       18            3
CONTOSO\SQLServiceAcct                  15            2
...
```

**Watch for:**
- Privileged groups (Domain/Enterprise Admins)
- Service accounts
- Executive accounts
- Same target hit by multiple actors (potential attack)

### 📋 Event Type Breakdown

```
──────────────────────────────────────
 Event Breakdown by Top Actors
──────────────────────────────────────

   Actor: CONTOSO\admin.john

Actor                EventID Count
-----                ------- -----
CONTOSO\admin.john      4672    89
CONTOSO\admin.john      4738    45
CONTOSO\admin.john      4728    23
CONTOSO\admin.john      4720    15

   Actor: CONTOSO\ITAdmin
   
Actor                EventID Count
-----                ------- -----
CONTOSO\ITAdmin         4672    67
CONTOSO\ITAdmin         4724    34
...
```

**Common Event IDs:**
- **4672**: Special privileges assigned (admin logon)
- **4738**: User account changed
- **4728**: Member added to security group
- **4720**: User account created
- **4724**: Password reset

---

## 7️⃣ Reports Export

### Export Location

```
──────────────────────────────────────
 Exporting Reports
──────────────────────────────────────

✓ Reports exported successfully!

  📁 C:\Users\YourName\Desktop\PrivilegedReport_20250120_150000

  Files created:
    • DetailedEvents.csv
    • ActorSummary.csv
    • ActorEventBreakdown.csv
    • RiskSummary.csv
    • HourlyActivity.csv
    • TargetSummary.csv
```

### Report Files Explained

#### 1. **DetailedEvents.csv**
Complete event log with all details
```csv
TimeCreated,DomainController,EventID,Level,RiskLevel,RiskScore,Source,Target,Message
2025-01-20 14:23:15,DC01,4728,Information,Critical,4,CONTOSO\admin.john,CONTOSO\DomainAdmins,"A member was added to..."
```

**Use for:**
- Detailed forensic analysis
- Import to Excel for filtering
- SIEM integration
- Compliance documentation

#### 2. **ActorSummary.csv**
Actor statistics and risk profiles
```csv
Actor,Total,Critical,High,Medium,Low,AvgRisk
CONTOSO\admin.john,234,3,25,156,50,2.45
```

**Use for:**
- Identifying most active admins
- Risk profiling
- Access reviews
- Management reports

#### 3. **ActorEventBreakdown.csv**
Event types per actor
```csv
Actor,EventID,Count
CONTOSO\admin.john,4672,89
CONTOSO\admin.john,4738,45
```

**Use for:**
- Understanding what each admin does
- Identifying unusual patterns
- Training and optimization

#### 4. **RiskSummary.csv**
Risk level distribution
```csv
RiskLevel,Count,Percentage
Critical,12,1.35
High,89,10.01
```

**Use for:**
- Executive dashboards
- Trend analysis over time
- Risk metrics

#### 5. **HourlyActivity.csv**
Time-based activity patterns
```csv
Hour,Events,Critical
00:00,12,0
01:00,5,0
09:00,145,2
```

**Use for:**
- Detecting after-hours activity
- Workload analysis
- Anomaly detection

#### 6. **TargetSummary.csv**
Most targeted objects
```csv
Target,TimesTargeted,UniqueActors
CONTOSO\DomainAdmins,45,8
```

**Use for:**
- Protecting high-value targets
- Detecting focused attacks
- Access pattern analysis

---

## 📊 Working with Reports in Excel

### Import CSV Files

1. Open Excel
2. **Data** → **From Text/CSV**
3. Select report file
4. Click **Load**

### Recommended Analysis

#### Filter Critical Events
1. Open **DetailedEvents.csv**
2. Apply **AutoFilter** (Data → Filter)
3. Filter **RiskLevel** = "Critical"
4. Review all critical activities

#### Create Pivot Table for Actor Analysis
1. Open **DetailedEvents.csv**
2. Insert → PivotTable
3. Rows: **Source**
4. Values: **Count of EventID**
5. Filter: **RiskLevel** (select Critical, High)

#### Chart Hourly Activity
1. Open **HourlyActivity.csv**
2. Select **Hour** and **Events** columns
3. Insert → Charts → Column Chart
4. Identify peak activity hours

---

## 🔍 Common Scenarios & Recipes

### Scenario 1: Daily Security Check
```powershell
.\Get-PrivilegedReport.ps1
# Select: [1] All DCs
# Time: [1] 24 hours
# Exclude System: Y
# Threads: 5
# Review: Focus on Critical/High risk events
```

### Scenario 2: Incident Investigation
```powershell
.\Get-PrivilegedReport.ps1
# Select: [1] All DCs
# Time: [3] 7 days
# Exclude System: N (include all accounts)
# Threads: 10
# Review: Look for unusual patterns in timeline
```

### Scenario 3: Compliance Audit
```powershell
.\Get-PrivilegedReport.ps1
# Select: [1] All DCs
# Time: [4] Custom → 720 (30 days)
# Exclude System: Y
# Threads: 5
# Export: Use ActorSummary.csv for evidence
```

### Scenario 4: User Account Investigation
```powershell
.\Get-PrivilegedReport.ps1
# Select: [1] All DCs
# Time: [3] 7 days
# After export: Open DetailedEvents.csv
# Filter Source or Target by username
```

### Scenario 5: After-Hours Activity Check
```powershell
.\Get-PrivilegedReport.ps1
# Select: [1] All DCs
# Time: [1] 24 hours
# After export: Open HourlyActivity.csv
# Check 00:00-06:00 and 18:00-23:00 ranges
```

---

## ⚠️ Troubleshooting

### Problem: "This script requires PowerShell 7.0 or higher"

**Solution:**
```powershell
# Check current version
$PSVersionTable.PSVersion

# Install PowerShell 7
winget install Microsoft.PowerShell

# Launch PowerShell 7
pwsh
```

### Problem: "Active Directory module not found"

**Solution (Windows Server):**
```powershell
Install-WindowsFeature RSAT-AD-PowerShell
```

**Solution (Windows 10/11):**
```powershell
Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0
```

### Problem: "Access Denied" on some servers

**Check:**
1. Are you running as Domain Admin?
2. Is Windows Firewall blocking WinRM?
3. Is Remote Event Log Management enabled?

**Enable Remote Event Log Management:**
```powershell
# On target server:
Set-Service -Name "RemoteRegistry" -StartupType Automatic
Start-Service -Name "RemoteRegistry"

# Enable firewall rule:
Enable-NetFirewallRule -DisplayGroup "Remote Event Log Management"
```

### Problem: "No events found"

**Check:**
1. Is auditing enabled on target servers?
2. Has enough time passed for events to generate?
3. Are you querying the right time range?

**Enable auditing:**
```powershell
# Via Group Policy:
# Computer Configuration → Policies → Windows Settings → 
# Security Settings → Advanced Audit Policy Configuration
```

### Problem: Script is slow

**Optimize:**
1. Reduce time range (query fewer hours)
2. Increase parallel threads (if network allows)
3. Query fewer servers at once
4. Exclude system accounts (fewer events to process)

### Problem: Out of memory

**Solutions:**
1. Reduce time range
2. Query servers in batches
3. Exclude low-risk events
4. Increase system RAM

---

## 💡 Pro Tips

### 1. Schedule Regular Scans
Create a scheduled task:
```powershell
# Create script wrapper that auto-selects options
# Schedule daily at 6 AM
# Email reports to security team
```

### 2. Baseline Normal Activity
- Run weekly for a month
- Identify patterns (peak hours, common actors)
- Use as baseline for anomaly detection

### 3. Focus on High-Risk Events
- Filter `RiskLevel = Critical or High`
- Review these daily
- Investigate any unexpected actors

### 4. Monitor Privileged Groups
- Watch `TargetSummary.csv` for:
  - Domain Admins
  - Enterprise Admins
  - Schema Admins
  - Account Operators

### 5. Look for Anomalies
- Admin activity at 3 AM
- Unusual actor performing high-risk actions
- Spike in activity from single source
- Multiple actors targeting same account

### 6. Integrate with SIEM
- Export detailed events
- Import to Splunk/ELK/Sentinel
- Create automated alerts

---

## 📞 Getting Help

### Error Messages
The script provides clear error messages:
- ✓ **Green** = Success
- ℹ **Cyan** = Information
- ⚠ **Yellow** = Warning
- ✗ **Red** = Error

### Verbose Mode
For troubleshooting, run with verbose output:
```powershell
$VerbosePreference = "Continue"
.\Get-PrivilegedReport.ps1
```

---

**Happy Auditing! 🛡️**

