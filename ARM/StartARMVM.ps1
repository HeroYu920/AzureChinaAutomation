<#
.NOTES
    AUTHOR: Lei Zhang 
    LASTEDIT: 2019-07-25
#>
#开机脚本

$cred = Get-AutomationPSCredential -Name "MyAccount"

#设置订阅名称
$subscriptionName= 'InputYourSubscription'

#设置需要开机的虚拟机名称，以分号分隔
$VMNamesArray='WinVDI01;WinVDI02'

#资源组名称
$ResourceGroupName='InputYourRG'

Add-AzureRMAccount -Credential $cred -EnvironmentName AzureChinaCloud

Select-AzureRmSubscription -SubscriptionName $subscriptionName | Select-AzureRmSubscription

$VMNames = $VMNamesArray -split ";"

$jobs = @()
Foreach ($VMName in $VMNames) 
{

    $VM= Get-AzureRMVM | Where-Object {($_.ResourceGroupName -eq $ResourceGroupName) -and ($_.Name -eq $VMName)}
    
    #判断VM是否存在
    if($VM)
    {
            #Get VM Status
            $vmStatus = (Get-AzureRMVM -ResourceGroupName $VM.ResourceGroupName -Name $VM.Name -Status).Statuses.DisplayStatus[1]

            #判断VM的开关机状态
            if($vmStatus -eq 'VM deallocated')
            {
                $jobs += Start-AzureRMVM -ResourceGroupName $vm.ResourceGroupName -Name $VM.Name
            }
    }
    else
    {
        "VM Name " +  $VM.Name + " is NOT Existing in Resource Group " + $ResourceGroupName + " Please check the configuration"
    }
}

$jobs | Wait-Job | Remove-Job -Force

"All VMs are Started"
