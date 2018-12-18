
Describe "Testing NIC Info" {
    Context -Name 'Testing physical adapters' {
        $TestCases =
        @{  InterfaceAlias = 'Ethernet'
            TestName       = 'Ethernet is a Physical Adapter'
        },
        @{  InterfaceAlias = 'Loopback Pseudo-Interface 1'
            TestName       = 'Loopback is NOT Physical'
        },
        @{  InterfaceAlias = 'vEthernet (Default Switch)'
            TestName       = 'Hyper-V switch is NOT Physical'
        }
        it "Testing network adapter <TestName>" -TestCases $TestCases {
            param($InterfaceAlias)
            $NicInfo = .\Get-NicInfo.ps1 | Where-Object {$_.Alias -eq $InterfaceAlias}
            if ($NicInfo.Alias -eq 'Ethernet') {
                $NicInfo.Physical | Should be $true
            }
            else {
                $NicInfo.Physical | Should be $false
            }
        }
    }
}
