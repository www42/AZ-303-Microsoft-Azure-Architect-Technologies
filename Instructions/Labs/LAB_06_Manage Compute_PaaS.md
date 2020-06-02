---
lab:
    title: 'Lab: Implementing containers on Azure'
    module: 'Module 3: Manage Compute - PaaS'
---

# Lab: Implementing containers on Azure
# Student lab manual

## Lab scenario

Adatum Corporation became interested in containerization a few years ago, before it started entertaining the idea of migrating some of its workloads to Azure. Since then, its developers and engineers implemented a wide range of Docker-based applications, running on Windows Server 2016 and Linux Ubuntu 16.04. The Enterprise Architecture team also designed and assisted with implementation of an on-premises deployments of Kubernetes clusters to host a number more complex, containerized multi-tier applications. However, operational teams that took over management and maintainance of the clusters has been complaining about significant administrative overhead.

As part of the initiative of migrating on-premises workloads to Azure, the Enterprise Architecture team wants to evaluate different methods of running containerized apps in the cloud. While it is apparent that it is possible to deploy containers to Azure VMs in order to mirror their on-premises deployment model, the use of managed offerings, such as Azure Container Instances (ACI) and Azure Kubernetes Service (AKS) is considerably more compelling since it minimizes administrative overhead and offers additional agility and cost reduction benefits. The portability, inherent to containerization technologies, provides flexibility when choosing the target platform. 

Azure Container Instances offers the fastest and simplest way to run a container in Azure, without having to manage virtual machines or having to adopt a higher-level service. Azure Container Instances provide some of the basic scheduling capabilities of orchestration platforms, including all of the scheduling and management capabilities required to run a single container

Azure Kubernetes Service accommdates scenarios that require full container orchestration, including service discovery across multiple containers, automatic scaling, and coordinated application upgrades. It is also possible to combine benefits of ACI and AKS, by using the orchestrator platforms to manage multi-container tasks running within ACIs. 

In order to evaluate these capabilities, the Adatum Architecture team wants to test the following scenarios that involve the use of Docker containers on Azure:

-  containers running in Azure VMs

-  containers running in Azure Container Instances

-  container orchestration by using Azure Kubernetes Service (AKS)


## Objectives
  
After completing this lab, you will be able to:

-  implement containers running in Azure VMs

-  deploy containers to Azure Container Instances

-  deploy containers to Azure Kubernetes Service (AKS) clusters


## Lab Environment
  
Windows Server admin credentials

-  User Name: **Student**

-  Password: **Pa55w.rd1234**

Estimated Time: 120 minutes


## Lab Files

-  \\\\AZ303\\AllFiles\\Labs\\06\\azuredeploy30306suba.json

-  \\\\AZ303\\AllFiles\\Labs\\06\\azuredeploy30306rga.json

-  \\\\AZ303\\AllFiles\\Labs\\06\\azuredeploy30306rga.parameters.json


### Exercise 0: Prepare the lab environment

The main tasks for this exercise are as follows:

1. Deploy an Azure VM by using an Azure Resource Manager template

1. Install Git, .NET Core SDK, and Docker engine on an Azure VM running Windows Server 2019


#### Task 1: Deploy an Azure VM by using an Azure Resource Manager template

1. From your lab computer, start a web browser, navigate to the [Azure portal](https://portal.azure.com), and sign in by providing credentials of a user account with the Owner role in the subscription you are using in this lab.

1. In the Azure portal, open **Cloud Shell** pane by selecting on the toolbar icon directly to the right of the search textbox.

1. If prompted to select either **Bash** or **PowerShell**, select **Bash**. 

    >**Note**: If this is the first time you are starting **Cloud Shell** and you are presented with the **You have no storage mounted** message, select the subscription you are using in this lab, and select **Create storage**. 

1. In the toolbar of the Cloud Shell pane, select the **Upload/Download files** icon, in the drop-down menu select **Upload**, and upload the file **\\\\AZ303\\AllFiles\Labs\\06\\azuredeploy30306suba.json** into the Cloud Shell home directory.

1. From the Cloud Shell pane, run the following to create a resource groups (replace the `<Azure region>` placeholder with the name of the Azure region that is available for deployment of Azure VMs in your subscription and which is closest to the location of your lab computer):

   ```sh
   LOCATION='Azure region'
   az deployment sub create \
   --location $LOCATION \
   --template-file azuredeploy30306suba.json \
   --parameters rgName=az30306a-LabRG rgLocation=$LOCATION
   ```

      > **Note**: To identify Azure regions where you can provision Azure VMs, refer to [**https://azure.microsoft.com/en-us/regions/offers/**](https://azure.microsoft.com/en-us/regions/offers/)

1. From the Cloud Shell pane, upload the Azure Resource Manager template **\\\\AZ303\\AllFiles\Labs\\06\\azuredeploy30306rga.json**.

1. From the Cloud Shell pane, upload the Azure Resource Manager parameter file **\\\\AZ303\\AllFilesLabs\\06\\azuredeploy30306rga.parameters.json**.

1. From the Cloud Shell pane, run the following to deploy a Azure VM running Windows Server 2019 that you will be using in this lab:

   ```sh
   az deployment group create \
   --resource-group az30306a-LabRG \
   --template-file azuredeploy30306rga.json \
   --parameters @azuredeploy30306rga.parameters.json
   ```

    > **Note**: Wait for the deployment to complete. The deployment might take about than 5 minutes.

1. In the Azure portal, close the **Cloud Shell** pane. 


#### Task 2: Install Git, .NET Core SDK, and Docker engine on an Azure VM running Windows Server 2019

1. In the Azure portal, search for and select **Virtual machines** and, on the **Virtual machines** blade, select **az30306a-vm0**.

1. On the **az30306a-vm0** blade, select **Connect** and, in the drop-down menu, select **RDP**.

1. On the **az30306a-vm0 | Connect** blade, select **Download RDP File**.

1. Follow prompts to connect to the **az30306a-vm0** Azure VM. When prompted, sign in with the following credentials: 

   | Setting | Value |
   | --- | --- |
   | User Name | **Student** |
   | Password | **Pa55w.rd1234** |


1. Within the Remote Desktop session to **az30306a-vm0**, start Windows PowerShell as Administrator and run the following to disable Internet Explorer Enhanced Security Configuration:

   ```powershell
   $adminKey = 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}'
   $userKey = 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}'
   Set-ItemProperty -Path $adminKey -Name 'IsInstalled' -Value 0
   Set-ItemProperty -Path $userKey -Name 'IsInstalled' -Value 0
   Stop-Process -Name Explorer
   ```

1. Within the Remote Desktop session to **az30306a-vm0**, within the **Administrator: Windows PowerShell** console, run the following to install the .NET Core SDK.

   ```powershell
   $tempDir = New-Item -type Directory -Path 'C:\Temp' -Force
   Invoke-WebRequest -Uri https://dot.net/v1/dotnet-install.ps1 -OutFile $tempDir\dotnet-install.ps1
   Set-Location -Path $tempDir
   Get-ChildItem -File -Filter 'dotnet-install.ps1' | Unblock-File
   .\dotnet-install.ps1 -InstallDir "C:\Program Files\dotnet"
   ```

      > **Note**: Wait for the installation to complete. This might take about 2 minutes.

1. Within the **Administrator: Windows PowerShell** console, run the following to include **C:\\Program Files\\dotnet** in the system Path environment variable:

   ```powershell
   $oldPath=(Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
   $newPath=$oldPath+';C:\Program Files\dotnet'
   Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH –Value $newPath
   ```

1. Within the Remote Desktop session to **az30306a-vm0**, within the **Administrator: Windows PowerShell** console, run the following to install Git.

   ```powershell
   $repo = 'git-for-windows'
   $releases = "https://api.github.com/repos/$repo/git/releases"
   [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
   $response = (Invoke-WebRequest -Uri $releases -UseBasicParsing | ConvertFrom-Json)
   $downloadUrl = $response.assets | where {$_.name -match "-64-bit.exe" -and $_.name -notmatch "rc"} | sort created_at -Descending | select -First 1
   $outputPath = "$tempDir\$($downloadUrl.name)"
   Invoke-RestMethod -Method Get -Uri $DownloadUrl.browser_download_url -OutFile $OutputPath -ErrorAction Stop 
   $arguments = "/SILENT"
   Start-Process $OutputPath $arguments -Wait -ErrorAction Stop
   ```

      > **Note**: Wait for the installation to complete. This might take about 5 minutes.


1. Within the **Administrator: Windows PowerShell** console, run the following to install Azure CLI:

   ```powershell
   Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; rm .\AzureCLI.msi
   ```

1. Within the **Administrator: Windows PowerShell** console, run the following to install Docker Engine:

   ```powershell
   Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
   Install-Module DockerMsftProvider -Force
   Install-Package Docker -ProviderName DockerMsftProvider -Force
   If ((Install-WindowsFeature Containers).RestartNeeded ) { Restart-Computer -Force }
   ```

1. If the operating system restarts, reestablish Remote Desktop connection to the **az30306a-vm0** Azure VM and, when prompted, sign in with the same credentials as before.


### Exercise 1: Build an ASP.NET Core app in Docker containers

1. Build and deploy an ASP.NET Core sample app

1. Containerize the ASP.NET Core sample app


#### Task 1: Build and deploy an ASP.NET Core sample app

1. Within the Remote Desktop session to **az30306a-vm0**, start Command Prompt as Administrator and run the following to clone the .NET Core Docker repository:

   ```cmd
   md C:\az30306a-lab
   cd C:\az30306a-lab
   git clone https://github.com/dotnet/dotnet-docker
   ```

1. Within the Remote Desktop session to **az30306a-vm0**, from the Command Prompt, run the following to build and run the sample ASP.NET app locally:

   ```cmd
   cd dotnet-docker/samples/aspnetapp/aspnetapp
   dotnet run
   ```

1. To verify that the app is running, start Internet Explorer and browse to [http://localhost:5000](http://localhost:5000). Ignore the message **This site is not secure**, select **More information** and **Go on to the webpage (not recommended)**, and verify that the **Welcome to .NET Core** message is displayed. 

1. Close the Internet Explorer window and switch back to the Command Prompt.


#### Task 2: Containerize the ASP.NET Core sample app

1. From the Command Prompt, run the following to open Dockerfile for the sample app in Notepad:

   ```cmd
   cd ../
   notepad Dockerfile
   ```

1. In Notepad, review the content of Dockerfile and close the file without making any changes.

   ```dockerfile
   FROM mcr.microsoft.com/dotnet/core/sdk:3.0 AS build
   WORKDIR /app

   # copy csproj and restore as distinct layers
   COPY *.sln .
   COPY aspnetapp/*.csproj ./aspnetapp/
   RUN dotnet restore

   # copy everything else and build app
   COPY aspnetapp/. ./aspnetapp/
   WORKDIR /app/aspnetapp
   RUN dotnet publish -c Release -o out

   FROM mcr.microsoft.com/dotnet/core/aspnet:3.0 AS runtime
   WORKDIR /app
   COPY --from=build /app/aspnetapp/out ./
   ENTRYPOINT ["dotnet", "aspnetapp.dll"]
   ```

      > **Note**: This Dockerfile builds an app first and then uses the resulting build to create an image containing the app release with runtime components only.

1. From the Command Prompt, run the following to build a container image for the app in the **dotnet-docker/samples/aspnetapp/aspnetapp** folder:

   ```cmd
   docker build -t aspnetapp .
   ```

1. From the Command Prompt, run the following to verify that the new image has been created:

   ```cmd
   docker images
   ```

1. From the Command Prompt, run the following to create a container listening on port 5000 based on the newly created image:

   ```cmd
   docker create -p 5000:80 --name aspnetapp-container aspnetapp
   ```

1. From the Command Prompt, run the following to verify that the container hosting the app has been created, but is not yet running:

   ```cmd
   docker ps -a
   ```

1. From the Command Prompt, run the following to start the newly created container:

   ```cmd
   docker start aspnetapp-container
   ```

1. To verify that the container hosting the app is running, start Internet Explorer and browse to [http://localhost:5000](http://localhost:5000). Ignore the message **This site is not secure**, select **More information** and **Go on to the webpage (not recommended)**, and verify that the **Welcome to .NET Core** message is displayed.

1. From the Command Prompt, run the following to view the running container:

   ```cmd
   docker ps -a
   ```

1. From the Command Prompt, run the following to stop the running container:

   ```cmd
   docker stop aspnetapp-container
   ```

1. From the Command Prompt, run the following to view the stopped container:

   ```cmd
   docker ps -a
   ```

1. From the Command Prompt, run the following to remove the stopped container:

   ```cmd
   docker rm aspnetapp-container
   ```

### Exercise 2: Push an image into Azure Container Registry

1. Create and configure an Azure container registry

1. Push an image into the Azure container registry


#### Task 1: Create and configure an Azure container registry

1. Within the Remote Desktop session to **az30306a-vm0**, start Internet Explorer, navigate to the [Azure portal](https://portal.azure.com), and sign in by providing credentials of the user account with the Owner role in the subscription you are using in this lab.

1. In the Azure portal, start a Bash session within the **Cloud Shell** pane by selecting on the toolbar icon directly to the right of the search textbox.

1. From the Cloud Shell pane, run the following to create a resource group in the same Azure region into which you deployed the Azure VM in the first exercise of this lab:

   ```sh
   RGNAME='az30306b-LabRG'
   LOCATION=$(az group show --name az30306a-LabRG --query location --output tsv)
   az group create --name $RGNAME --location $LOCATION
   ```

1. From the Cloud Shell pane, run the following to create an Azure container registry in the newly created resource group:

   ```sh
   ACRNAME=az30306b$RANDOM
   az acr create --resource-group $RGNAME --name $ACRNAME --sku Basic
   echo $ACRNAME
   ```
   
1. From the Cloud Shell pane, run the following to allow sign in to the Azure container registry with the Admin user account when using docker commands.

   ```sh
   az acr update --name $ACRNAME --admin-enabled true
   ```

1. From the Cloud Shell pane, run the following to identify the Admin user name and its passwords for the newly created Azure container registry:

   ```sh
   az acr credential show --name $ACRNAME --resource-group $RGNAME
   ```

      > **Note**: Record the user name and one of the two passwords. You will need them in the next task.

1. From the Cloud Shell pane, run the following to identify the name of the newly created Azure container registry:

   ```sh
   echo $ACRNAME
   ```

      > **Note**: Record the registry name. You will need it in the next task.


#### Task 2: Push an image into the Azure container registry

1. Within the Remote Desktop session to **az30306a-vm0**, switch back to the Command Prompt window and run the following to sign in to the Azure container registry with the Admin user account (replace the <ACR name> placeholder with the name of the Azure container registry you identified in the previous task):

   ```sh
   docker login <ACR name>.azurecr.io
   ```

1. When prompted, provide the user name and one of the two passwords you recorded in the previous task.

1. From the Command Prompt, run the following to identify local images:

   ```cmd
   docker images
   ```

1. From the Command Prompt, run the following to tag the local image you created in the previous exercise (replace the <ACR name> placeholder with the name of the Azure container registry):

   ```cmd
   docker tag aspnetapp <ACR name>.azurecr.io/aspnetapp:v1
   ```

1. From the Command Prompt, run the following to verify that the tag was applied (the image is tagged with the ACR name and the version number):

   ```cmd
   docker images
   ```

1. From the Command Prompt, run the following to push the newly tagged image to the Azure container registry (replace the <ACR name> placeholder with the name of the Azure container registry):

   ```cmd
   docker push <ACR name>.azurecr.io/aspnetapp:v1
   ```

1. Switch to the Internet Explorer window displaying the Azure portal and, from the Cloud Shell pane, run the following to verify that the image exists in the Azure container registry:

   ```sh
   az acr repository list --name $ACRNAME --output table
   ```

### Exercise 3: Deploy an image from Azure Container Registry to an Azure container instance

1. Create an Azure container instance

1. Review the functionality of the Azure container instance


#### Task 1: Create an Azure container instance

1. Within the Remote Desktop session to **az30306a-vm0**, in the Internet Explorer window displaying the Azure portal, search for and select **Container instances** and, on the **Container instances** blade, select **+ Add**.

1. On the **Basics** tab of the **Create container instance** blade, specify the following settings (leave others with their default values):

    | Setting | Value |
    | ---- | ---- |
    | Subscription | the name of the Azure subscription you are using in this lab |
    | Resource group | the name of a new resource group **az30306c-LabRG** |
    | Container name | **az30306c-c1** |
    | Region | the name of an Azure region you used to provision Azure container registry in the previous exercise in this lab |
    | Image Source | **Azure Container Registry** |
    | Registry | the name of the Azure container registry you provisioned in the previous exercise in this lab |
    | Image | **aspnetapp** |
    | Image tag | **v1** |
    | OS type | **Windows** |
    | Size | **1 vcpu, 1.5 GiB memory, 0 gpus** |

1. Select **Next: Networking >** and, on the **Networking** tab of the **Create container instance** blade, specify the following settings (leave others with their default values):

    | Setting | Value |
    | --- | --- |
    | DNS name label | any valid, globally unique DNS host name |
	
    >**Note**: Your container will be publicly reachable via dns-name-label.region.azurecontainer.io. If you receive a **DNS name label not available** error message, specify a different value.

1. Select **Next: Advanced >**, review the settings on the **Advanced** tab of the **Create container instance** blade without making any changes, select **Review + Create**, and then select **Create**. 

    >**Note**: Wait for the deployment to complete. This takes about 3 minutes.


#### Task 2: Review the functionality of the Azure container instance

In this task, you will review the deployment of the container instance.

1. Within the Remote Desktop session to **az30306a-vm0**, in the Internet Explorer window displaying the Azure portal, search for and select **Container instances** and, on the **Container instances** blade, select **az30306c-c1**

1. On the **az30306c-c1** blade, verify that **Status** is reported as **Running**. 

1. Copy the value of the container instance **FQDN**, open a new browser tab, navigate to the corresponding URL, and verify that the **Welcome to .NET Core** message is displayed.

1. Close the new browser tab.


### Exercise 4: Deploy an image from Azure Container Registry to an Azure Kubernetes Service (AKS) cluster

1. Create an AKS cluster

1. Deploy an image from Azure Container Registry to the AKS cluster

1. Remove Azure resources deployed in the lab


#### Task 1: Create an AKS cluster

1. Within the Remote Desktop session to **az30306a-vm0**, in the Internet Explorer window displaying the Azure portal, search for and select **Kubernetes services** and, on the **Kubernetes services** blade, select **+ Add**.

1. On the **Basics** tab of the **Create Kubernetes cluster** blade, specify the following settings (leave others with their default values):

    | Setting | Value |
    | ---- | ---- |
    | Subscription | the name of the Azure subscription you are using in this lab |
    | Resource group | the name of a new resource group **az30306d-LabRG** |
    | Kubernetes cluster name | **az30306d-aks1** |
    | Kubernetes version | the default value |
    | Node size | **Standard D2s v3** |
    | Node count | **1** | 

1. Select **Next: Node pools >** and, on the **Node pools** tab of **Create Kubernetes cluster** blade, select **+ Add node pool**.

    >**Note**: The primary node pool must be Linux to support system pods.

1. On the **Add a node pool** blade, specify the following settings (leave others with their default values) and select **Add**:

    | Setting | Value |
    | --- | --- |
    | Node pool name | **wpool1** |
    | OS type | **Windows** |
    | Node size | **Standard D2s v3** |
    | Node count | **1** | 

1. Back on the **Node pools** tab of **Create Kubernetes cluster** blade, leave other settings with their default values and select **Next: Authentication >**.

1. On the **Authentication** tab of **Create Kubernetes cluster** blade, specify the following settings (leave others with their default values):

    | Setting | Value |
    | --- | --- |
    | Authentication method | **System-assigned managed identity** |
    | Role-based access control (RBAC) | **Enabled** |

1. Select **Next: Networking >** and, on the **Networking** tab of the **Create Kubernetes cluster** blade, specify the following settings (leave others with their default values):

    | Setting | Value |
    | --- | --- |
    | Network configuration | **Advanced** |
    | DNS name prefix | any unique, valid DNS name | 

1. Select **Next: Integrations >** and, on the **Integrations** tab of the **Create Kubernetes cluster** blade, specify the following settings (leave others with their default values):

    | Setting | Value |
    | --- | --- |
    | Container registry | the name of the Azure container registry you created earlier in this lab |
    | Container monitoring | **Disabled** |

1. Select **Review + Create**, and then select **Create**. 

    >**Note**: Wait for the deployment to complete. This takes about 10 minutes.


#### Task 2: Deploy an image from Azure Container Registry to the AKS cluster

1. Within the Remote Desktop session to **az30306a-vm0**, in the Internet Explorer window displaying the Azure portal, search for and select **Kubernetes services** and, on the **Kubernetes services** blade, select **az30306d-aks1**.

1. Within the Remote Desktop session to **az30306a-vm0**, in the Internet Explorer window displaying the Azure portal, start a Bash session in the Cloud Shell pane. 

1. From the Cloud Shell pane, run the following to configure kubectl to connect to the newly created Kubernetes cluster:

   ```sh
   AKSRGNAME='az30306d-LabRG'
   AKSNAME='az30306d-aks1'
   az aks get-credentials --resource-group $RGNAME --name $AKSNAME
   ```

1. From the Cloud Shell pane, run the following to verify the connection to your cluster by listing the cluster nodes, including one running Linux and the other Windows Server:

   ```sh
   kubectl get nodes
   ```

1. From the Cloud Shell pane, run the following to identify the value of the **name** property of the Azure container registry hosting the image created earlier in this lab:

   ```sh
   ACRRGNAME='az30306b-LabRG'
   ACRNAME=$(az acr list --resource-group 'az30306b-LabRG' --query "[?starts_with(name,'az30306')]".name --output tsv)
   echo $ACRNAME
   ```
    >**Note**: Record the name of the Azure container registry. You will need it in the next step.

1. From the Cloud Shell pane, use the built-in editor to create a new file named **aspnetapp.yaml** in the root of the home directory, paste the following content into it, and save it (make sure to replace the `$ACRNAME` placeholder with the name of the Azure container registry you recorded in the previous step):

   ```yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: aspnetapp
     labels:
       app: aspnetapp
   spec:
     replicas: 1
     template:
       metadata:
         name: aspnetapp
         labels:
           app: aspnetapp
       spec:
         nodeSelector:
           "beta.kubernetes.io/os": windows
         containers:
         - name: aspnetapp
           image: $ACRNAME.azurecr.io/aspnetapp:v1
           resources:
             limits:
               cpu: 1
               memory: 800M
             requests:
               cpu: .1
               memory: 300M
           ports:
             - containerPort: 80
     selector:
       matchLabels:
         app: aspnetapp
   ---
   apiVersion: v1
   kind: Service
   metadata:
     name: aspnetapp
   spec:
     type: LoadBalancer
     ports:
     - protocol: TCP
       port: 80
     selector:
       app: aspnetapp
   ```

1. From the Cloud Shell pane, run the following to deploy resources defined in the **aspnetapp.yaml** file: 

   ```sh
   kubectl apply -f aspnetapp.yaml
   ```

1. From the Cloud Shell pane, run the following to verify that the deployment resulted in creation of a single pod: 

   ```sh
   kubectl get pods
   ```

1. From the Cloud Shell pane, run the following to identify the external IP address associated with the **LoadBalancer** service:

   ```sh
   kubectl get service aspnetapp
   ```

    >**Note**: You might have to wait a few minutes and rerun this command in order to identify the external IP address.

1. To verify that the app is running, start Internet Explorer, browse to the external IP address you identified in the previous step, and verify that the **Welcome to .NET Core** message is displayed. 


#### Task 3: Remove Azure resources deployed in the lab

1. From the Cloud Shell pane, run the following to list the resource group you created in this exercise:

   ```sh
   az group list --query "[?starts_with(name,'az30306')]".name --output tsv
   ```

    > **Note**: Verify that the output contains only the resource group you created in this lab. This group will be deleted in this task.

1. From the Cloud Shell pane, run the following to delete the resource group you created in this lab

   ```sh
   az group list --query "[?starts_with(name,'az30306')]".name --output tsv | xargs -L1 bash -c 'az group delete --name $0 --no-wait --yes'
   ```

1. Close the Cloud Shell pane.