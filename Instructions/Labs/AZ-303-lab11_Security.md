# Module 4 - Security
# Lab 11: Managing Azure Role-Based Access Control

### Scenario

Adatum Corporation wants to test delegation of Azure management by using Role-Based Access Control
  

### Objectives
  
After completing this lab, you will be able to:

-  Define a custom RBAC role 

-  Assign a custom RBAC role



### Lab Environment
  
Windows Server admin credentials

-  User Name: **Student**

-  Password: **Pa55w.rd1234**

Estimated Time: 60 minutes


### Lab Files

-  \\\\AZ303\\AllFiles\\Labs\\11\\azuredeploy30311suba.json

-  \\\\AZ303\\AllFiles\\Labs\\11\\azuredeploy30311rga.json

-  \\\\AZ303\\AllFiles\\Labs\\11\\azuredeploy30311rga.parameters.json

-  \\\\AZ303\\AllFiles\\Labs\\11\\roledefinition30311.json



### Exercise 0: Prepare the lab environment

The main tasks for this exercise are as follows:

1. Deploy an Azure VM by using an Azure Resource Manager template

1. Create an Azure Active Directory user


#### Task 1: Deploy an Azure VM by using an Azure Resource Manager template

1. From your lab computer, start a web browser, navigate to the [Azure portal](https://portal.azure.com), and sign in by providing credentials of a user account with the Owner role in the subscription you will be using in this lab.

1. In the Azure portal, open **Cloud Shell** pane by selecting on the toolbar icon directly to the right of the search textbox.

1. If prompted to select either **Bash** or **PowerShell**, select **PowerShell**. 

    >**Note**: If this is the first time you are starting **Cloud Shell** and you are presented with the **You have no storage mounted** message, select the subscription you are using in this lab, and select **Create storage**. 

1. In the toolbar of the Cloud Shell pane, select the **Upload/Download files** icon, in the drop-down menu select **Upload**, and upload the file **\\\\AZ303\\AllFiles\Labs\\11\\azuredeploy30311suba.json** into the Cloud Shell home directory.

1. From the Cloud Shell pane, run the following to create a resource groups (replace the `<Azure region>` placeholder with the name of the Azure region that is available for deployment of Azure VMs in your subscription and which is closest to the location of your lab computer):

   ```powershell
   $location = '<Azure region>'
   New-AzSubscriptionDeployment `
     -Location $location `
     -Name az30311subaDeployment `
     -TemplateFile $HOME/azuredeploy30311suba.json `
     -rgLocation $location `
     -rgName 'az30311a-labRG'
   ```

      > **Note**: To identify Azure regions where you can provision Azure VMs, refer to [**https://azure.microsoft.com/en-us/regions/offers/**](https://azure.microsoft.com/en-us/regions/offers/)

1. From the Cloud Shell pane, upload the Azure Resource Manager template **\\\\AZ303\\AllFiles\Labs\\11\\azuredeploy30311rga.json**.

1. From the Cloud Shell pane, upload the Azure Resource Manager parameter file **\\\\AZ303\\AllFilesLabs\\11\\azuredeploy30311rga.parameters.json**.

1. From the Cloud Shell pane, run the following to deploy a Azure VM running Windows Server 2019 that you will be using in this lab:

   ```powershell
   New-AzResourceGroupDeployment `
     -Name az30311rgaDeployment `
     -ResourceGroupName 'az30311a-labRG' `
     -TemplateFile $HOME/azuredeploy30311rga.json `
     -TemplateParameterFile $HOME/azuredeploy30311rga.parameters.json `
     -AsJob
   ```

    > **Note**: Do not wait for the deployment to complete but instead proceed to the next task. The deployment should take less than 5 minutes.


#### Task 2: Create an Azure Active Directory user

1. In the Azure portal, from the PowerShell session in the Cloud Shell pane, run the following to authenticate to the Azure AD tenant associated with your Azure subscription:

   ```powershell
   Connect-AzureAD
   ```
   
1. From the Cloud Shell pane, run the following to identify the Azure AD DNS domain name:

   ```powershell
   $domainName = ((Get-AzureAdTenantDetail).VerifiedDomains)[0].Name
   ```

1. From the Cloud Shell pane, run the following to create a new Azure AD user:

   ```powershell
   $passwordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
   $passwordProfile.Password = 'Pa55w.rd1234'
   $passwordProfile.ForceChangePasswordNextLogin = $false
   New-AzureADUser -AccountEnabled $true -DisplayName 'az30311aaduser1' -PasswordProfile $passwordProfile -MailNickName 'az30311aaduser1' -UserPrincipalName "az30311aaduser1@$domainName"
   ```

1. From the Cloud Shell pane, run the following to identify the user principal name of the newly created Azure AD user:

   ```powershell
   (Get-AzureADUser -Filter "MailNickName eq 'az30311aaduser1'").UserPrincipalName
   ```

      > **Note**: Record the user principal name of the newly created Azure AD user. You will need it later in this lab.

1. Close the Cloud Shell pane.


## Exercise 1: Define a custom RBAC role
  
The main tasks for this exercise are as follows:

1. Identify actions to delegate via RBAC

1. Create a custom RBAC role in an Azure AD tenant


#### Task 1: Identify actions to delegate via RBAC

1. In the Azure portal, navigate to the **az30311a-labRG** blade.

1. On the **az30311a-labRG** blade, select **Access Control (IAM)**.

1. On the **az30311a-labRG - Access Control (IAM)** blade, select **Roles**.

1. On the **Roles** blade, select **Owner**.

1. On the **Owner** blade, select **Permissions**.

1. On the **Permissions (preview)** blade, select **Microsoft Compute**.

1. On the **Microsoft Compute** blade, select **Virtual machines**.

1. On the **Virtual Machines** blade, review the list of management actions that can be delegated through RBAC. Note that they include the **Deallocate Virtual Machine** and **Start Virtual Machine** actions.


#### Task 2: Create a custom RBAC role in an Azure AD tenant

1. On the lab computer, open the file **\\\\AZ303\\AllFiles\\Labs\\11\\roledefinition30311.json** and review its content:

   ```json
   {
      "Name": "Virtual Machine Operator (Custom)",
      "Id": null,
      "IsCustom": true,
      "Description": "Allows to start/restart Azure VMs",
      "Actions": [
          "Microsoft.Compute/*/read",
          "Microsoft.Compute/virtualMachines/restart/action",
          "Microsoft.Compute/virtualMachines/start/action"
      ],
      "NotActions": [
      ],
      "AssignableScopes": [
          "/subscriptions/SUBSCRIPTION_ID"
      ]
   }
   ```

1. On the lab computer, in the browser window displaying the Azure portal, start a **PowerShell** session within the **Cloud Shell**. 

1. From the Cloud Shell pane, upload the Azure Resource Manager template **\\\\AZ303\\AllFiles\\Labs\\11\\roledefinition30311.json** into the home directory.

1. From the Cloud Shell pane, run the following to replace the `SUBSCRIPTION_ID` placeholder with the ID value of the Azure subscription:

   ```powershell
   $subscription_id = (Get-AzContext).Subscription.id
   (Get-Content -Path $HOME/roledefinition30311.json) -Replace 'SUBSCRIPTION_ID', "$subscription_id" | Set-Content -Path $HOME/roledefinition30311.json
   ```

1. From the Cloud Shell pane, run the following to verify that the `SUBSCRIPTION_ID` placeholder was replaced with the ID value of the Azure subscription:

   ```powershell
   Get-Content -Path $HOME/roledefinition30311.json
   ```

1. From the Cloud Shell pane, run the following to create the custom role definition:

   ```powershell
   New-AzRoleDefinition -InputFile $HOME/roledefinition30311.json
   ```

1. From the Cloud Shell pane, run the following to verify that the role was created successfully:

   ```powershell
   Get-AzRoleDefinition -Name 'Virtual Machine Operator (Custom)'
   ```

1. Close the Cloud Shell pane.


## Exercise 2: Assign and test a custom RBAC role
  
The main tasks for this exercise are as follows:

1. Create an RBAC role assignment

1. Test the RBAC role assignment


#### Task 1: Create an RBAC role assignment
 
1. In the Azure portal, navigate to the **az30311a-labRG** blade.

1. On the **az30311a-labRG** blade, select **Access Control (IAM)**.

1. On the **az30311a-labRG - Access Control (IAM)** blade, select **+ Add** and select the **Add role assignment** option.

1. On the **Add role assignment** blade, specify the following settings (leave others with their existing values) and select **Save**:

    | Setting | Value | 
    | --- | --- |
    | Role | **Virtual Machine Operator (Custom)** |
    | Assign access to | **Azure AD user, group, or service principal** |
    | Select | **az30311aaduser1** |


#### Task 2: Test the RBAC role assignment

1. From the lab computer, start a new in-private web browser session, navigate to the [Azure portal](https://portal.azure.com), and sign in by using the **az30311aaduser1** user account with the **Pa55w.rd1234** password.

    > **Note**: Make sure to use the user principal name of the **az30311aaduser1** user account, which you recorded earlier in this lab.

1. In the Azure portal, navigate to the **Resource groups** blade. Note that you are not able to see any resource groups. 

1. In the Azure portal, navigate to the **All resources** blade. Note that you are able to see only the **az30311a-vm0** and its managed disk.

1. In the Azure portal, navigate to the **az30311a-vm0** blade. Try stopping the virtual machine. Review the error message in the notification area and note that this action failed because the current user is not authorized to carry it out.

1. Restart the virtual machine and verify that the action completed successfully.


#### Task 4: Remove Azure resources deployed in the lab

1. From the lab computer, in the browser window displaying the Azure portal, start a PowerShell session within the Cloud Shell pane.

1. From the Cloud Shell pane, run the following to list the resource group you created in this exercise:

   ```powershell
   Get-AzResourceGroup -Name 'az30311*'
   ```

    > **Note**: Verify that the output contains only the resource group you created in this lab. This group will be deleted in this task.

1. From the Cloud Shell pane, run the following to delete the resource group you created in this lab

   ```powershell
   Get-AzResourceGroup -Name 'az30311*' | Remove-AzResourceGroup -Force -AsJob
   ```

1. Close the Cloud Shell pane.