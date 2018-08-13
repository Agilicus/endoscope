## container-diagnostic-tools

## Usage

### Ping

Ping all pods in a namespace, from a given one, in graphical form:
`scope -n NAMESPACE -p SRC-POD ping -c0 -a -g`
![img](img/graph-ping.png)

### Shell

Obtain a shell in the network namespace of a given pod:
`scope -n NAMESPACE -p SRC-POD shell`

Run 'ip address' command in the network namespace of a given pod:
`scope -n NAMESPACE -p SRC-POD shell ip address`

### Launch

Launch a debug pod and leave it running, with access to the PID/network
namespace of a given pod:
`scope -n NAMESPACE -p SRC-POD launch`

### Cleanup

Cleanup a/all the debug-* pods in a namespace.

`scope -n NAMESPACE -p all cleanup` -- remove all the debug-*
`scope -n NAMESPACE -p POD cleanup` -- remove the debug-POD

The above commands, unless run with '-t' for terminate, leave the
debug- pod around after starting (for better interactive performance).

### Pids

Obtain the list of pids (in host coordinate terms) for the given
container. This is useful to e.g. attach gdb or strace:

`scope -n NAMESPACE -p POD pids`

### Strace

strace a pid (default first pid in Pod).

`scope -n NAMESPACE -p POD strace [-p #] [-e expr]`

If 'expr' is specified, show only those syscalls (see strace(1)).
If -p # is specified (e.g. as the result of the 'pids' command), use
this pid instead of the first.

### gdb

Debug (gdb) a pid (default first pid in Pod).

`scope -n NAMESPACE -p POD gdb [-p #]`

Runs the debugger, privileged, in the pid namespace, attached.

## Container

The container here (cr.agilicus.com/utilities/endoscope) contains tools to

 - cross ping / tcp / udp connectivity check
 - capture traffic
 - inject traffic
 - debug processes

This is normally run as a privileged container on the
node, mounting the network namespaces. It can then,
given another Pod name, 'enter' it. It works in conjuncton
with the python script 'scope'.

The motivation is to run this under Kubernetes as:

```
---
apiVersion: v1
kind: Pod
metadata:
  name: debug
spec:
  nodeName: XXXX
  hostPID: true
  imagePullSecrets:
    - name: regcred
  containers:
  - name: debug
    securityContext:
      privileged: true
    image: cr.agilicus.com/utilities/container-diagnostic-tools:latest
    volumeMounts:
    - mountPath: /var/run/cri.sock
      name: crisock
    - mountPath: /run/docker/netns
      name: netns
  volumes:
  - hostPath:
      path: /var/run/dockershim.sock
      type: ""
    name: crisock
  - hostPath:
      path: /var/run/docker/netns
      type: ""
    name: netns
```

and thus attach to a Pod in XXXX w/ 'nsenter -n -t <PID>'.

## License

The container is released under Apache 2.0 license.
The individuals files within it vary.
