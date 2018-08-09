## container-diagnostic-tools

Tools to 

 - cross ping / tcp / udp connectivity check
 - capture traffic
 - inject traffic
 - debug processes

This is normally run as a privileged container on the
node, mounting the network namespaces. It can then,
given another Pod name, 'enter' it.

## Usage

The motivation is to run this under Kubernetes as:

```
---
apiVersion: v1
kind: Pod
metadata:
  name: debug
spec:
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

## License

The container is released under Apache 2.0 license.
The individuals files within it vary.
