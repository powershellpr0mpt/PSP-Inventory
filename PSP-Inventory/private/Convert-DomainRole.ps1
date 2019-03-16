function Convert-DomainRole
{
    [cmdletbinding()]
    param(
        [int]$DomainRole
    )
    switch ($DomainRole)
    {
        0 { "Standalone Workstation" }
        1 { "Member Workstation" }
        2 { "Standalone Server" }
        3 { "Member Server" }
        4 { "Backup Domain Controller" }
        5 { "Primary Domain Controller" }
        Default { "Member Server" }
    }
}