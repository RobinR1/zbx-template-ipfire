# Template App IPFire by Zabbix Agent Active

## Overview

For Zabbix version: 5.0

This template-set monitors an IPFire appliance/instance and supports monitoring of:
- IPFire general stats (Available entropy, state of RNG)
- IPFire services (default IPFire services and possible Addon services)
- Pakfire status (Installed version, Available update(s))
- Network stats (Line quality, Open Connections, Firewall hits)

Use in conjunction with a default Template OS Linux-template for CPU/Memory/Storage monitoring of the IPFire appliance/instance.

Also an extra Zabbix agent userparameter is included to support `vfs.dev.discovery` on Zabbix agent <4.4 as IPFire currently ships with Zabbix agent v4.2. Install this userparameter to enable the Template Module Linux block devices-template included with Zabbix Server 4.4+ to monitor block device performance.

This template was tested on:

- IPFire 2.25 - Core update 150, but should work on earlier versions

## Setup

- Install IPFire addon `zabbix_agentd` using Pakfire
- Install IPFire addon `fping` using Pakfire
- Remove `userparameter_pakfire.conf` from the folder with Zabbix agent configuration, if it exists.
- Copy 
  - `template_app_pakfire.conf`
  - `template_module_ipfire_network_stats.conf`
  - `template_module_ipfire_services.conf`
  - optional: `template_module_linux_block_devices.conf` - if Zabbix agent version is <4.4 but you use Template OS Linux from Zabbix Server 4.4+.
  into the folder with Zabbix agent configuration (`/etc/zabbix_agentd/zabbix_agentd.d/` by default on IPFire)
- Copy `ipfire_services.pl` into the folder with Zabbix agent scripts (`/etc/zabbix_agentd/scripts/` by default on IPFire) and make it executable for user `zabbix`.
- Copy `zabbix` into the folder with sudoers configuration (`/etc/sudoers.d`) to allow Zabbix agent to run pakfire status, addonctrl and iptables as root user.
- Restart Zabbix agent.

## Zabbix configuration

No specific Zabbix configuration is required

### Macros used
|Name|Description|Default|
|----|-----------|-------|
|{$IPFIRE.SERVICE.TRIGGER} |<p>Whether Zabbix needs to trigger when an IPFire service is down. This variable can be used with context to exclude specific services.</p>|`1` |
|{$IPFIRE.ENTROPY.MIN} |<p>Minimal required entropy</p>|`128` |

#### Notes about $IPFIRE.SERVICE.TRIGGER
This template does not 'detect' if you have manually disabled a service in IPFire, so by default it will alarm you when any service is down. This is done on purpose so that you will also be notified if a service is unintentionly disabled.

To disable the trigger for a specific service (because it is disabled or you just don't want notifications about that service) add a host macro `{$IPFIRE.SERVICE.TRIGGER:"<service>"}` to the IPFire host and set it to `0`. 

For example to disable the OpenVPN service trigger add `{$IPFIRE.SERVICE.TRIGGER:"openvpn"}` to the host. Check the discovered IPFire service item-keys for the correct service-name of each service.

## Credits

[Alexander Koch](https://community.ipfire.org/t/looking-for-the-zabbix-agent-template/1459/2) for the app Pakfire template.

[IPFire Team](https://www.ipfire.org) for the IPFire services.cgi script which is used as a base for the ipfire_services.pl script included here.

## Feedback

Please report any issues with the template at https://github.com/RobinR1/zbx-template-ipfire/issues