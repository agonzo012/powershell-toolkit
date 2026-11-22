# PowerShell Toolkit

## What This Is

A small collection of PowerShell scripts for IT automation, built while
practicing Azure and Microsoft 365 administration. Each script solves a
real admin task and is documented with what it does and how to run it.

## Tools Used

- PowerShell
- Microsoft Azure (Az module)
- Microsoft Graph (for Entra ID / M365 tasks)

## Scripts

- **New-LabUsers.ps1** — creates the 5 Entra ID users and 3 groups in bulk
  (instead of clicking through the portal one by one). Uses the Microsoft
  Graph SDK. Idempotent: skips any user or group that already exists.
  The 5 users (Alex Rivera, Priya Sharma, Marcus Webb, Sofia Chen,
  David Kim) and 3 groups (IT, Finance, Sales) match the Week 2 lab;
  they were first created by hand in the portal on Nov 21, 2026, and
  this script is the automated version of the same work.
  Run: `Connect-MgGraph -Scopes "User.ReadWrite.All","Group.ReadWrite.All","GroupMember.ReadWrite.All"` then `.\New-LabUsers.ps1`
  Outcome: written and idempotent; not yet run against the live tenant — the users and groups already exist, so it would skip them.
- **Get-VMStatus.ps1** — lists Azure VMs with their power state and size,
  so I can check what's running before I get charged. Uses the Az module.
  Run: `Connect-AzAccount` then `.\Get-VMStatus.ps1` (add
  `-ResourceGroupName "AlvinLab-RG"` for one resource group only).
  A VM showing "VM deallocated" costs nothing for compute.
  Outcome: written; not yet run — it only reads, so it is the safe one to try first.
- **Test-AppInstalled.ps1** — detection script for Intune: checks whether
  an app (7-Zip or Chrome) is installed on a device. Returns exit 0 when
  found, exit 1 when not. Checks the uninstall registry keys and the
  default install folders. Run: `.\Test-AppInstalled.ps1 -AppName "7-Zip"`
  or `.\Test-AppInstalled.ps1 -AppName "Google Chrome"`.
  Outcome: written; not yet used in an Intune deployment — app deployment is blocked until a .intunewin package is prepared.

## Status

Done — all three scripts are written (Nov 21, 2026). They have not been
run against the live tenant yet; New-LabUsers targets users and groups
that already exist, so it will skip them on a re-run.

## Why It Matters

Admins who can script don't click through the same task fifty times.
PowerShell is how you automate user creation, checks, and reporting in
a Microsoft environment.

## Next Steps

- Test each script against the lab tenant and the Azure free account
  (Get-VMStatus first, since it only reads; New-LabUsers will skip the
  users and groups that already exist)
