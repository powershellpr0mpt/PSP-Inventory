function Convert-NetworkStatus
{
    [cmdletbinding()]
    Param(
        [int]$NetworkStatus
    )
    switch ($NetworkStatus)
    {
        0 { "Disconnected" }
        1 { "Connecting" }
        2 { "Connected" }
        3 { "Disconnecting" }
        4 { "Hardware not present" }
        5 { "Hardware disabled" }
        6 { "Hardware malfunction" }
        7 { "Media disconnected" }
        8 { "Authenticating" }
        9 { "Authentication succeeded" }
        10 { "Authentication failed" }
        11 { "Invalid Address" }
        12 { "Credentials Required" }
        Default { "Not connected" }
    }
}