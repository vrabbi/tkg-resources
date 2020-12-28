# Discalaimer
* This folder contains some edited manifests to enhance the capabilities of TKG.
* All of these filesare experimental and should not be used in production without adequate testing and validations
* All files here are my own POC examples and are not official manifests supported or maintained by VMware

# Contents
1. Configuration for a new plan called "complex"
   * the complex plan creates 3 Machine Deployments. This can be used if you need workers of different sizes
   * currently CAPV and TKG do not support Failure Domains. when they do this could be used to enable such use cases as well
2. Automated Installations at cluster creation
    * Automatic installation of MetalLB or KubeVIP to provide SVC type LB in a vSphere TKG cluster
    * Automatic installation of Contour
    * Automatic installation of Kyverno
    * Automatic Creation of Kyverno Auditing Policies following the Kubernetes Security best practices
    * Automatic Creation of Kyverno Enforced Policies following the Kubernetes Security best practices
    * Automatic installation of Metrics Server
    * Automatic installation of the kube-prometheus-stack monitoring suite (Prometheus, Alert Manager, Node Exporter and Grafana + 24 base dashboards for monitoring your cluster)
    * Automatic installation of KubeApps
    * Automatic installation of the official TKG extensions for contour, prometheus and grafana
    * automatic installation of the OSS harbor installation

# Usage Notes
## Complex Plan Enablement
1. the plan file should be added in the tkg/providers/infrastructure-vsphere/v0.7.1/ location on your workstation where you have installed TKG CLI
2. in order to use this plan you also must update the overlay.yaml file in the directory tkg/providers/infrastructure-vsphere/v0.7.1/ytt with the file provided here in the same location.
3. you also must add the vsphere-overlay.yaml file contents into the same file on your workstation in the tkg/providers/infrastructure-vsphere/ytt/ directory
## Automated Installations
1. In order to use the automatic installation options add the 04_user_customizations folder from this repo into the following path on your workstation .tkg/providers/ytt/
2. You must also add the variables in the config_default.yaml file under the providers folder in this repo into the same file on your workstation
3. You can set the values of these variables either in this file, in the .tkg/config.yaml file or as variables when running a tkg create cluster command

## Example command setting automatic installations and using the complex plan at runtime together with the new autoscaling option to create a robust HA cluster
```
ENABLE_OSS_MONITORING_STACK=true ENABLE_OSS_CONTOUR=true \
ENABLE_SVC_LB_METALLB=true METALLB_VIP_RANGE=10.0.1.50-10.0.1.60 \
INSTALL_KYVERNO=true KYVERNO_AUDIT_BASELINE=true \
ENABLE_METRICS_SERVER=true \
VSPHERE_WORKER_NUM_CPUS_1=4 VSPHERE_WORKER_MEM_MIB_1=8192 VSPHERE_WORKER_DISK_GIB_1=80 \
VSPHERE_WORKER_NUM_CPUS_1=8 VSPHERE_WORKER_MEM_MIB_1=16284 VSPHERE_WORKER_DISK_GIB_1=120 \
AUTOSCALER_MIN_SIZE_0=2 AUTOSCALER_MAX_SIZE_0=20 \
AUTOSCALER_MIN_SIZE_1=2 AUTOSCALER_MAX_SIZE_1=10 \
AUTOSCALER_MIN_SIZE_2=1 AUTOSCALER_MAX_SIZE_2=5 \
tkg create cluster tkg-cls-01 --plan complex --vsphere-controlplane-endpoint=tkg-cls-01.vrabbi.cloud --controlplane-machine-count 3 --enable-cluster-options autoscaler
```

