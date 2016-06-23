### Overview

Collection of PowerShell scripts and resources to dynamically configure Azure VNET controls (NSG and UDR) based on published IP ranges from the following download:

https://www.microsoft.com/en-in/download/confirmation.aspx?id=41653

The end goal will be to wrap up these scripts in an ARM template leveraging Azure Automation to keep a specified deployment up-to-date.

### Limitations

There are several limitations that need dealt with first. Mainly, the default limits for NSG's and UDR's barely contain the published subnets. Azure networking limits can be found here: https://azure.microsoft.com/en-us/documentation/articles/azure-subscription-service-limits/#networking-limits---azure-resource-manager

The immediate concern is the scalability of such a solution. That said, in environments that require absolute control over outbound network access, this may be a necessary tradeoff.

### Credit 

Much of this work is based directly off of the blog post by Keith Mayer (https://blogs.technet.microsoft.com/keithmayer/2016/01/12/step-by-step-automate-building-outbound-network-security-groups-rules-via-azure-resource-manager-arm-and-powershell/).