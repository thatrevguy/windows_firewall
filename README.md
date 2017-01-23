# windows_firewall

####Table of Contents

1. [Overview - What is windows_firewall module?](#overview)
2. [Module Description - What does this module do?](#module-description)
    * [Rule Enforcement Process - What is it thinking?](#rule-enforcement-process)
3. [Setup - Basics of getting started with windows_firewall](#setup)
    * [Beginning with windows_firewall - Installation](#beginning-with-windows_firewall)
    * [Tools - Stuff that will help](#tools)
4. [Usage - Classes, defined types, and their parameters available for configuration](#usage)
    * [Classes](#classes)
    * [Rule Parameters](#rule-parameters)
5. [Implementation - An under-the-hood peek at what this module is doing](#implementation)
    * [Custom Types](#custom-types)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Release Notes - Notes on the most recent updates to the module](#release-notes)

##Overview
This is a module that will manage the Microsoft Windows Firewall and its rules.

##Module Description

The windows_firewall module will primarily manage the state of the windows firewall application on your windows system. Also applies rules defined in hiera data source.

###Rule Enforcement Process
    +---------------------------------------------------------------------------------+
    |                                                                                 |
    |                                                +--+                             |
    |                                                v  |                             |
    |                               +-------------------+                             |
    |                   REMOVE      |Rule Definitions|         ADD                    |
    |                   +-----------+----------------+-----------+                    |
    |                   v                                        v                    |
    | +-------------------------------------+ +-------------------------------------+ |
    | |                                     | |                                     | |
    | | +------------------+ N  +--------+  | | +------------------+ N  +--------+  | |
    | | |Rule Name Present?+--->|  Done! |  | | |Rule Name Present?+--->|Add Rule|  | |
    | | +--------+---------+    +--------+  | | +--------+---------+    +--------+  | |
    | |          |                   ^      | |          |                          | |
    | |        Y |                   |      | |        Y |                          | |
    | |          v                   |      | |          v                          | |
    | | +----------------------------+---+  | | +--------------------------------+  | |
    | | |Remove all matching rule names. |  | | |Do all matching rule names match|  | |
    | | +--------------------------------+  | | |definition property values?     |  | |
    | |                                     | | +--------+--------------+--------+  | |
    | +-------------------------------------+ |          |              |           | |
    |                                         |         Y|             N|           | |
    +-------------+-------------------------+ |          v              v           | |
                  |                         | | +-------------+    +--------------+ | |
                  |                         | | |Are matching |    |Set property  | | |
                  v                         | | |rule names   |    |values for all| | |
    +---------------------------+           | | |greater than |<---+matching rule | | |
    |Disable all rule names that|           | | |one?         |    |names.        | | |
    |do not exist in client's   |           | | +-+------+----+    +--------------+ | |
    |stored catalog.            |           | |   |      |                          | |
    +---------------------------+           | |  N|     Y|                          | |
                                            | |   |      v                          | |
                                            | |   |  +----------------------------+ | |
                                            | |   |  | De-duplicate matching rule | | |
                                            | |   |  | names.                     | | |
                                            | |   |  +---+------------------------+ | |
                                            | |   |      |                          | |
                                            | |   |      |                          | |
                                            | |   v      v                          | |
                                            | | +----------+                        | |
                                            | | |   Done!  |                        | |
                                            | | +----------+                        | |
                                            | |                                     | |
                                            | +-------------------------------------+ |
                                            |                                         |
                                            +-----------------------------------------+

##Setup

###What windows_firewall affects:

* windows firewall profile and policy.
* windows firewall rules.

###Beginning with windows_firewall

The windows_firewall resource allows you to manage the firewall profile state and their policy.
```puppet
class { 'windows_firewall': 
    profile_state => 'on',
    in_policy     => 'BlockInbound',
    out_policy    => 'AllowOutbound',
    rule_key      => 'windows_networks',
    purge_rules   => true,
}
```
Windows_firewall loads rules from hiera stored as hashes using key defined in 'rule_key'.

Rules can be defined using json or yaml data resource. Below is a json example:
```json
{
  "windows_networks": {
    "Rule 1": {
      "description": "This is rule 1.",
      "remote_addresses": "10.1.2.3,10.7.8.9",
      "local_ports": "1000,1010"
    },
    "Rule 2": {
      "description": "This is rule 2.",
      "remote_addresses": "10.4.5.6-10.4.5.150",
      "local_ports": "2000-2500"
    },
    "Rule 3": {
      "description": "This is rule 3.",
      "remote_addresses": "10.1.100.1/24",
      "local_ports": "3030",
      "interfaces": "Ethernet"
    }
  }
}
```

###Tools

####`tools\generate_rule_definitions.ps1`
Powershell script for generating JSON baseline rules from pre-existing enabled advfirewall rules on a Windows system.

####`hieradata\base_windows_rules.json`
A pre-generated json hiera resource to get started.

##Usage

###Classes

####`windows_firewall`

**Parameters within `windows_firewall`:**

#####`profile_state`
Determines whether or not service profiles are enabled. If not included, module will assume that windows firewall profiles should be enabled. Valid values are 'on' and 'off'.

#####`in_policy`
Determines inbound policy for all profiles. If not included, module will assume that inbound policy is BlockInbound. Valid values are 'AllowInbound' and 'BlockInbound'.

#####`out_policy`
Determines outbound policy for all profiles. If not included, module will assume that outbound policy is AllowOutbound. Valid values are 'AllowOutbound' and 'BlockOutbound'.

#####`rule_key`
Determines what key name is used to load firewall rules from hiera.

#####`purge_rules`
Determines whether or not to purge unmanaged firewall_rule resources on system.
Valid values are 'true' and 'false'.

###Rule Parameters

**Available parameters for rule definition:**

#####`ensure`
Determines whether or not the firewall exception is 'present' or 'absent'. Defaults to 'present'.

#####`description`
A description of the rule. Defaults to ''.

#####`application_name`
Sets path for application rule applies to. Defaults to ''.

#####`service_name`
Sets name for service rule applies to. Defaults to ''.

#####`protocol`
Sets the protocol to be included in rule. Following protocol names are valid:

* 'ICMPv4'
* 'IGMP'
* 'TCP' (Default)
* 'UDP'
* 'IPv6'
* 'IPv6Route'
* 'IPv6Frag'
* 'GRE'
* 'ICMPv6'
* 'IPv6NoNxt'
* 'IPv6Opts'
* 'VRRP'
* 'PGM'
* 'L2TP'

#####`local_ports`
Defines local ports to be included in rule. Defaults to ''.

#####`remote_ports`
Defines remote ports to be included in rule. Defaults to ''.

#####`local_addresses`
Specifies local hosts that can use this rule. Defaults to ''.

#####`remote_addresses`
Specifies remote hosts that can use this rule. Defaults to ''.

#####`icmp_types_and_codes`
Specifies types and codes if protocol is ICMP. Format is 'Type:Code'. Do not attempt to set if protocol is not ICMP.

#####`direction`
Sets the direction of the exception rule, either: 'In' or 'Out'. Defaults to 'In'.

#####`interfaces`
Sets network interfaces rule applies to. Accepts a comma delimited list of network interface friendly names. Defaults to ''.

#####`interface_types`
Sets interface types rule applies to. Following interface types are valid:

* 'Wireless'
* 'Lan'
* 'RemoteAccess'
* 'All' (Default)

Multiple types can be set by comma delimitation.

#####`enabled`
Determines whether the exception is enabled, either: 'True' or 'False'. Defaults to 'True'.

#####`grouping`
Defines the group name rule belongs to. Defaults to ''.

#####`profiles`
Sets profiles rule applies to. Following profile names are valid:

* 'Domain'  (Default)
* 'Private' (Default)
* 'Public'  (Default)

Multiple profiles can be set by comma delimitation.

#####`edge_traversal`
Specifies whether traffic for rule traverses an edge device, either: 'True' or 'False'. Defaults to 'False'.

#####`action`
Sets the action type of rule, either: 'Allow' or 'Block'. Defaults to 'Allow'.

#####`edge_traversal_options`
Specifies edge traversal options. Following options are valid:

* 'Block' (Default)
* 'Allow'
* 'Defer to App'
* 'Defer to User'

##Implementation

###Custom Types

#### [`firewall_rule`]
Checks for following:
* 'Puppet defined rule that does not match system rule counterpart property values.'
* 'Puppet defined rule name on system does not occur more than once.'
* 'Puppet defined rule that does not match ensured state found on system.'

```puppet
$defaults = {
    protocol               => 6,
    description            => "",
    application_name       => "",
    service_name           => "",
    local_ports            => "",
    remote_ports           => "",
    local_addresses        => "",
    remote_addresses       => "",
    icmp_types_and_codes   => "",
    direction              => 1,
    interfaces             => "",
    interface_types        => 'All',
    enabled                => true,
    grouping               => "",
    profiles               => 2147483647,
    edge_traversal         => false,
    action                 => 1,
    edge_traversal_options => 0,
}

create_resources(firewall_rule, hiera_hash('windows_networks'), $defaults)
```

##Reference

###Classes
####Public Classes
* [`windows_firewall`](#classes): Main class of module for managing state of windows firewall profiles and their policies.

##Limitations

This module is tested on the following platforms:

* Windows Server 2012 R2
* Windows Server 2012
* Windows Server 2008 R2
* Windows Server 2008

##Development
Submit issues or pull requests to [GitHub](https://github.com/hathoward/windows_firewall)

##Release-Notes
* 0.3.4 (robklg) - Fix escape characters in firewall rule name.
* 0.3.3 (amgarstang) - Remove dependency on win_facts module.
* 0.3.2 puppet notice generated on rule de-dupe.
* 0.3.0 provider and type re-written. postrun_facts dropped. purge_rules added.
* 0.2.1 updated JSON rule generator tool.
* 0.2.0 updated to ruby-centric code base. Powershell dep removed.
* 0.1.5 (pcallewaert) - fixes firewall_policy breaks facts on linux
* 0.0.8 option to update facts post configuration added
* 0.0.4 switch over to hiera to store rules
