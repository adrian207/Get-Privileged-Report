# Log Capacity Analysis Feature Guide

## Overview

The **Log Capacity Analysis** feature helps you determine the optimal scan frequency for your environment by analyzing event log generation rates and capacity constraints across all your Windows servers.

### Problem It Solves

**Risk**: Security event logs can overwrite old events when they reach capacity, resulting in lost audit data and compliance gaps.

**Solution**: This feature analyzes your servers' event generation rates and log sizes to calculate exactly how often you need to run scans to capture all events without data loss.

---

## Key Capabilities

### 1. **Event Generation Rate Analysis**
- Measures actual events generated in last 24 hours
- Calculates events per hour for each server
- Projects forward based on current activity levels

### 2. **Capacity Planning**
- Analyzes current log size vs. maximum capacity
- Calculates time until log reaches full capacity
- Factors in overwrite mode (Circular, Archive, Retain)

### 3. **Smart Recommendations**
- Recommends scan frequency per server (1x to 12x per day)
- Provides overall recommendation based on most constrained server
- Includes 20% safety margin to prevent data loss
- Generates sample 24-hour scan schedule

### 4. **Risk Alerting**
- **CRITICAL** (Red): Server will reach capacity within 24 hours
- **WARNING** (Yellow): Server will reach capacity within 3 days
- **OK** (Green): Adequate capacity (>3 days)

---

## How to Use

### Access the Feature

When you run the script, you'll see:

```
Operation Mode
  [1] Privileged Activities Scan (Standard)
  [2] Log Capacity Analysis (Determine optimal scan frequency)
  [3] Both (Run capacity analysis, then perform scan)
```

**Select option [2] or [3]**

### Server Selection

Works with **any** of the 4 server input methods:
- ✓ All Domain Controllers (auto-discovery)
- ✓ Manual server entry (any Windows servers)
- ✓ Load from file (any Windows servers)
- ✓ Single server

**Recommendation**: Run analysis on all servers you plan to monitor (DCs, file servers, app servers, etc.)

---

## Sample Output

### Real-Time Feedback

```
[1/5] Analyzing: DC01.contoso.com
  Events/day: 45000 | Days until full: 2.3 | Recommended: 2x per day

[2/5] Analyzing: DC02.contoso.com
  Events/day: 12000 | Days until full: 8.5 | Recommended: 1x per day

[3/5] Analyzing: FS01.contoso.com
  Events/day: 3500 | Days until full: 28.0 | Recommended: 1x per day
```

### Summary Table

```
Server              MaxSizeMB CurrentSizeMB PercentFull OverwriteMode      EventsLast24h EventsPerHour HoursUntilFull DaysUntilFull RecommendedScansPerDay RecommendedInterval Status
------              --------- ------------- ----------- -------------      ------------- ------------- -------------- ------------- ---------------------- ------------------- ------
DC01.contoso.com    512.00    486.25        95.03       Overwrite          45000         1875          54.8           2.3           2                      12 hours            WARNING
DC02.contoso.com    512.00    298.75        58.35       Overwrite          12000         500           204.3          8.5           1                      24 hours            OK
FS01.contoso.com    256.00    42.50         16.60       Overwrite          3500          146           672.5          28.0          1                      24 hours            OK
```

### Recommendations

```
🟡 WARNING: 1 server(s) will reach capacity within 3 days
   • DC01.contoso.com: Scan every 12 hours

📊 OVERALL RECOMMENDATION
   To capture all events without data loss:
   • Scan frequency: 2x per day
   • Scan interval: Every 12 hours

   Sample 24-hour schedule:
      Scan 1: 00:00
      Scan 2: 12:00
```

---

## Understanding the Metrics

### Key Metrics Explained

| Metric | Description | What It Means |
|--------|-------------|---------------|
| **MaxSizeMB** | Maximum log capacity | Configured limit (usually 128MB-2048MB) |
| **CurrentSizeMB** | Current log size | How much space is used now |
| **PercentFull** | Percentage of capacity used | >90% = concerning, >95% = urgent |
| **OverwriteMode** | Log rollover behavior | Circular = overwrites old events |
| **EventsLast24h** | Events generated yesterday | Actual measured rate |
| **EventsPerHour** | Average hourly rate | EventsLast24h / 24 |
| **DaysUntilFull** | Time until capacity reached | At current generation rate |
| **RecommendedScansPerDay** | How often to scan | Ensures no data loss |
| **RecommendedInterval** | Time between scans | In hours |

### Overwrite Modes

**Circular (Most Common)**
- Overwrites oldest events when full
- **Risk**: Data loss if not scanned frequently enough
- **Action**: Follow recommended scan frequency strictly

**Archive When Full**
- Saves log and starts new one when full
- **Risk**: Lower, but archives must be processed
- **Action**: Follow recommendations but slightly less urgent

**Do Not Overwrite**
- Stops logging when full
- **Risk**: Log entries stop being recorded
- **Action**: Critical to follow recommendations

---

## Use Cases

### 1. Initial Deployment Planning

**Scenario**: Setting up monitoring for the first time

**Steps**:
1. Run capacity analysis on all target servers
2. Review overall recommendation
3. Configure scheduled task based on recommended interval
4. Re-run analysis monthly to adjust for growth

**Example**:
```
Result: Need to scan 3x per day (every 8 hours)
Action: Schedule tasks at 00:00, 08:00, 16:00
```

---

### 2. Compliance Audit Preparation

**Scenario**: Auditor asks "How do you ensure no event log data is lost?"

**Steps**:
1. Run capacity analysis
2. Export CSV report (includes all calculations)
3. Show recommendations were followed
4. Demonstrate scheduled task matches recommendations

**Deliverable**: `LogCapacityAnalysis_YYYYMMDD_HHMMSS.csv` as evidence

---

### 3. Incident Response - Data Loss Check

**Scenario**: Investigating incident but suspect events may have been overwritten

**Steps**:
1. Run capacity analysis immediately
2. Check "DaysUntilFull" - if <1 day, data loss likely occurred
3. Review when last scan ran
4. Calculate potential data loss window

**Decision**: Determines if you have complete incident timeline

---

### 4. Infrastructure Growth Planning

**Scenario**: Adding new servers or increased activity expected

**Steps**:
1. Run baseline capacity analysis
2. Add new servers or wait for activity increase
3. Re-run analysis after 1 week
4. Compare "EventsLast24h" - adjust scan frequency if needed

**Proactive**: Prevents data loss before it happens

---

### 5. Log Size Configuration Adjustment

**Scenario**: Deciding if log size should be increased

**Steps**:
1. Run capacity analysis
2. If requiring >4 scans per day, consider increasing log size
3. Double log size (e.g., 512MB → 1024MB) via GPO
4. Re-run analysis to verify improvement

**Rule of Thumb**: 1-2 scans per day is optimal, >4 suggests log too small

---

## Interpreting Results

### Healthy Environment

```
✓ All servers show "OK" status
✓ DaysUntilFull > 3 days for all servers
✓ Overall recommendation: 1-2 scans per day
```

**Action**: Configure daily or twice-daily scheduled scans

---

### Moderate Risk Environment

```
⚠ Some servers show "WARNING" status  
⚠ DaysUntilFull between 1-3 days
⚠ Overall recommendation: 2-4 scans per day
```

**Actions**:
1. Increase scan frequency immediately
2. Consider increasing log size for warning servers
3. Monitor for growth trends

---

### High Risk Environment

```
🔴 Servers show "URGENT" status
🔴 DaysUntilFull < 1 day
🔴 Overall recommendation: 6-12 scans per day
```

**Immediate Actions**:
1. **Run scan RIGHT NOW** to capture current data
2. **Increase log size** via GPO (double or triple)
3. **Configure frequent scans** (every 2-4 hours) until log size increased
4. **Investigate** why event generation is so high

---

## Calculations Explained

### How Recommendations Are Calculated

1. **Measure Current State**
   - Query last 24 hours of events
   - Count total events: `EventsLast24h`

2. **Calculate Capacity**
   - Remaining space: `MaxSize - CurrentSize`
   - Events until full: `RemainingSpace / AvgEventSize`

3. **Project Time to Full**
   - Hours until full: `EventsUntilFull / EventsPerHour`
   - Days until full: `HoursUntilFull / 24`

4. **Apply Safety Margin**
   - Safe hours: `HoursUntilFull × 0.8` (20% buffer)
   
5. **Determine Scan Frequency**
   ```
   If SafeHours > 24  → 1x per day (every 24 hours)
   If SafeHours > 12  → 2x per day (every 12 hours)
   If SafeHours > 8   → 3x per day (every 8 hours)
   If SafeHours > 6   → 4x per day (every 6 hours)
   If SafeHours > 4   → 6x per day (every 4 hours)
   If SafeHours ≤ 4   → 12x per day (every 2 hours)
   ```

6. **Overall Recommendation**
   - Takes the MAXIMUM frequency from all servers
   - Ensures even the most constrained server is covered

---

## Best Practices

### 1. Run Analysis Quarterly

**Why**: Event generation rates change over time
- User growth
- New applications
- Policy changes
- Seasonal activity (e.g., end-of-quarter)

**Action**: Re-run every 3 months and adjust schedule if needed

---

### 2. Include All Critical Servers

**Don't just analyze domain controllers!**

Also scan:
- ✓ File servers
- ✓ Application servers
- ✓ Database servers
- ✓ Exchange servers
- ✓ Web servers
- ✓ Jump boxes / bastion hosts

**Why**: Privileged activities occur on all infrastructure, not just DCs

---

### 3. Document Your Schedule

After analysis, create documentation:

```
Scan Schedule Documentation
Based on: Log Capacity Analysis run 2025-01-20
Recommendation: 2 scans per day (every 12 hours)

Schedule:
  - Scan 1: 00:00 (midnight)
  - Scan 2: 12:00 (noon)

Scheduled Task: "PrivilegedReport-Midnight" and "PrivilegedReport-Noon"
Next Review Date: 2025-04-20 (3 months)
```

---

### 4. Monitor for Failures

Even with perfect scheduling, scans can fail due to:
- Server downtime
- Network issues
- Credential expiration
- Disk space issues

**Action**: Set up scheduled task to email on failure

---

### 5. Increase Log Sizes Proactively

**If requiring >4 scans per day**: Increase log size instead

**Via Group Policy**:
```
Computer Configuration → 
Policies → 
Administrative Templates → 
Windows Components → 
Event Log Service → 
Security → 
Specify the maximum log file size

Change from: 512MB
Change to: 1024MB or 2048MB
```

**Benefits**:
- Reduces scan frequency needed
- Provides more buffer for failures
- Simplifies scheduling

---

## Troubleshooting

### Issue: "Failed to analyze server"

**Causes**:
- Access denied (permissions)
- Server offline
- Firewall blocking
- Event log service stopped

**Solution**:
Same as privileged scan - ensure Remote Event Log Management enabled

---

### Issue: Analysis shows 0 events per day

**Causes**:
- Auditing not configured
- Log was recently cleared
- Server newly deployed

**Solution**:
1. Enable auditing via GPO
2. Wait 24 hours for accurate measurement
3. Re-run analysis

---

### Issue: "Days until full" shows negative number

**Meaning**: Log is already in overwrite mode and losing data

**Immediate Actions**:
1. Run scan NOW to capture current data
2. Increase log size immediately
3. Configure frequent scans (every 2 hours)

---

### Issue: Recommendations differ per server

**Normal!** Different servers have different:
- Activity levels (DC vs file server)
- Log sizes
- Audit policies

**Action**: Follow the **overall recommendation** (maximum of all servers)

---

## Integration with Scheduled Scanning

### Automated Approach

Once you know the recommended frequency, configure scheduled tasks:

**Example: 2 scans per day (every 12 hours)**

**Task 1: Midnight Scan**
```powershell
Trigger: Daily at 00:00
Action: pwsh.exe -File "C:\Scripts\Get-PrivilegedReport.ps1"
# Configure script to accept non-interactive parameters
```

**Task 2: Noon Scan**
```powershell
Trigger: Daily at 12:00
Action: pwsh.exe -File "C:\Scripts\Get-PrivilegedReport.ps1"
```

### Report Naming

Reports are automatically timestamped:
```
PrivilegedReport_20250120_000030\  ← Midnight scan
PrivilegedReport_20250120_120015\  ← Noon scan
```

This ensures:
- ✓ No overwrites
- ✓ Complete daily coverage
- ✓ Easy chronological review

---

## ROI Calculation

### Without Capacity Analysis

**Risk**: Configure arbitrary schedule (e.g., daily)
- Log overwrites before scan → Data loss
- Compliance gap discovered during audit
- **Cost**: Audit finding, remediation effort, reputational damage

### With Capacity Analysis

**Benefit**: Data-driven schedule ensuring complete coverage
- Zero data loss
- Auditor confidence
- Provable due diligence

**Time Investment**: 2 minutes to run analysis quarterly  
**Risk Mitigation**: Complete audit trail integrity

---

## Frequently Asked Questions

**Q: How often should I run capacity analysis?**  
A: Quarterly, or after significant infrastructure changes (new servers, policy changes, major application deployments)

**Q: What if different servers have different recommendations?**  
A: Follow the MAXIMUM frequency. The overall recommendation accounts for the most constrained server.

**Q: Can I increase log size instead of scanning more frequently?**  
A: Yes! If requiring >4 scans per day, doubling log size is often more practical.

**Q: What if a server is offline during analysis?**  
A: It will show "ERROR" status. Re-run analysis when server is back online.

**Q: Does this work for non-Security logs?**  
A: Currently analyzes Security log only. Could be extended to Application/System logs if needed.

**Q: What's the 20% safety margin for?**  
A: Accounts for scan failures, increased activity, and processing delays. Ensures you don't cut it too close.

---

## Summary

**Log Capacity Analysis helps you**:
- ✅ Prevent data loss from log overwrites
- ✅ Configure optimal scan schedules
- ✅ Demonstrate due diligence to auditors
- ✅ Plan infrastructure capacity
- ✅ Detect abnormal event generation

**Run it**:
- ✅ Before deploying scheduled scanning
- ✅ Quarterly for all monitored servers
- ✅ After infrastructure changes
- ✅ When investigating potential data loss

**Follow the recommendations** to ensure complete audit trail integrity across your entire Windows infrastructure!

---

## Author

**Adrian Johnson**  
Email: adrian207@gmail.com  
Version: 2.1.0  
Last Updated: 2025-01-20

---

*For questions or issues, contact Adrian Johnson at adrian207@gmail.com or see the main README.md and USAGE-GUIDE.md*

