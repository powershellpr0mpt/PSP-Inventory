Function Get-RemoteScheduledTask {
    <#
    .SYNOPSIS
    Get Scheduled task information for local or remote machines 
    
    .DESCRIPTION
    Get Scheduled task information for local or remote machines. 
    Will get all scheduled tasks in the root folder
    
    .PARAMETER ComputerName
    Provide the computername(s) to query
    Default value is the local machine
    
    .EXAMPLE
    Get-RemoteScheduledTask -ComputerName 'CONTOSO-SRV01','CONTOSO-WEB01'
    
    Description
    -----------
    Gets the Scheduled Tasks for CONTOSO-SRV01 and CONTOSO-WEB01
    
    .NOTES
    Name: Get-RemoteScheduledTask.ps1
    Author: Robert Prüst
    Module: PSP-Inventory
    DateCreated: 23-02-2019
    DateModified: 01-03-2019
    Blog: https://powershellpr0mpt.com

    .LINK
    https://powershellpr0mpt.com
    #>
    
    [OutputType('PSP.Inventory.ScheduledTask')] 
    [cmdletbinding()]
    param (    
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]$ComputerName = $env:COMPUTERNAME
    )
    begin {
        $ST = New-Object -ComObject Schedule.Service
        $InventoryDate = Get-Date -f 'dd-MM-yyyy HH:mm:ss'
    }
    process {
        foreach ($Computer in $ComputerName) {
            $Computer = $Computer.ToUpper()
            try {
                $ST.Connect($Computer)
                $Root = $ST.GetFolder("\")
                @($Root.GetTasks(0)) | ForEach-Object {
                    $xml = ([xml]$_.xml).task
                    $SchdTsk = [PSCustomObject] @{
                        ComputerName   = $Computer
                        Task           = $_.Name
                        Author         = $xml.RegistrationInfo.Author
                        RunAs          = $xml.Principals.Principal.UserId                        
                        Enabled        = $_.Enabled
                        State          = Switch ($_.State) {
                            0 {'Unknown'}
                            1 {'Disabled'}
                            2 {'Queued'}
                            3 {'Ready'}
                            4 {'Running'}
                        }
                        LastTaskResult = Switch ($_.LastTaskResult) {
                            0x0 {"Successfully completed"}
                            0x1 {"Incorrect function called"}
                            0x2 {"File not found"}
                            0xa {"Environment is not correct"}
                            0x41300 {"Task is ready to run at its next scheduled time"}
                            0x41301 {"Task is currently running"}
                            0x41302 {"Task is disabled"}
                            0x41303 {"Task has not yet run"}
                            0x41304 {"There are no more runs scheduled for this task"}
                            0x41306 {"Task is terminated"}
                            0x00041307 {"Either the task has no triggers or the existing triggers are disabled or not set"}
                            0x00041308 {"Event triggers do not have set run times"}
                            0x80041309 {"A task's trigger is not found"}
                            0x8004130A {"One or more of the properties required to run this task have not been set"}
                            0x8004130B {"There is no running instance of the task"}
                            0x8004130C {"The Task * SCHEDuler service is not installed on this computer"}
                            0x8004130D {"The task object could not be opened"}
                            0x8004130E {"The object is either an invalid task object or is not a task object"}
                            0x8004130F {"No account information could be found in the Task * SCHEDuler security database for the task indicated"}
                            0x80041310 {"Unable to establish existence of the account specified"}
                            0x80041311 {"Corruption was detected in the Task * SCHEDuler security database"}
                            0x80041312 {"Task * SCHEDuler security services are available only on Windows NT"}
                            0x80041313 {"The task object version is either unsupported or invalid"}
                            0x80041314 {"The task has been configured with an unsupported combination of account settings and run time options"}
                            0x80041315 {"The Task * SCHEDuler Service is not running"}
                            0x80041316 {"The task XML contains an unexpected node"}
                            0x80041317 {"The task XML contains an element or attribute from an unexpected namespace"}
                            0x80041318 {"The task XML contains a value which is incorrectly formatted or out of range"}
                            0x80041319 {"The task XML is missing a required element or attribute"}
                            0x8004131A {"The task XML is malformed"}
                            0x0004131B {"The task is registered, but not all specified triggers will start the task"}
                            0x0004131C {"The task is registered, but may fail to start"}
                            0x8004131D {"The task XML contains too many nodes of the same type"}
                            0x8004131E {"The task cannot be started after the trigger end boundary"}
                            0x8004131F {"An instance of this task is already running"}
                            0x80041320 {"The task will not run because the user is not logged on"}
                            0x80041321 {"The task image is corrupt or has been tampered with"}
                            0x80041322 {"The Task * SCHEDuler service is not available"}
                            0x80041323 {"The Task * SCHEDuler service is too busy to handle your request"}
                            0x80041324 {"The Task * SCHEDuler service attempted to run the task, but the task did not run due to one of the constraints in the task definition"}
                            0x00041325 {"The Task * SCHEDuler service has asked the task to run"}
                            0x80041326 {"The task is disabled"}
                            0x80041327 {"The task has properties that are not compatible with earlier versions of Windows"}
                            0x80041328 {"The task settings do not allow the task to start on demand"}
                            Default {[string]$_}
                        }
                        Command        = $xml.Actions.Exec.Command
                        Arguments      = $xml.Actions.Exec.Arguments
                        StartDirectory = $xml.Actions.Exec.WorkingDirectory
                        Hidden         = $xml.Settings.Hidden
                        InventoryDate  = $InventoryDate
                    }
                    $SchdTsk.PSTypeNames.Insert(0, 'PSP.Inventory.ScheduledTask')
                    $SchdTsk
                }
            }
            catch {
                Write-Warning ("{0}: {1}" -f $Computer, $_.Exception.Message)
            }
        }
    }
}        