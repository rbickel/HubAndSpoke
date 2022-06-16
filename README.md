Deploy an Azure Hub & Spoke networking solution. The Hub having an Azure Firewall to filter outbound traffic and an Application Gateway for inbound http traffic.

Internet routing is enforced through the Firewall with a custom Policy.

How to deploy it:

```bash
az deployment sub create -l westeurope --template-file .\all.bicep
```
