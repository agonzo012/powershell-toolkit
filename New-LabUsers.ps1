# New-LabUsers.ps1
# Creates the 5 Entra ID test users and 3 Security groups for the Azure portfolio lab,
# then assigns each user to their department group.
# Built for the Week 2 lab (users and groups were first created by hand in the portal
# on Nov 21, 2026; this script is the bulk/automated version of the same work).
#
# Requires: Microsoft Graph PowerShell SDK (Install-Module Microsoft.Graph)
# Run:      Connect-MgGraph -Scopes "User.ReadWrite.All","Group.ReadWrite.All","GroupMember.ReadWrite.All"
#           .\New-LabUsers.ps1
#
# The script is idempotent: it skips any user or group that already exists,
# so it is safe to re-run.

$Domain = "alvingonzogmail.onmicrosoft.com"

$Users = @(
    @{ DisplayName = "Alex Rivera";  MailNickname = "alex.rivera";  GivenName = "Alex";  Surname = "Rivera";  Department = "IT" }
    @{ DisplayName = "Priya Sharma"; MailNickname = "priya.sharma"; GivenName = "Priya"; Surname = "Sharma"; Department = "IT" }
    @{ DisplayName = "Marcus Webb";  MailNickname = "marcus.webb";  GivenName = "Marcus"; Surname = "Webb";  Department = "Finance" }
    @{ DisplayName = "Sofia Chen";   MailNickname = "sofia.chen";   GivenName = "Sofia"; Surname = "Chen";   Department = "Finance" }
    @{ DisplayName = "David Kim";    MailNickname = "david.kim";    GivenName = "David"; Surname = "Kim";    Department = "Sales" }
)

$Groups = @(
    @{ DisplayName = "IT Department";      MailNickname = "it-department";      Members = @("Alex Rivera", "Priya Sharma") }
    @{ DisplayName = "Finance Department"; MailNickname = "finance-department"; Members = @("Marcus Webb", "Sofia Chen") }
    @{ DisplayName = "Sales Department";   MailNickname = "sales-department";   Members = @("David Kim") }
)

# --- Create users (skip if the UPN already exists) ---
$CreatedUsers = @{}
foreach ($u in $Users) {
    $upn = "$($u.MailNickname)@$Domain"
    $existing = Get-MgUser -Filter "userPrincipalName eq '$upn'" -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Host "User already exists, skipping: $upn"
        $CreatedUsers[$u.DisplayName] = $existing
        continue
    }
    $params = @{
        DisplayName       = $u.DisplayName
        MailNickname      = $u.MailNickname
        UserPrincipalName = $upn
        GivenName         = $u.GivenName
        Surname           = $u.Surname
        Department        = $u.Department
        AccountEnabled    = $true
        PasswordProfile   = @{
            ForceChangePasswordNextSignIn = $true
            Password = "TempPass123!"
        }
    }
    $newUser = New-MgUser @params
    Write-Host "Created user: $upn"
    $CreatedUsers[$u.DisplayName] = $newUser
}

# --- Create groups (skip if the display name already exists) ---
foreach ($g in $Groups) {
    $existing = Get-MgGroup -Filter "displayName eq '$($g.DisplayName)'" -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Host "Group already exists, skipping: $($g.DisplayName)"
        $groupId = $existing.Id
    } else {
        $groupParams = @{
            DisplayName     = $g.DisplayName
            MailNickname    = $g.MailNickname
            MailEnabled     = $false
            SecurityEnabled = $true
        }
        $newGroup = New-MgGroup @groupParams
        Write-Host "Created group: $($g.DisplayName)"
        $groupId = $newGroup.Id
    }

    # --- Assign members (skip if already a member) ---
    foreach ($memberName in $g.Members) {
        $user = $CreatedUsers[$memberName]
        if (-not $user) { continue }
        $isMember = Get-MgGroupMember -GroupId $groupId -All | Where-Object { $_.Id -eq $user.Id }
        if ($isMember) {
            Write-Host "  Already a member of $($g.DisplayName): $memberName"
        } else {
            New-MgGroupMember -GroupId $groupId -DirectoryObjectId $user.Id
            Write-Host "  Added to $($g.DisplayName): $memberName"
        }
    }
}

Write-Host "Done. 5 users, 3 groups, memberships assigned."
