# Manuel
### Clean
#### Master
* remove etcd dir /atomic.io/network/*
#### Minion ####
* stop services: kubelet, docker, flanneld
* ip link del dev: flannel.x, docker0, br-*
* Empty dir /var/run/flannel
### Installation ###
#### Minion ####
- install default plugins :
    - >mkdir -p /opt/cni/bin ; cd /opt/cni/bin
    - download corresponding package from https://github.com/containernetworking/cni/releases/ \
             we are using v0.2.0 on minion1
    - extract in _/opt/cni/bin/_

- install flannel multinetwork cni plugin
    - get flannelmulnw from minion1:/home/zf/patches
    - put it into _/opt/cni/bin_

- install assistant service to create multi-bridge
    - get flannelmultibridge from minion1:/home/zf/patches/
    - put it into _/usr/local/bin_

- install flanneld for multi-network
    - get flanneld from minion1:/home/zf/patches/
    - replace _/usr/bin/flanneld_
### Configuration ###
#### Master ####
- Configure etcd with a subnetwork named "master" working as management network, then configure other networks . For example
    > etcdctl set /atomic.io/network/master/config '{ "network": "10.254.0.0/16", "Backend": {"Type": "vxlan", "VNI": 1}}' \
    etcdctl set /atomic.io/network/wantest/config '{ "network": "10.13.0.0/16", "Backend": {"Type": "vxlan", "VNI": 2}}'
#### Minion ####
- Add new service  _/lib/systemd/system/flannel-multi-bridge.service_
- Update service _/etc/systemd/system/flannel-docker-bridge.service_, set EnvironmentFile as
    >[Service] \
Type=oneshot \
EnvironmentFile=/run/flannel/networks/master.env
ExecStart=/usr/local/bin/flannel-docker-bridge
-   Update configuration of flanneld service
    -   update _/etc/sysconfig/flanneld_, add 
    >FLANNEL_OPTIONS="--networks=master,wantest"
- Update _/lib/systemd/system/flanneld.service_
    - update the ExecStartPost as
    >ExecStartPost=/usr/libexec/flannel/mk-docker-opts.sh -f /run/flannel/networks/master.env -k DOCKER_NETWORK_OPTIONS -d /run/flannel/docker
- Update _/etc/kubernetes/kubelet_
    - update KUBELET_ARGS to set network-plugin configuration
    >KUBELET_ARGS="--config=/etc/kubernetes/manifests --cadvisor-port=4194  --hostname-override=k8-olpiogq2f6-0-csnexxkfs7i7-kube-minion-r6gorbl75kxj --network-plugin=cni --network-plugin-dir=/etc/cni/net.d"
- Put _flannelmulnw.conf_ in _/etc/cni/net.d/_. The content of the file is of NO significance, while format of the file to be kept
- Restart flanneld.service --> docker.service --> kubelet.service, reload may be required.
