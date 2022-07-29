# Template App IPFire by Zabbix Agent Active

## Overview

For Zabbix version: 5.4

This template-set monitors an IPFire appliance/instance and supports monitoring of:
- IPFire general stats (Available entropy, state of RNG)
- IPFire services (default IPFire services and possible Addon services)
- Pakfire status (Installed version, Available update(s))
- Network stats (Line quality, Open Connections, Firewall hits)

Use in conjunction with a default Template OS Linux-template for CPU/Memory/Storage monitoring of the IPFire appliance/instance.

This template was created for:

- IPFire 2.27 - Core update 170

**Warning**: This template will *NOT* work on earlier versions of IPFire due to changes to the Zabbix Agent addon.

Use [v0.1](https://github.com/RobinR1/zbx-template-ipfire/releases/tag/0.1) of this template for older versions of IPFire.

## Setup

- Install IPFire addon `zabbix_agentd` using Pakfire
- Remove `userparameter_pakfire.conf` from the folder with Zabbix agent configuration, if it exists.
- Make sure the IPFire builtin specific userparameters are enabled in `/etc/zabbix_agentd/zabbix_agentd.conf` (which should be by default)
- Copy `template_ipfire_services.conf` into the folder with Zabbix agent configuration (`/etc/zabbix_agentd/zabbix_agentd.d/` on IPFire)
- Copy `ipfire_services.pl` into the folder with Zabbix agent scripts (`/etc/zabbix_agentd/scripts/` on IPFire) and make it executable for user `zabbix`.
- Copy `zabbix_agentd_user` into the folder with sudoers configuration (`/etc/sudoers.d`) to allow Zabbix agent to run `addonctrl` as root user.
- Restart Zabbix agent.

## Zabbix configuration

No specific Zabbix configuration is required

### Macros used
|Name|Description|Default|
|----|-----------|-------|
|{$IPFIRE.CONN_MAX} |<p>Max percentage of max open connections used before triggering warning</p>|`95` |
|{$IPFIRE.CONN_MAX_RESOLVE} |<p>Percentage of max open connections used before resolving trigger</p>|`85` |
|{$IPFIRE.ENTROPY.MIN} |<p>Minimal required entropy</p>|`128` |
|{$IPFIRE.FW_CHAIN.MATCHES} |<p>Only discover firewall chains matching this regex</p>|`^.*$` |
|{$IPFIRE.FW_CHAIN.NOT_MATCHES} |<p>Do not discover firewall chains matching this regex</p>|`CHANGE_IF_NEEDED` |
|{$IPFIRE.SERVICE.TRIGGER} |<p>Whether Zabbix needs to trigger when an IPFire service is down. This variable can be used with context to exclude specific services.</p>|`1` |
|{$IPFIRE.SERVICENAME.MATCHES} |<p>All services matching this regex will be discovered</p>|`^.*$` |
|{$IPFIRE.SERVICENAME.NOT_MATCHES} |<p>Services matching this regex will not be discovered</p>|`CHANGE_IF_NEEDED` |

#### Notes about $IPFIRE.SERVICE.TRIGGER
This template does not 'detect' if you have manually disabled a service in IPFire, so by default it will alarm you when any service is down. This is done on purpose so that you will also be notified if a service is unintentionly disabled.

To disable the trigger for a specific service (because it is disabled or you just don't want notifications about that service) add a host macro `{$IPFIRE.SERVICE.TRIGGER:"<service>"}` to the IPFire host and set it to `0`. 

For example to disable the OpenVPN service trigger add `{$IPFIRE.SERVICE.TRIGGER:"openvpn"}` to the host. Check the discovered IPFire service item-keys for the correct service-name of each service.

Or you could opt to use the variables `{$IPFIRE.SERVICENAME.MATCHES}` and/or `{$IPFIRE.SERVICENAME.NOT_MATCHES}` to filter out services
you don't want to be monitored at all.

## Credits

[Alexander Koch](https://community.ipfire.org/t/looking-for-the-zabbix-agent-template/1459/2) for the app Pakfire template.

[IPFire Team](https://www.ipfire.org) for the IPFire distro and for accepting my contributions to allow easier/better monitoring using Zabbix Agent.

## Feedback

Please report any issues with the template at https://github.com/RobinR1/zbx-template-ipfire/issues