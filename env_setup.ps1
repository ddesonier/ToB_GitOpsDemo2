$sp_name = 'tob_demo_sp_contrib2'
$tenantID = '4a414dd8-5762-4937-bb06-64d67ae006a6'
$subID = '7c27312f-200e-47f6-a855-c308a26f1493'
$sshPath = './test.rsa'

$location = 'eastus'
$resourceGroup = 'ToB_Demo2'
$projectName = 'tobdemo2'
$month = Get-Date -Format "MM"
$accountName = ($projectName + $location + (Get-Culture).DateTimeFormat.GetMonthName($month) + (Get-Date -Format "yyyy")).ToLower()
Set-Item -Path env:TF_VAR_STORAGEACCOUNT -Value $accountName
$storageContainerName = 'tfstate'

#Connect-AzAccount
az login

$azContext = Get-AzContext

Set-AzContext -Subscription  $subID


### Create Service Principal for AKS Cluster
$sp = New-AzADServicePrincipal -DisplayName $sp_name -Role "Contributor"

### Set up Environment Variables for Service Principal
Set-Item -Path env:TF_VAR_ARM_APP_ID -Value $sp.AppId
Set-Item -Path env:TF_VAR_ARM_SUBSCRIPTION_ID -Value $subID
Set-Item -Path env:TF_VAR_ARM_TENANT_ID -Value $tenantID
Set-Item -Path env:TF_VAR_ARM_CLIENT_SECRET -Value $sp.PasswordCredentials.SecretText
Set-Item -Path env:TF_VAR_ARM_OBJECT_ID -Value $sp.ID

### Craete SSH Key
Write-Output "y" | ssh-keygen -m PEM -t rsa -b 4096  -C $azContext.Account.Id -q -N '""' -f $sshPath
Write-Output `n

az group create -l $location -n $resourceGroup

### Create Storage Account to Store Terraform State File
New-AzStorageAccount -ResourceGroupName $resourceGroup `
  -Name $accountName `
  -Location $location `
  -SkuName Standard_RAGRS `
  -Kind StorageV2

  $account = Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $accountName

  if ($account.KeyCreationTime.Key1 -eq $null -or $account.KeyCreationTime.Key2 -eq $null)
{
    Write-Host("You must regenerate both keys at least once before setting expiration policy")
} else {
    $storageaccntKeys = Get-AzStorageAccountKey -ResourceGroupName $resourceGroup -AccountName $accountName
    Write-Host "Keys are in good standing"
}

### Create Container within Storage Account
az storage container create -n $storageContainerName `
   --account-name $accountName  `
   --account-key $storageaccntKeys[0].Value

az storage container list `
    --account-name $accountName  `
    --account-key $storageaccntKeys[0].Value