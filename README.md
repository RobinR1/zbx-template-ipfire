# IPFire by Zabbix Agent Active

## Description

This template monitors an [IPFire](https://www.ipfire.org/) [appliance](https://www.lightningwirelabs.com/products/ipfire/appliances) or [instance](https://www.ipfire.org/download)

## Overview

For Zabbix version: [7.0](./7.0/), [7.2](./7.2/)

Supports monitoring of:
- IPFire general stats (Number of current DHCPd clients)
- IPFire services (default IPFire services and possible Addon services)
- Pakfire status (Installed version, Available update(s))
- Network stats (Line quality, Open Connections, Firewall hits)
- OpenVPN clients and stats (OpenVPN client discovery, OpenVPN client properties, Traffic stats, Client/Server/CA Certificate validation)
- IPS throughput stats (Scanned, Bypassed, Whitelisted)
- Guardian blocked IPs (count)

Use in conjunction with a default Template OS Linux-template for CPU/Memory/Storage monitoring of the IPFire appliance/instance.

This template was created for:

- IPFire 2.29 - Core update 191 and higher

**Warning**: This template will *NOT* work on earlier versions of IPFire due to changes to the Zabbix Agent addon.

![Zabbix 7.0 IPFire host dashboard](./images/IPFire_Zabbix_Host_Dashboard.png)
*IPFire host dashboard (Zabbix 7.2+)*

![Zabbix 7.0 OpenVPN Client host dashboard](./images/IPFire_OpenVPNClient_Host_Dashboard.png)
*OpenVPN client host dashboard (Zabbix 7.2+)*

![image info](./images/IPFire_Zabbix_Dashboard.png)
*Example Zabbix 7.2 dashboard for an IPFire instance using this template + Zabbix default Linux by Zabbix Agent template*

## Author

Robin Roevens
