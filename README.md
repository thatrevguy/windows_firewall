# windows_firewall

####Table of Contents

1. [Overview - What is windows_firewall module?](#overview)
2. [Module Description - What does this module do?](#module-description)
3. [Setup - Basics of getting started with windows_firewall](#setup)
    * [Beginning with windows_firewall - Installation](#beginning-with-windows_firewall)
    * [Configuring a rule - Basic options for getting started](#configure-a-rule)
4. [Usage - Classes, defined types, and their parameters available for configuration](#usage)
    * [Classes and Defined Types](#classes-and-defined-types)
        * [Class: windows_firewall](#class-windows_firewall)
        * [Defined Type: windows_firewall::rule](#defined-type-rule)
5. [Implementation - An under-the-hood peek at what this module is doing](#implementation)
    * [Templates](#templates)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Release Notes - Notes on the most recent updates to the module](#release-notes)

##Overview
This is a module that will manage the Microsoft Windows Firewall and its rules.

##Module Description

The windows_firewall module will primarily manage the state of the windows firewall application on your windows system. Optionally it will also
allow you to configure any rules that you need to have in place.

##Setup

###What windows_firewall affects:

* windows firewall service and corresponding Windows Registry keys
* windows registry keys and values for any defined rules

###Beginning with windows_firewall

The windows_firewall resource allows you to manage the firewall profile state and their policy.

    class { 'windows_firewall': 
      profile_state => 'on',
      in_policy     => 'BlockInbound',
      out_policy    => 'AllowOutbound',
    }

Once the windows firewall is managed you can start managing the rules and exceptions within it.

    windows_firewall::rule { 'ICMPv4 Allow Echo':
      ensure               => present,
      direction            => 'In',
      action               => 'Allow',
      enabled              => 'True',
      protocol             => 'ICMPv4',
      description          => 'Inbound rule for ICMPv4 echo.',
      icmp_types_and_codes => '8:*',
    }

##Usage

###Classes and Defined Types:

####Class: `windows_firewall`

**Parameters within `windows_firewall`:**

#####`profile_state`
Determines whether or not service profiles are enabled. If not included, module will assume that windows firewall profiles should be enabled. Valid values are 'on' and 'off'.

#####`in_policy`
Determines inbound policy for all profiles. If not included, module will assume that inbound policy is BlockInbound. Valid values are 'AllowInbound' and 'BlockInbound'.

#####`out_policy`
Determines outbound policy for all profiles. If not included, module will assume that inbound policy is AllowOutbound. Valid values are 'AllowOutbound' and 'BlockOutbound'.

###Defined Type: `windows_firewall::rule`

**Parameters within `windows_firewall::rule`:**

#####`ensure`
Determines whether or not the firewall exception is 'present' or 'absent'. Defaults to 'Present'.

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
Defines local ports to be included in rule. Defaults to '*'.

#####`remote_ports`
Defines remote ports to be included in rule. Defaults to '*'.

#####`local_addresses`
Specifies local hosts that can use this rule. Defaults to '*'.

#####`remote_addresses`
Specifies remote hosts that can use this rule. Defaults to '*'.

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

###Templates

#### [`template(windows_firewall\rule_object.ps1)`]
Loads and prepares all variables from current scope of [`windows_firewall::rule`] instance for HNetCfg consumption.

#### [`template(windows_firewall\add_rule.ps1)`]
Adds HNetCfg.FWRule object prepared by [`template(windows_firewall\rule_object.ps1)`].

#### [`template(windows_firewall\set_rule.ps1)`]
Sets rule property values prepared by [`template(windows_firewall\rule_object.ps1)`] on all matching rule names in HNetCfg.FwPolicy2.Rules. Only differing property values are updated.

#### [`template(windows_firewall\remove_rule.ps1)`]
Removes all rules with matching name property from [`template(windows_firewall\rule_object.ps1)`] in HNetCfg.FwPolicy2.Rules.

#### [`template(windows_firewall\validate_rule.ps1)`]
Returns exit code 1 if rule property values prepared by [`template(windows_firewall\rule_object.ps1)`] mismatch any rule properties with the name in HNetCfg.FwPolicy2.Rules.

#### [`template(windows_firewall\prune_rule.ps1)`]
Removes all rules with matching name property from [`template(windows_firewall\rule_object.ps1)`] in HNetCfg.FwPolicy2.Rules except for last instance.

#### [`template(windows_firewall\get_rule.ps1)`]
Returns exit code 1 if no matching rule name from [`template(windows_firewall\rule_object.ps1)`] are found in HNetCfg.FwPolicy2.Rules.

#### [`template(windows_firewall\duplicate_rule.ps1)`]
Returns exit code 1 if more than 1 matching rule name from [`template(windows_firewall\rule_object.ps1)`] are found in HNetCfg.FwPolicy2.Rules.

##Reference

###Classes
####Public Classes
* [`windows_firewall`](#class-windows_firewall): Main class of module for managing state of windows firewall profiles and their policies.

###Defined Types
####Public Types:
* [`windows_firewall::rule`] Manages configuration of firewall rules.

#Limitations
Requires at least powershell v2 on clients.

This module is tested on the following platforms:

* Windows Server 2012 R2
* Windows Server 2012
* Windows Server 2008 R2
* Windows Server 2008

#Release-Notes
Still working on auditing/reporting aspect for module.