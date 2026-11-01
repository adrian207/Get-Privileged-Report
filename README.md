# Get-Privileged-Report

An interactive PowerShell 7 script that collects privileged-activity events from Windows Security logs on domain controllers or other servers, scores each event by risk, and writes a set of CSV reports: who did what, to whom, when, and how risky it was. It can also estimate how quickly each server's Security log fills, so you know how often to run it.

## What it does

`Get-PrivilegedReport.ps1` asks a few questions, then queries the selected servers in parallel with `Get-WinEvent`.

**Events collected** (42 Security event IDs):

| Area | Event IDs |
|---|---|
| Account management | 4720, 4722, 4723, 4724, 4725, 4726, 4738, 4740, 4767, 4781 |
| Group management | 4727–4735, 4737, 4754–4758, 4764 |
| Policy changes | 4713, 4714, 4719, 4739 |
| Privilege use | 4672, 4673, 4674, 4704, 4705, 4717, 4718, 4964 |
| SID history and other | 4765, 4766, 4794, 4897 |

**Risk levels:**

- **Critical:** account created (4720), member added to a privileged group (4728, 4732, 4756), SID history added (4765), DSRM password set (4794)
- **High:** audit or domain policy changes, password resets, account and group deletions, user-right assignments
- **Medium:** other account and group changes
- **Low:** everything else in the list, such as special-privilege logons (4672)

For each event it records the time, server, event ID, risk level, the account that acted (`Subject`) and the account or group acted on (`Target`). It can skip activity by SYSTEM, LOCAL SERVICE, NETWORK SERVICE and anonymous logons.

**Operation modes:**

1. **Privileged activities scan:** the report below.
2. **Log capacity analysis:** for each server, Security log size, events in the last 24 hours, hours until the log is full, and a recommended number of scans per day.
3. **Both:** capacity analysis first, then the scan.

**Targets:** all domain controllers (found with `Get-ADDomainController`), names typed in, a text file with one server per line (see `servers-example.txt`), or a single server.

## Output

Reports are written to a timestamped folder on your desktop, `PrivilegedReport_<yyyyMMdd_HHmmss>`:

| File | Contents |
|---|---|
| `DetailedEvents.csv` | Every matching event |
| `ActorSummary.csv` | Top 20 accounts by activity, with counts per risk level and average risk score |
| `ActorEventBreakdown.csv` | Event IDs used by the top 10 accounts |
| `RiskSummary.csv` | Events per risk level |
| `HourlyActivity.csv` | Events and critical events per hour of the day |
| `TargetSummary.csv` | Top 15 accounts and groups acted on, with the number of distinct actors |

Capacity analysis writes `LogCapacityAnalysis_<timestamp>.csv` to the desktop.

## Requirements

- PowerShell 7.0 or later (the script uses `ForEach-Object -Parallel`), on Windows
- Read access to the Security log on each target: membership of **Event Log Readers** or local Administrators, and remote event log access allowed through the firewall (*Remote Event Log Management* rules)
- For automatic DC discovery: the ActiveDirectory module from RSAT (`Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0` on Windows 10/11)
- Auditing of account management, policy change and privilege use enabled on the targets, otherwise there is nothing to collect

## Quick start

```powershell
git clone https://github.com/adrian207/Get-Privileged-Report.git
cd Get-Privileged-Report
pwsh ./Get-PrivilegedReport.ps1
```

Choose a mode, the target servers, the time range (24 hours, 48 hours, 7 days or a custom number of hours), whether to exclude system accounts, and the number of parallel threads (default 5). Confirm, and the script reports progress per server and the folder it wrote.

## Repository layout

```
Get-PrivilegedReport.ps1     The script
servers-example.txt          Template for the server-list option
docs/
  USAGE-GUIDE.md             Walkthrough of every prompt
  QUICK-REFERENCE.md         Event IDs and risk levels on one page
  LOG-CAPACITY-ANALYSIS.md   How the capacity estimate is calculated
  EXECUTIVE-BRIEFING.md      Summary for non-technical readers
CHANGELOG.md
```

## Status and limitations

- **Fixed in this version:** earlier versions never collected events. PowerShell 7 rejected the way the query was passed to the parallel runspaces, and the single 42-ID query exceeds the limit some Windows versions accept. The query now runs in groups of 20 IDs. This was tested in PowerShell 7.4 with a stand-in for `Get-WinEvent`, not yet against a live domain controller; `docs/TEST-RESULTS.md` predates the fix.
- **Interactive only.** Every option is a prompt, so the script can't run from Task Scheduler as it stands.
- Capacity analysis reads the full last 24 hours of each Security log to count events, which can take a while on busy domain controllers.
- Risk levels come from a fixed list of event IDs. They are a starting point for review, not a detection rule set.

## License

MIT. See [LICENSE](LICENSE).

## Author

Adrian Johnson · [github.com/adrian207](https://github.com/adrian207)
