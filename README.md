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

- **New-LabUsers.ps1** — create the 5 Entra ID users and 3 groups in bulk
  (instead of clicking through the portal one by one)
- **Get-VMStatus.ps1** — list Azure VMs with their power state and size,
  so I can check what's running before I get charged
- **Test-AppInstalled.ps1** — detection script for Intune: checks whether
  an app (7-Zip or Chrome) is installed on a device

## Status

In progress — the scripts are being written as I reach each task in the
4-week plan. Each one will be added here with a short description and
usage notes.

## Why It Matters

Admins who can script don't click through the same task fifty times.
PowerShell is how you automate user creation, checks, and reporting in
a Microsoft environment.

## Next Steps

- Write the three scripts above as the labs call for them
- Test each one against the lab tenant and the Azure free account
