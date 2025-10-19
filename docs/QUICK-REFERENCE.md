# ⚡ Quick Reference Card

## 🚀 One-Line Launch
```powershell
pwsh -File Get-PrivilegedReport.ps1
```

---

## 📊 Menu Options Quick Guide

### Server Selection
| Option | Description | Use When |
|--------|-------------|----------|
| **1** | All Domain Controllers | Domain-wide audit |
| **2** | Manual Entry | Specific servers |
| **3** | Load from File | Many servers / repeated runs |
| **4** | Single Server | Focused investigation |

### Time Ranges
| Option | Range | Best For |
|--------|-------|----------|
| **1** | 24 hours | Daily checks |
| **2** | 48 hours | Recent incidents |
| **3** | 7 days | Weekly reviews |
| **4** | Custom | Compliance / Deep dives |

### Parallel Threads
| Servers | Threads | Estimated Time |
|---------|---------|----------------|
| 1-5 | 3-5 | 10-20 sec |
| 6-15 | 5-10 | 15-30 sec |
| 16-50 | 10-15 | 20-45 sec |
| 50+ | 15-20 | 30-60 sec |

---

## 📁 Output Files Cheat Sheet

| File | Purpose | Primary Use |
|------|---------|-------------|
| **DetailedEvents.csv** | All events, full details | Forensics, SIEM import |
| **ActorSummary.csv** | Top actors with risk scores | Management reports |
| **ActorEventBreakdown.csv** | What each actor does | Pattern analysis |
| **RiskSummary.csv** | Risk distribution | Dashboards |
| **HourlyActivity.csv** | Time-based patterns | Anomaly detection |
| **TargetSummary.csv** | Most hit objects | Attack detection |

---

## 🔴 Critical Event IDs to Watch

| Event ID | Description | Why Critical |
|----------|-------------|--------------|
| **4765** | SID History added | Privilege escalation attack |
| **4794** | DSRM password attempt | Backdoor creation |
| **4720** | User created | New account, verify legitimate |
| **4728** | Member added to global group | Privilege granted |
| **4732** | Member added to local group | Privilege granted |
| **4756** | Member added to universal group | Privilege granted |

---

## 🟠 High-Risk Event IDs

| Event ID | Description | Risk |
|----------|-------------|------|
| **4719** | Audit policy changed | Evidence tampering |
| **4713** | Kerberos policy changed | Golden ticket attack |
| **4739** | Domain policy changed | Security weakening |
| **4724** | Admin password reset | Unauthorized access |
| **4726** | User deleted | Data loss risk |
| **4704** | User right assigned | Privilege escalation |

---

## 🔍 Red Flags Checklist

### Activity Timing
- [ ] Admin actions between 10 PM - 6 AM
- [ ] Weekend/holiday activity
- [ ] Activity outside business hours

### Actor Behavior
- [ ] New/unknown actors performing privileged operations
- [ ] Service accounts doing user-like activities
- [ ] Excessive actions from single actor
- [ ] Multiple failures followed by success

### Target Patterns
- [ ] Multiple actors targeting same account
- [ ] Privileged groups modified (Domain/Enterprise Admins)
- [ ] Service accounts being modified
- [ ] Executive/VIP accounts targeted

### Risk Indicators
- [ ] Critical risk events > 0
- [ ] SID History modifications
- [ ] DSRM password attempts
- [ ] Audit policy changes
- [ ] Unexpected account creations

---

## 🛠️ Common Command Sequences

### Daily Security Check (2 minutes)
```
1. Launch script
2. Select: [1] All DCs
3. Time: [1] 24 hours
4. Exclude System: Y
5. Threads: 5
6. Review Critical/High events
```

### Weekly Compliance Report (5 minutes)
```
1. Launch script
2. Select: [1] All DCs  
3. Time: [3] 7 days
4. Exclude System: Y
5. Threads: 5
6. Export ActorSummary for management
```

### Incident Investigation (10 minutes)
```
1. Launch script
2. Select: [1] All DCs
3. Time: [4] Custom (72-168 hours)
4. Exclude System: N
5. Threads: 10
6. Deep dive into DetailedEvents.csv
```

### Specific User Audit (3 minutes)
```
1. Launch script
2. Select: [4] Single Server (user's DC)
3. Time: [3] 7 days
4. Exclude System: Y
5. After export: Filter by username in Excel
```

---

## 📊 Excel Quick Analysis

### Find All Actions by User
```
1. Open DetailedEvents.csv
2. Data → Filter
3. Filter "Source" column by username
```

### Create Actor Activity Chart
```
1. Open ActorSummary.csv
2. Select Actor + Total columns
3. Insert → Column Chart
```

### Identify After-Hours Activity
```
1. Open HourlyActivity.csv
2. Filter Hour: 00:00 - 06:00, 18:00 - 23:00
3. Check Events column for activity
```

### Critical Events Only
```
1. Open DetailedEvents.csv
2. Data → Filter  
3. RiskLevel = "Critical"
4. Review all rows
```

---

## 🔧 Troubleshooting Quick Fixes

| Problem | Quick Fix |
|---------|-----------|
| Need PowerShell 7 | `winget install Microsoft.PowerShell` |
| Missing AD Module | `Install-WindowsFeature RSAT-AD-PowerShell` |
| Access Denied | Run as Domain Admin |
| No events found | Check auditing enabled on targets |
| Script slow | Reduce time range or increase threads |
| Out of memory | Query fewer hours or servers |

---

## 🎯 Investigation Workflows

### Unknown Account Created
```
1. Find EventID 4720 in DetailedEvents.csv
2. Check Source (who created it)
3. Check Target (new account name)
4. Verify with Source actor if legitimate
5. Check subsequent actions by new account
```

### Privileged Group Modified
```
1. Find EventID 4728, 4732, or 4756
2. Check Source (who made change)
3. Check Target (who was added)
4. Verify change request ticket exists
5. Review Target's subsequent activities
```

### After-Hours Admin Activity
```
1. Open HourlyActivity.csv
2. Identify unusual hours
3. Open DetailedEvents.csv
4. Filter by those time ranges
5. Review Source actors and their actions
6. Verify legitimate (maintenance, incident response)
```

### Password Reset Spike
```
1. Find EventID 4724 in DetailedEvents.csv
2. Count by Source (who reset passwords)
3. Count by Target (whose passwords reset)
4. Check for automation vs manual
5. Verify help desk tickets
```

---

## 📈 Metrics to Track Over Time

### Security Posture
- Total Critical events per week
- Unique actors performing privileged actions
- After-hours activity percentage
- Failed vs successful privilege operations

### User Behavior
- Actions per actor (identify power users)
- Average risk score per actor
- Event diversity (specialist vs generalist)

### System Health
- Audit coverage (% of servers reporting)
- Event volume trends
- Response time to incidents

---

## 💾 File Management

### Recommended Retention
- **Daily reports**: 30 days
- **Weekly reports**: 90 days  
- **Monthly reports**: 1 year
- **Incident reports**: 7 years (compliance)

### Storage Locations
```
🏠 Daily:    .\Reports\Daily\
📅 Weekly:   .\Reports\Weekly\
📊 Monthly:  .\Reports\Monthly\
🚨 Incidents: .\Reports\Incidents\
```

---

## 🔐 Security Best Practices

### Running the Script
- [ ] Run from secure admin workstation
- [ ] Use dedicated admin account
- [ ] Enable PowerShell logging
- [ ] Review output before exporting

### Handling Reports
- [ ] Store in access-controlled location
- [ ] Encrypt for long-term storage
- [ ] Shred/delete after retention period
- [ ] Limit distribution (need-to-know)

### Regular Actions
- [ ] Daily: Check Critical events
- [ ] Weekly: Review top actors
- [ ] Monthly: Trend analysis
- [ ] Quarterly: Update event ID list

---

## 🆘 Emergency Response

### Suspected Breach
```bash
# Immediate actions
1. Run script with custom time range to incident window
2. Include system accounts (don't exclude)
3. Export all data immediately
4. Secure reports (evidence)
5. Focus on:
   - EventID 4765 (SID History)
   - EventID 4794 (DSRM)
   - EventID 4719 (Audit policy)
   - Unusual actors
   - After-hours activity
```

### Account Compromise
```bash
# Trace account activity
1. Run full domain scan (all DCs)
2. Export DetailedEvents.csv
3. Filter by compromised account (Source + Target)
4. Build timeline of all actions
5. Identify affected resources
6. Generate impact report
```

---

## 📞 Support Resources

### Script Requirements
- PowerShell: https://aka.ms/powershell
- AD Module: Built into RSAT tools

### Event ID References
- Microsoft Appendix L: https://docs.microsoft.com/appendix-l
- Ultimate Windows Security: https://www.ultimatewindowssecurity.com/

### Security Standards
- NIST 800-53: AU Controls
- CIS Controls: Control 6 (Logging)
- PCI DSS: Requirement 10

---

**Print this card for quick reference! 🖨️**

*Author: Adrian Johnson <adrian207@gmail.com>*  
*Last updated: 2025-01-20*  
*Version: 2.1.0*

