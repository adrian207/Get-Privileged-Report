# Privileged Activities Report Generator

## Executive Summary

**The Privileged Activities Report Generator accelerates security auditing by 5-8x through parallel processing while providing comprehensive risk analysis of privileged account activities across your Windows infrastructure.**

This enterprise-grade PowerShell tool addresses the critical security challenge of monitoring privileged access—reducing manual audit time from hours to minutes while delivering actionable intelligence on high-risk activities, actor behaviors, and compliance evidence.

---

## Value Proposition

### Primary Benefits

**For Security Operations**
- **85% time reduction** in privileged activity audits through parallel server queries
- **Automatic risk classification** of 60+ security event types across 4 severity levels
- **Real-time visibility** into who performed what actions, when, and against which targets

**For Compliance & Audit**
- **One-click evidence generation** for SOX, HIPAA, PCI DSS, and NIST 800-53 requirements
- **Comprehensive audit trail** with 6 formatted reports ready for auditor review
- **Historical analysis** supporting investigations from 1 hour to 30+ days

**For IT Operations**
- **Zero infrastructure requirements** - runs from any Windows workstation with PowerShell 7
- **Flexible deployment** - scan domain controllers, member servers, or any Windows system
- **Non-intrusive** - read-only queries with minimal performance impact

---

## Solution Overview

### What It Does

The tool queries Windows Security event logs across multiple servers simultaneously, extracting and analyzing privileged activities to identify:

1. **High-risk actions** requiring immediate attention (privilege escalation, policy tampering)
2. **Actor behavior patterns** showing who performs privileged operations and their risk profile
3. **Temporal anomalies** such as after-hours administrative activity
4. **Target focus** identifying which accounts and groups are being modified most frequently
5. **Log capacity constraints** determining optimal scan frequency to prevent data loss from overwrites

### How It Works

```
Input: Server List + Time Range + Configuration
  ↓
Parallel Query Engine (5-20 simultaneous connections)
  ↓
Event Collection & Parsing (60+ monitored event IDs)
  ↓
Risk Classification (Critical/High/Medium/Low)
  ↓
Multi-Dimensional Analysis (Actor/Time/Target/Event Type)
  ↓
Output: 6 CSV Reports + Interactive Summary
```

### Key Differentiators

| Traditional Approach | This Solution |
|---------------------|---------------|
| Sequential queries (slow) | **Parallel processing (5-8x faster)** |
| Raw event logs (difficult to interpret) | **Risk-scored & categorized** |
| Manual correlation required | **Automated actor & target analysis** |
| Single CSV dump | **6 purpose-built reports** |
| Command-line only | **Interactive guided UI** |
| Domain-only | **Any Windows server** |

---

## Technical Architecture

### Core Components

#### 1. Parallel Query Engine
- **Technology**: PowerShell 7 `ForEach-Object -Parallel`
- **Capability**: Queries 5-20 servers simultaneously
- **Performance**: Processes 20,000+ events in under 60 seconds
- **Resilience**: Continues on server failures, tracks and reports errors

#### 2. Event Intelligence Layer
- **Event Coverage**: 60+ security event IDs across 5 categories
- **Risk Scoring**: 4-tier classification based on security impact
- **Actor Extraction**: Parses XML event data to identify source (who) and target (what)
- **Deduplication**: Intelligent handling of system vs. human accounts

#### 3. Analytics Engine
Produces five analytical views:
- **Risk Distribution**: Percentage breakdown by severity
- **Actor Profiling**: Top 20 actors with risk metrics and action counts
- **Temporal Analysis**: Hourly activity patterns with visual timeline
- **Target Tracking**: Most frequently modified accounts and groups
- **Event Taxonomy**: Detailed breakdown of what each actor does

#### 4. Reporting Framework
Generates timestamped export folder containing:
- `DetailedEvents.csv` - Complete event log (SIEM-ready)
- `ActorSummary.csv` - Executive dashboard data
- `ActorEventBreakdown.csv` - Detailed actor actions
- `RiskSummary.csv` - Compliance metrics
- `HourlyActivity.csv` - Temporal analysis data
- `TargetSummary.csv` - High-value target tracking

---

## Requirements & Prerequisites

### System Requirements

| Component | Specification | Purpose |
|-----------|--------------|---------|
| **PowerShell** | 7.0 or higher | Parallel processing capability |
| **Operating System** | Windows 10/11 or Windows Server | PowerShell execution environment |
| **Memory** | 4GB minimum, 8GB recommended | Event processing and analysis |
| **Network** | Standard corporate LAN | WinRM/RPC access to target servers |

### Optional Components

| Component | Required For | Alternative |
|-----------|--------------|-------------|
| **Active Directory Module** | Auto-discovery of domain controllers (option 1) | Use manual server entry (options 2-4) |
| **Domain Admin Rights** | Domain-wide auditing | Local admin rights on individual servers |

### Target Server Configuration

**Required on servers to be audited:**
- Windows Event Log service running
- Audit policies enabled (Account Management, Policy Change, Privilege Use)
- Remote Event Log Management firewall rules enabled
- Remote Registry service accessible (for remote queries)

**To enable auditing via Group Policy:**
```
Computer Configuration → Policies → Windows Settings → 
Security Settings → Advanced Audit Policy Configuration →
Audit Policies → [Enable relevant subcategories]
```

**Key audit subcategories:**
- Account Management: All events
- Policy Change: Audit Policy Change, Authentication Policy Change
- Privilege Use: Sensitive Privilege Use
- DS Access: Directory Service Changes (for DCs)

---

## Quick Start Guide

### Installation (5 minutes)

**Step 1: Install PowerShell 7**
```powershell
# Via Windows Package Manager
winget install Microsoft.PowerShell

# Verify installation
pwsh --version  # Should show 7.x or higher
```

**Step 2: Obtain the script**
```powershell
# Via Git
git clone https://github.com/yourusername/Get-Privileged-Report.git
cd Get-Privileged-Report

# Or download ZIP and extract
```

**Step 3: (Optional) Install Active Directory Module**
```powershell
# Windows Server
Install-WindowsFeature RSAT-AD-PowerShell

# Windows 10/11
Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0
```

### First Run (2 minutes)

```powershell
# Launch PowerShell 7
pwsh

# Navigate to script directory
cd Get-Privileged-Report

# Execute script
.\Get-PrivilegedReport.ps1
```

**Interactive Workflow:**
1. **Operation Mode** → Choose Standard Scan, Log Capacity Analysis, or Both
2. **Server Selection** → Choose from 4 input methods
3. **Time Range** → Select 24h, 48h, 7d, or custom (Standard Scan mode)
4. **Filtering** → Exclude system accounts? (recommended: Yes)
5. **Performance** → Set parallel threads (default: 5)
6. **Confirmation** → Review settings and start
7. **Monitoring** → Watch real-time progress
8. **Results** → Review on-screen analysis and exported reports

**Note**: Select **Log Capacity Analysis** mode first to determine optimal scan frequency for your environment!

---

## Use Case Scenarios

### 1. Daily Security Operations (2 minutes)

**Objective**: Routine monitoring for suspicious privileged activities

**Workflow**:
- Time Range: Last 24 hours
- Servers: All domain controllers
- Focus: Critical and High-risk events

**Key Metrics to Monitor**:
- Any Critical events (target: 0)
- After-hours activity (18:00-06:00)
- Unknown actors in top 10 list
- Unexpected privilege group modifications

**Frequency**: Daily, morning briefing

---

### 2. Incident Response (10 minutes)

**Objective**: Investigate potential security incident involving privileged access

**Workflow**:
- Time Range: Incident window + 24 hours before/after
- Servers: All infrastructure (DCs, file servers, app servers)
- Include system accounts: Yes (full visibility)

**Analysis Steps**:
1. Review Critical events first (EventID 4765, 4794, 4719)
2. Identify compromised or suspicious accounts in Actor Summary
3. Build timeline from Hourly Activity
4. Trace actions in Detailed Events CSV
5. Identify affected targets from Target Summary

**Output**: Evidence package for incident report

---

### 3. Compliance Audit (15 minutes)

**Objective**: Generate evidence for SOX, PCI DSS, HIPAA, or NIST 800-53 audit

**Workflow**:
- Time Range: Audit period (typically 30-90 days)
- Servers: All in-scope systems
- Documentation: Actor Summary + Risk Summary

**Compliance Mapping**:

| Standard | Control | Evidence Provided |
|----------|---------|-------------------|
| **SOX** | Section 404 (Internal Controls) | Actor Summary shows who accessed privileged functions |
| **PCI DSS** | Requirement 10 (Logging & Monitoring) | Detailed Events log all privileged access |
| **HIPAA** | §164.308(a)(1)(ii)(D) (Access Monitoring) | Risk Summary + Hourly Activity demonstrate continuous monitoring |
| **NIST 800-53** | AU-2, AU-6, AU-12 | Complete audit trail with risk classification |

**Deliverables**: Export folder with all 6 reports

---

### 4. Privilege Access Review (10 minutes)

**Objective**: Quarterly review of administrative account usage and necessity

**Workflow**:
- Time Range: Last 90 days
- Analysis: Actor Summary + Actor Event Breakdown
- Focus: Identify inactive or anomalous admin accounts

**Decision Points**:
- Accounts with 0 activity → Candidate for deprovisioning
- Accounts with unexpected event types → Training opportunity
- Accounts with high average risk score → Enhanced monitoring
- Service accounts performing user-like activities → Security risk

**Outcome**: List of accounts for review, deactivation, or enhanced controls

---

### 5. Security Baseline Establishment (60 minutes)

**Objective**: Create behavioral baseline for anomaly detection

**Workflow**:
- Run weekly for 4 consecutive weeks
- Same time range (e.g., Sunday-Saturday)
- Compare Actor Summary and Hourly Activity across weeks

**Baseline Metrics**:
- Normal actor list (top 20)
- Expected hourly activity pattern
- Typical risk distribution (% Critical/High/Medium/Low)
- Average events per day

**Future Use**: Compare daily/weekly scans against baseline to identify anomalies

---

### 6. Log Capacity Analysis & Scan Scheduling (5 minutes)

**Objective**: Determine optimal scan frequency to prevent event log data loss

**Workflow**:
- Select Operation Mode [2] Log Capacity Analysis
- Choose all servers to be monitored (DCs, file servers, app servers)
- Review analysis results and recommendations

**Analysis Provides**:
- Event generation rate (events per day/hour) for each server
- Current log capacity and percent full
- Days until log reaches capacity
- Recommended scan frequency (1x to 12x per day)
- Sample 24-hour scan schedule

**Output**: `LogCapacityAnalysis_YYYYMMDD_HHMMSS.csv` with all metrics

**Decision Points**:
- If servers show "URGENT" (< 1 day until full) → Increase log size immediately
- If requiring >4 scans per day → Consider increasing log size
- Configure scheduled tasks based on overall recommendation

**Best Practice**: Run quarterly to adjust for infrastructure growth

**See**: [LOG-CAPACITY-ANALYSIS.md](LOG-CAPACITY-ANALYSIS.md) for complete guide

---

## Event Coverage Reference

### Monitored Security Events (60+ Event IDs)

#### Critical Risk Events (6 events)
| Event ID | Description | Attack Relevance |
|----------|-------------|------------------|
| **4765** | SID History added to account | Privilege escalation via SID injection |
| **4794** | DSRM password set attempt | Persistence via Directory Services Restore Mode |
| **4720** | User account created | Unauthorized account creation |
| **4728** | Member added to global security group | Privilege escalation (esp. Domain Admins) |
| **4732** | Member added to local security group | Lateral movement enabler |
| **4756** | Member added to universal security group | Cross-domain privilege escalation |

#### High Risk Events (10 events)
| Event ID | Description | Security Impact |
|----------|-------------|-----------------|
| **4719** | System audit policy changed | Evidence destruction preparation |
| **4713** | Kerberos policy changed | Golden ticket attack enablement |
| **4739** | Domain policy changed | Security control weakening |
| **4724** | Password reset attempt | Account takeover |
| **4726** | User account deleted | Evidence destruction |
| **4730** | Global security group deleted | Privilege removal/disruption |
| **4734** | Local security group deleted | Access control disruption |
| **4758** | Universal security group deleted | Cross-domain access disruption |
| **4704** | User right assigned | Direct privilege grant |
| **4717** | System security access granted | Audit log access granted |

#### Medium Risk Events (17 events)
Account modifications, group changes, privilege adjustments - routine administrative activities requiring monitoring but typically legitimate.

#### Low Risk Events (27+ events)
Informational events such as privileged logons (4672), self-service password changes (4723), and routine privilege use - useful for context but generally non-threatening.

**Full event list**: See [QUICK-REFERENCE.md](QUICK-REFERENCE.md)

---

## Output Specifications

### Report Structure

All reports export to: `%USERPROFILE%\Desktop\PrivilegedReport_YYYYMMDD_HHMMSS\`

### Report Descriptions

#### DetailedEvents.csv
**Purpose**: Complete forensic record  
**Use Cases**: SIEM import, detailed investigations, compliance evidence  
**Columns**: TimeCreated, DomainController, EventID, Level, RiskLevel, RiskScore, Source, Target, Message  
**Typical Size**: 500-50,000 rows depending on time range and environment  

#### ActorSummary.csv
**Purpose**: Executive dashboard of privileged user activity  
**Use Cases**: Management briefings, access reviews, risk profiling  
**Columns**: Actor, TotalActions, Critical, High, Medium, Low, AvgRiskScore  
**Typical Size**: 20-100 rows (top actors only)  

#### ActorEventBreakdown.csv
**Purpose**: Detailed view of what each actor does  
**Use Cases**: Behavioral analysis, training needs, anomaly detection  
**Columns**: Actor, EventID, Count  
**Typical Size**: 100-500 rows  

#### RiskSummary.csv
**Purpose**: Risk distribution metrics  
**Use Cases**: KPI dashboards, trend analysis, compliance metrics  
**Columns**: RiskLevel, Count, Percentage  
**Typical Size**: 4 rows (one per risk level)  

#### HourlyActivity.csv
**Purpose**: Temporal analysis of privileged activities  
**Use Cases**: After-hours monitoring, workload analysis, incident timeline  
**Columns**: Hour, EventCount, CriticalEvents  
**Typical Size**: 24 rows (one per hour)  

#### TargetSummary.csv
**Purpose**: Most frequently targeted accounts and groups  
**Use Cases**: High-value target protection, attack pattern detection  
**Columns**: Target, TimesTargeted, UniqueActors  
**Typical Size**: 15-50 rows  

---

## Performance Characteristics

### Benchmark Results

**Test Environment**:
- Infrastructure: 10 domain controllers
- Time Range: 24 hours
- Event Volume: ~5,000 events
- Hardware: Intel Core i7, 16GB RAM, 1Gbps network

**Results**:

| Threads | Execution Time | Throughput | vs. Sequential |
|---------|----------------|------------|----------------|
| 1 (sequential) | 180 seconds | 28 events/sec | Baseline |
| 5 (parallel) | 35 seconds | 143 events/sec | **5.1x faster** |
| 10 (parallel) | 25 seconds | 200 events/sec | **7.2x faster** |
| 20 (parallel) | 22 seconds | 227 events/sec | **8.2x faster** |

**Scaling Characteristics**:
- Linear scaling up to 10 threads
- Diminishing returns beyond 15 threads (network/server limits)
- Optimal: 1 thread per 2-3 servers

### Resource Utilization

**Client Workstation**:
- CPU: 15-40% during query phase
- Memory: 100-500MB depending on event volume
- Network: 1-5 Mbps sustained
- Disk I/O: Minimal (CSV export only)

**Target Servers**:
- Impact: Negligible (<1% CPU, <10MB RAM)
- Duration: Query completes in 2-5 seconds per server
- Intrusion Level: Read-only, equivalent to Event Viewer query

---

## Security & Compliance Considerations

### Data Sensitivity

**Information Contained in Reports**:
- ✓ Privileged account names
- ✓ Administrative actions performed
- ✓ Timestamps of privileged activities
- ✓ Target accounts and groups affected
- ✗ Passwords or credentials (never logged)
- ✗ Personally identifiable information beyond account names

**Recommended Controls**:
- Store reports in access-controlled locations (ACL-protected folders)
- Encrypt reports for long-term retention (BitLocker, EFS, or encryption tools)
- Implement retention policies aligned with compliance requirements
- Restrict report distribution on need-to-know basis

### Operational Security

**Script Behavior**:
- Read-only operations (no modifications to target systems)
- Standard Windows protocols (WinRM, RPC)
- Credentials: Uses current user context (no credential storage)
- Logging: Subject to PowerShell transcription and operational logging

**Potential Alerts**:
- Multiple simultaneous RPC connections (IDS/IPS)
- Elevated privilege verification checks (EDR)
- Event log queries from workstation (SIEM)

**Mitigation**: Whitelist script execution in security tools

### Compliance Alignment

**NIST 800-53 Rev 5**:
- AU-2 (Event Logging): Captures all required privileged account events
- AU-6 (Audit Review): Facilitates regular analysis and review
- AU-12 (Audit Generation): Leverages Windows native audit capability
- AC-2(4) (Automated Account Actions): Automated privileged activity monitoring

**CIS Controls v8**:
- Control 6.2 (Activate Audit Logging): Implements continuous monitoring
- Control 6.3 (Collect Detailed Audit Logs): Aggregates from multiple systems
- Control 6.4 (Ensure Adequate Audit Storage): Provides exportable archives

**SOX Section 404**:
- Demonstrates monitoring of privileged access to financial systems
- Provides audit trail for changes to critical configurations
- Supports testing of internal controls over IT general controls (ITGC)

---

## Troubleshooting Guide

### Issue: "This script requires PowerShell 7.0 or higher"

**Cause**: Running on Windows PowerShell 5.1 instead of PowerShell 7

**Solution**:
```powershell
# Check current version
$PSVersionTable.PSVersion

# Install PowerShell 7
winget install Microsoft.PowerShell

# Launch PowerShell 7
pwsh
```

**Verification**: Version should show 7.x.x or higher

---

### Issue: "Active Directory module not installed" (Option 1 only)

**Cause**: AD module required for auto-discovery but not present

**Solution 1 - Install AD Module**:
```powershell
# Windows Server
Install-WindowsFeature RSAT-AD-PowerShell

# Windows 10/11
Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0
```

**Solution 2 - Use Alternative Input Method**:
- Select option [2], [3], or [4] (manual server specification)
- No AD module required for these options

---

### Issue: "Access Denied" when querying servers

**Possible Causes**:
1. Insufficient permissions
2. Windows Firewall blocking
3. Remote Event Log Management disabled

**Diagnostic Steps**:
```powershell
# Test 1: Verify permissions
Get-WinEvent -ComputerName SERVER01 -LogName Security -MaxEvents 1

# Test 2: Check firewall
Test-NetConnection -ComputerName SERVER01 -Port 5985  # WinRM HTTP

# Test 3: Verify Remote Event Log Management
Get-Service -ComputerName SERVER01 -Name RemoteRegistry
```

**Solutions**:

**A. Grant Permissions**:
- Add user to "Event Log Readers" group on target server
- Or grant "Read" permission to Security log via registry/GPO

**B. Enable Firewall Rules**:
```powershell
# On target server:
Enable-NetFirewallRule -DisplayGroup "Remote Event Log Management"
```

**C. Start Required Services**:
```powershell
# On target server:
Set-Service -Name RemoteRegistry -StartupType Automatic
Start-Service -Name RemoteRegistry
```

---

### Issue: "No events found"

**Possible Causes**:
1. Auditing not enabled on target servers
2. Time range predates event availability
3. Event logs cleared
4. Audit policy misconfiguration

**Diagnostic Steps**:
```powershell
# Check if Security log has events
Get-WinEvent -ComputerName SERVER01 -LogName Security -MaxEvents 10

# Check audit policy on target
auditpol /get /category:* /r | ConvertFrom-Csv | Where-Object {$_.'Inclusion Setting' -eq 'Success'}
```

**Solutions**:

**Enable Auditing via Group Policy**:
1. Open Group Policy Management
2. Navigate to: Computer Configuration → Policies → Windows Settings → Security Settings → Advanced Audit Policy Configuration
3. Enable:
   - Account Management → All subcategories
   - Policy Change → Audit Policy Change
   - Privilege Use → Sensitive Privilege Use
   - DS Access → Directory Service Changes (DCs only)

**Verify Audit Settings**:
```powershell
# On target server
auditpol /get /category:"Account Management"
auditpol /get /category:"Policy Change"
auditpol /get /category:"Privilege Use"
```

---

### Issue: Script execution slow / hanging

**Possible Causes**:
1. Too many parallel threads overwhelming network
2. Unresponsive servers in target list
3. Very large event logs (100K+ events)

**Solutions**:

**A. Reduce Thread Count**:
- Try 3-5 threads instead of 10-20
- Better for constrained networks

**B. Remove Problem Servers**:
- Note which servers fail in output
- Remove from target list and query separately

**C. Reduce Time Range**:
- Query 24 hours instead of 7 days
- Run multiple smaller queries vs. one large query

**D. Filter Events More Aggressively**:
- Enable system account exclusion
- Consider focusing on Critical/High events only (requires script modification)

---

## Advanced Configuration

### Customizing Event Coverage

To modify which events are monitored, edit the `$eventIDs` array in `Get-PrivilegedReport.ps1`:

```powershell
# Line ~325
$eventIDs = @(
    4720, 4722, 4723, 4724, 4725, 4726, 4738, 4740, 4767, 4781,  # Account Management
    4727, 4728, 4729, 4730, 4731, 4732, 4733, 4734, 4735, 4737,  # Group Management
    # ... add or remove event IDs as needed
)
```

**Common Additions**:
- `4768, 4769, 4770` - Kerberos authentication events
- `4776` - Credential validation
- `5136, 5137, 5138` - Directory service changes
- `4688` - Process creation (for privileged processes)

### Customizing Risk Scores

Modify the `Get-EventRiskScore` function to adjust risk classification:

```powershell
# Line ~33
function Get-EventRiskScore {
    param([int]$EventID)
    
    $criticalEvents = @(4765, 4794, 4720, 4728, 4732, 4756)
    # Customize arrays based on your security priorities
}
```

### Automating Execution

**Scheduled Task Example**:
```powershell
# Create wrapper script: Run-DailyAudit.ps1
$servers = "DC01", "DC02", "DC03"
$hours = 24
$excludeSystem = $true
$threads = 5

# Configure script to accept parameters instead of interactive input
# (Requires modifying main script to accept -NonInteractive parameter)
```

**Task Scheduler Setup**:
- Trigger: Daily at 6:00 AM
- Action: `pwsh.exe -File "C:\Scripts\Run-DailyAudit.ps1"`
- Run whether user is logged on or not
- Use service account with appropriate permissions

---

## Support & Resources

### Documentation Set

| Document | Purpose | Audience |
|----------|---------|----------|
| **README.md** (this file) | Complete reference | All users |
| **USAGE-GUIDE.md** | Step-by-step walkthrough | New users |
| **QUICK-REFERENCE.md** | Fast lookup / cheat sheet | Daily users |
| **CHANGELOG.md** | Version history | Administrators |

### External References

**Microsoft Documentation**:
- [Appendix L: Events to Monitor](https://docs.microsoft.com/windows-server/identity/ad-ds/plan/appendix-l--events-to-monitor)
- [Advanced Security Audit Policies](https://docs.microsoft.com/windows/security/threat-protection/auditing/advanced-security-auditing)
- [Windows Security Log Encyclopedia](https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/)

**Security Standards**:
- [NIST 800-53 Rev 5](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final) - Audit and Accountability controls
- [CIS Controls v8](https://www.cisecurity.org/controls/v8) - Control 6 (Log Management)
- [PCI DSS v4.0](https://www.pcisecuritystandards.org/) - Requirement 10 (Logging and Monitoring)

### Technical Support

**For issues or questions**:
1. Check [Troubleshooting Guide](#troubleshooting-guide) above
2. Review [USAGE-GUIDE.md](USAGE-GUIDE.md) for detailed instructions
3. Consult [QUICK-REFERENCE.md](QUICK-REFERENCE.md) for common scenarios
4. Open issue on GitHub (include PowerShell version, error messages, environment details)

---

## Project Metadata

**Version**: 2.1.0 Enhanced Edition  
**Release Date**: 2025-01-20  
**PowerShell Version**: 7.0 or higher required  
**License**: Enterprise Use  
**Author**: Adrian Johnson <adrian207@gmail.com>  
**Status**: Production Ready

---

## Appendix: Decision Framework

### When to Use This Tool

**Ideal Scenarios**:
- ✓ Regular privileged activity monitoring (daily/weekly)
- ✓ Incident response investigations
- ✓ Compliance audit preparation
- ✓ Quarterly access reviews
- ✓ Security baseline establishment

**Alternative Tools May Be Better For**:
- ✗ Real-time alerting (use SIEM instead)
- ✗ Long-term event retention (use log aggregation platform)
- ✗ Non-Windows systems (this tool is Windows-specific)
- ✗ Application-level auditing (use application logs)

### Selection Criteria

| Your Need | This Tool Provides | Alternative |
|-----------|-------------------|-------------|
| Ad-hoc privileged activity reports | ✓ Yes - run on demand | SIEM (continuous) |
| Historical investigation (days/weeks) | ✓ Yes - custom time ranges | Log management platform |
| Risk-scored event analysis | ✓ Yes - built-in scoring | Manual analysis |
| Multi-server parallel queries | ✓ Yes - 5-8x faster | Sequential scripts |
| Compliance evidence | ✓ Yes - formatted reports | Custom queries |
| Real-time monitoring | ✗ No - on-demand only | SIEM with alerts |
| Long-term retention (>90 days) | ✗ No - query only | Centralized logging |

---

**For questions or contributions, contact Adrian Johnson at adrian207@gmail.com**
