# Deploy a Production Ready Kubernetes Cluster
# test commit
![Kubernetes Logo](https://raw.githubusercontent.com/kubernetes-sigs/kubespray/master/docs/img/kubernetes-logo.png)

If you have questions, check the documentation at [kubespray.io](https://kubespray.io) and join us on the [kubernetes slack](https://kubernetes.slack.com), channel **\#kubespray**.
You can get your invite [here](http://slack.k8s.io/)

- Can be deployed on **[AWS](docs/aws.md), GCE, [Azure](docs/azure.md), [OpenStack](docs/openstack.md), [vSphere](docs/vsphere.md), [Equinix Metal](docs/equinix-metal.md) (bare metal), Oracle Cloud Infrastructure (Experimental), or Baremetal**
- **Highly available** cluster
- **Composable** (Choice of the network plugin for instance)
- Supports most popular **Linux distributions**
- **Continuous integration tests**

## Quick Start

Below are several ways to use Kubespray to deploy a Kubernetes cluster.

### Ansible

#### Usage

Install Ansible according to [Ansible installation guide](/docs/ansible.md#installing-ansible)
then run the following steps:

```ShellSession
# Copy ``inventory/sample`` as ``inventory/mycluster``
cp -rfp inventory/sample inventory/mycluster

# Update Ansible inventory file with inventory builder
declare -a IPS=(192.168.88.211 192.168.88.220 192.168.88.221 192.168.88.223 192.168.88.224)
CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}

# Review and change parameters under ``inventory/mycluster/group_vars``
cat inventory/mycluster/group_vars/all/all.yml
cat inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml

# Clean up old Kubernetes cluster with Ansible Playbook - run the playbook as root
# The option `--become` is required, as for example cleaning up SSL keys in /etc/,
# uninstalling old packages and interacting with various systemd daemons.
# Without --become the playbook will fail to run!
# And be mind it will remove the current kubernetes cluster (if it's running)!
ansible-playbook -i inventory/mycluster/hosts.yaml  --become --become-user=root reset.ym[text](playbooks/plugins/modules/kube.py)l

# Deploy Kubespray with Ansible Playbook - run the playbook as root
# The option `--become` is required, as for example writing SSL keys in /etc/,
# installing packages and interacting with various systemd daemons.
# Without --become the playbook will fail to run!
ansible-playbook -i inventory/mycluster/hosts.yaml  --become --become-user=root cluster.yml -u ansible -i ~/.ssh/id_rsa
```

Note: When Ansible is already installed via system packages on the control node,
Python packages installed via `sudo pip install -r requirements.txt` will go to
a different directory tree (e.g. `/usr/local/lib/python2.7/dist-packages` on
Ubuntu) from Ansible's (e.g. `/usr/lib/python2.7/dist-packages/ansible` still on
Ubuntu). As a consequence, the `ansible-playbook` command will fail with:

```raw
ERROR! no action detected in task. This often indicates a misspelled module name, or incorrect module path.
```

This likely indicates that a task depends on a module present in ``requirements.txt``.

One way of addressing this is to uninstall the system Ansible package then
reinstall Ansible via ``pip``, but this not always possible and one must
take care regarding package versions.
A workaround consists of setting the `ANSIBLE_LIBRARY`
and `ANSIBLE_MODULE_UTILS` environment variables respectively to
the `ansible/modules` and `ansible/module_utils` subdirectories of the ``pip``
installation location, which is the ``Location`` shown by running
`pip show [package]` before executing `ansible-playbook`.

A simple way to ensure you get all the correct version of Ansible is to use
the [pre-built docker image from Quay](https://quay.io/repository/kubespray/kubespray?tab=tags).
You will then need to use [bind mounts](https://docs.docker.com/storage/bind-mounts/)
to access the inventory and SSH key in the container, like this:

```ShellSession
git checkout v2.24.0
docker pull quay.io/kubespray/kubespray:v2.24.0
docker run --rm -it --mount type=bind,source="$(pwd)"/inventory/sample,dst=/inventory \
  --mount type=bind,source="${HOME}"/.ssh/id_rsa,dst=/root/.ssh/id_rsa \
  quay.io/kubespray/kubespray:v2.24.0 bash
# Inside the container you may now run the kubespray playbooks:
ansible-playbook -i /inventory/inventory.ini --private-key /root/.ssh/id_rsa cluster.yml
```

#### Collection

See [here](docs/ansible_collection.md) if you wish to use this repository as an Ansible collection

### Vagrant

For Vagrant we need to install Python dependencies for provisioning tasks.
Check that ``Python`` and ``pip`` are installed:

```ShellSession
python -V && pip -V
```

If this returns the version of the software, you're good to go. If not, download and install Python from here <https://www.python.org/downloads/source/>

Install Ansible according to [Ansible installation guide](/docs/ansible.md#installing-ansible)
then run the following step:

```ShellSession
vagrant up
```

## Documents

- [Requirements](#requirements)
- [Kubespray vs ...](docs/comparisons.md)
- [Getting started](docs/getting-started.md)
- [Setting up your first cluster](docs/setting-up-your-first-cluster.md)
- [Ansible inventory and tags](docs/ansible.md)
- [Integration with existing ansible repo](docs/integration.md)
- [Deployment data variables](docs/vars.md)
- [DNS stack](docs/dns-stack.md)
- [HA mode](docs/ha-mode.md)
- [Network plugins](#network-plugins)
- [Vagrant install](docs/vagrant.md)
- [Flatcar Container Linux bootstrap](docs/flatcar.md)
- [Fedora CoreOS bootstrap](docs/fcos.md)
- [openSUSE setup](docs/opensuse.md)
- [Downloaded artifacts](docs/downloads.md)
- [Cloud providers](docs/cloud.md)
- [OpenStack](docs/openstack.md)
- [AWS](docs/aws.md)
- [Azure](docs/azure.md)
- [vSphere](docs/vsphere.md)
- [Equinix Metal](docs/equinix-metal.md)
- [Large deployments](docs/large-deployments.md)
- [Adding/replacing a node](docs/nodes.md)
- [Upgrades basics](docs/upgrades.md)
- [Air-Gap installation](docs/offline-environment.md)
- [NTP](docs/ntp.md)
- [Hardening](docs/hardening.md)
- [Mirror](docs/mirror.md)
- [Roadmap](docs/roadmap.md)

## Supported Linux Distributions

- **Flatcar Container Linux by Kinvolk**
- **Debian** Bookworm, Bullseye, Buster
- **Ubuntu** 20.04, 22.04
- **CentOS/RHEL** 7, [8, 9](docs/centos.md#centos-8)
- **Fedora** 37, 38
- **Fedora CoreOS** (see [fcos Note](docs/fcos.md))
- **openSUSE** Leap 15.x/Tumbleweed
- **Oracle Linux** 7, [8, 9](docs/centos.md#centos-8)
- **Alma Linux** [8, 9](docs/centos.md#centos-8)
- **Rocky Linux** [8, 9](docs/centos.md#centos-8)
- **Kylin Linux Advanced Server V10** (experimental: see [kylin linux notes](docs/kylinlinux.md))
- **Amazon Linux 2** (experimental: see [amazon linux notes](docs/amazonlinux.md))
- **UOS Linux** (experimental: see [uos linux notes](docs/uoslinux.md))
- **openEuler** (experimental: see [openEuler notes](docs/openeuler.md))

Note: Upstart/SysV init based OS types are not supported.

## Supported Components

- Core
  - [kubernetes](https://github.com/kubernetes/kubernetes) v1.29.2
  - [etcd](https://github.com/etcd-io/etcd) v3.5.10
  - [docker](https://www.docker.com/) v24.0 (see [Note](#container-runtime-notes))
  - [containerd](https://containerd.io/) v1.7.13
  - [cri-o](http://cri-o.io/) v1.29.1 (experimental: see [CRI-O Note](docs/cri-o.md). Only on fedora, ubuntu and centos based OS)
- Network Plugin
  - [cni-plugins](https://github.com/containernetworking/plugins) v1.2.0
  - [calico](https://github.com/projectcalico/calico) v3.26.4
  - [cilium](https://github.com/cilium/cilium) v1.13.4
  - [flannel](https://github.com/flannel-io/flannel) v0.22.0
  - [kube-ovn](https://github.com/alauda/kube-ovn) v1.11.5
  - [kube-router](https://github.com/cloudnativelabs/kube-router) v2.0.0
  - [multus](https://github.com/k8snetworkplumbingwg/multus-cni) v3.8
  - [weave](https://github.com/weaveworks/weave) v2.8.1
  - [kube-vip](https://github.com/kube-vip/kube-vip) v0.5.12
- Application
  - [cert-manager](https://github.com/jetstack/cert-manager) v1.13.2
  - [coredns](https://github.com/coredns/coredns) v1.11.1
  - [ingress-nginx](https://github.com/kubernetes/ingress-nginx) v1.9.6
  - [krew](https://github.com/kubernetes-sigs/krew) v0.4.4
  - [argocd](https://argoproj.github.io/) v2.8.4
  - [helm](https://helm.sh/) v3.13.1
  - [metallb](https://metallb.universe.tf/)  v0.13.9
  - [registry](https://github.com/distribution/distribution) v2.8.1
- Storage Plugin
  - [cephfs-provisioner](https://github.com/kubernetes-incubator/external-storage) v2.1.0-k8s1.11
  - [rbd-provisioner](https://github.com/kubernetes-incubator/external-storage) v2.1.1-k8s1.11
  - [aws-ebs-csi-plugin](https://github.com/kubernetes-sigs/aws-ebs-csi-driver) v0.5.0
  - [azure-csi-plugin](https://github.com/kubernetes-sigs/azuredisk-csi-driver) v1.10.0
  - [cinder-csi-plugin](https://github.com/kubernetes/cloud-provider-openstack/blob/master/docs/cinder-csi-plugin/using-cinder-csi-plugin.md) v1.22.0
  - [gcp-pd-csi-plugin](https://github.com/kubernetes-sigs/gcp-compute-persistent-disk-csi-driver) v1.9.2
  - [local-path-provisioner](https://github.com/rancher/local-path-provisioner) v0.0.24
  - [local-volume-provisioner](https://github.com/kubernetes-sigs/sig-storage-local-static-provisioner) v2.5.0

## Container Runtime Notes

- Supported Docker versions are 18.09, 19.03, 20.10, 23.0 and 24.0. The *recommended* Docker version is 24.0. `Kubelet` might break on docker's non-standard version numbering (it no longer uses semantic versioning). To ensure auto-updates don't break your cluster look into e.g. the YUM  ``versionlock`` plugin or ``apt pin``).
- The cri-o version should be aligned with the respective kubernetes version (i.e. kube_version=1.20.x, crio_version=1.20)

## Requirements

- **Minimum required version of Kubernetes is v1.27**
- **Ansible v2.14+, Jinja 2.11+ and python-netaddr is installed on the machine that will run Ansible commands**
- The target servers must have **access to the Internet** in order to pull docker images. Otherwise, additional configuration is required (See [Offline Environment](docs/offline-environment.md))
- The target servers are configured to allow **IPv4 forwarding**.
- If using IPv6 for pods and services, the target servers are configured to allow **IPv6 forwarding**.
- The **firewalls are not managed**, you'll need to implement your own rules the way you used to.
    in order to avoid any issue during deployment you should disable your firewall.
- If kubespray is run from non-root user account, correct privilege escalation method
    should be configured in the target servers. Then the `ansible_become` flag
    or command parameters `--become or -b` should be specified.

Hardware:
These limits are safeguarded by Kubespray. Actual requirements for your workload can differ. For a sizing guide go to the [Building Large Clusters](https://kubernetes.io/docs/setup/cluster-large/#size-of-master-and-master-components) guide.

- Master
  - Memory: 1500 MB
- Node
  - Memory: 1024 MB

## Network Plugins

You can choose among ten network plugins. (default: `calico`, except Vagrant uses `flannel`)

- [flannel](docs/flannel.md): gre/vxlan (layer 2) networking.

- [Calico](https://docs.tigera.io/calico/latest/about/) is a networking and network policy provider. Calico supports a flexible set of networking options
    designed to give you the most efficient networking across a range of situations, including non-overlay
    and overlay networks, with or without BGP. Calico uses the same engine to enforce network policy for hosts,
    pods, and (if using Istio and Envoy) applications at the service mesh layer.

- [cilium](http://docs.cilium.io/en/latest/): layer 3/4 networking (as well as layer 7 to protect and secure application protocols), supports dynamic insertion of BPF bytecode into the Linux kernel to implement security services, networking and visibility logic.

- [weave](docs/weave.md): Weave is a lightweight container overlay network that doesn't require an external K/V database cluster.
    (Please refer to `weave` [troubleshooting documentation](https://www.weave.works/docs/net/latest/troubleshooting/)).

- [kube-ovn](docs/kube-ovn.md): Kube-OVN integrates the OVN-based Network Virtualization with Kubernetes. It offers an advanced Container Network Fabric for Enterprises.

- [kube-router](docs/kube-router.md): Kube-router is a L3 CNI for Kubernetes networking aiming to provide operational
    simplicity and high performance: it uses IPVS to provide Kube Services Proxy (if setup to replace kube-proxy),
    iptables for network policies, and BGP for ods L3 networking (with optionally BGP peering with out-of-cluster BGP peers).
    It can also optionally advertise routes to Kubernetes cluster Pods CIDRs, ClusterIPs, ExternalIPs and LoadBalancerIPs.

- [macvlan](docs/macvlan.md): Macvlan is a Linux network driver. Pods have their own unique Mac and Ip address, connected directly the physical (layer 2) network.

- [multus](docs/multus.md): Multus is a meta CNI plugin that provides multiple network interface support to pods. For each interface Multus delegates CNI calls to secondary CNI plugins such as Calico, macvlan, etc.

- [custom_cni](roles/network-plugin/custom_cni/) : You can specify some manifests that will be applied to the clusters to bring you own CNI and use non-supported ones by Kubespray.
  See `tests/files/custom_cni/README.md` and `tests/files/custom_cni/values.yaml`for an example with a CNI provided by a Helm Chart.

The network plugin to use is defined by the variable `kube_network_plugin`. There is also an
option to leverage built-in cloud provider networking instead.
See also [Network checker](docs/netcheck.md).

## Ingress Plugins

- [nginx](https://kubernetes.github.io/ingress-nginx): the NGINX Ingress Controller.

- [metallb](docs/metallb.md): the MetalLB bare-metal service LoadBalancer provider.

## Community docs and resources

- [kubernetes.io/docs/setup/production-environment/tools/kubespray/](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)
- [kubespray, monitoring and logging](https://github.com/gregbkr/kubernetes-kargo-logging-monitoring) by @gregbkr
- [Deploy Kubernetes w/ Ansible & Terraform](https://rsmitty.github.io/Terraform-Ansible-Kubernetes/) by @rsmitty
- [Deploy a Kubernetes Cluster with Kubespray (video)](https://www.youtube.com/watch?v=CJ5G4GpqDy0)

## Tools and projects on top of Kubespray

- [Digital Rebar Provision](https://github.com/digitalrebar/provision/blob/v4/doc/integrations/ansible.rst)
- [Terraform Contrib](https://github.com/kubernetes-sigs/kubespray/tree/master/contrib/terraform)
- [Kubean](https://github.com/kubean-io/kubean)

## CI Tests

[![Build graphs](https://gitlab.com/kargo-ci/kubernetes-sigs-kubespray/badges/master/pipeline.svg)](https://gitlab.com/kargo-ci/kubernetes-sigs-kubespray/-/pipelines)

CI/end-to-end tests sponsored by: [CNCF](https://cncf.io), [Equinix Metal](https://metal.equinix.com/), [OVHcloud](https://www.ovhcloud.com/), [ELASTX](https://elastx.se/).

See the [test matrix](docs/test_cases.md) for details.
