## container-diagnostic-tools

Tools to 

 - cross ping / tcp / udp connectivity check
 - capture traffic
 - inject traffic
 - debug processes

This is normally run as a privileged container on the
node, mounting the network namespaces. It can then,
given another Pod name, 'enter' it.

The container is released under Apache 2.0 license.
The individuals files within it vary.
