#! /bin/bash
# FUNCTIONS USED IN THE SCRIPT
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
get_input() {
  echo -n $1
  read value
}
get_secret_input() {
  echo -n $1
  read -s value
}

#DEFAULT VALUES FOR ALL PARAMETERS
cluster_name=""
cluster_plan="dev"
autoscale_enabled="no"
control_plane_node_count=1
control_plane_disk_gb=30
control_plane_ram_mb=4096
control_plane_vcpu_count=2
md_0_min_vm_count=1
md_0_max_vm_count=1
md_0_vm_count=1
md_0_vcpu_count=2
md_0_ram_mb=4096
md_0_disk_gb=30
md_1_min_vm_count=1
md_1_max_vm_count=1
md_1_vm_count=1
md_1_vcpu_count=2
md_1_ram_mb=4096
md_1_disk_gb=30
md_2_min_vm_count=1
md_2_max_vm_count=1
md_2_vm_count=1
md_2_vcpu_count=2
md_2_ram_mb=4096
md_2_disk_gb=30
use_crs="no"
svc_lb_provider="metallb"
kubevip_lb_cidr="10.0.0.1/24"
metallb_lb_ip_range="10.0.0.1-10.0.0.253"
install_monitoring_stack="no"
monitoring_stack_type="none"
prometheus_fqdn=""
grafana_fqdn=""
grafana_password=""
install_kubeapps="no"
install_oss_cert_manager="no"
install_oss_contour="no"
kubeapps_fqdn=""
install_rancher="no"
rancher_fqdn=""
install_kyverno="no"
kyverno_create_policies="no"
kyverno_policy_type=""
kyverno_enforce_policies="no"
kyverno_audit_policies="no"
install_metrics_server="no"
install_harbor="no"
harbor_fqdn=""
harbor_password=""
attach_to_tmc="no"
tmc_api_token=""
tmc_cluster_group=""
tmc_enable_dp="no"
tmc_dp_account_name=""
cni="antrea"
k8s_version="v1.19.3"
clear
# CLUSTER NAME
while true; do
  get_input "New Cluster Name [ENTER]: "
  if [[ $value =~ ^[a-zA-Z0-9-]+$ ]]
  then
    cluster_name=$value
    break
  else
    printf "${RED}ERROR: Invalid Cluster Name - Please use alpha-numeric and dashes only${NC}\n"  
  fi
done

# CLUSTER PLAN
while true; do
  get_input "TKG Cluster Plan (dev / prod / complex) [ENTER]: "
  if [[ $value == "dev" ]] || [[ $value == "prod" ]] || [[ $value == "complex" ]]
  then
    cluster_plan=$value
    break
  else
    printf "${RED}ERROR: Invalid Choice - use either dev, prod or complex${NC}\n"
  fi
done

# VIP OR FQDN FOR API SERVER
while true; do
  get_input "Control Plane Endpoint (FQDN or IP) [ENTER]: "
  if [[ $value =~ ^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$ ]] || [[ $value =~ ^[a-zA-Z0-9][a-zA-Z0-9_-]+[.][a-zA-Z0-9._-]+[a-zA-Z0-9]$ ]]
  then
    control_plane_endpoint=$value
    break
  else
    printf "${RED}ERROR: Invalid Control Plane Endpoint - must be a valid IPv4 Address or FQDN${NC}\n"
  fi
done

# K8S VERSION
while true; do
  printf "Available Kubernetes Versions:\n- v1.17.3+vmware.2\n- v1.17.6+vmware.1\n- v1.17.9+vmware.1\n- v1.17.11+vmware.1\n- v1.17.13+vmware.1\n- v1.18.2+vmware.1\n- v1.18.3+vmware.1\n- v1.18.6+vmware.1\n- v1.18.8+vmware.1\n- v1.18.10+vmware.1\n- v1.19.1+vmware.2\n- v1.19.3+vmware.1\n"
  get_input "What version of Kubernetes do you want to install [ENTER]: "
  if [[ $value == "v1.17.11+vmware.1" ]] || [[ $value == "v1.17.13+vmware.1" ]] || [[ $value == "v1.17.3+vmware.2" ]] || [[ $value == "v1.17.6+vmware.1" ]] || [[ $value == "v1.17.9+vmware.1" ]] || [[ $value == "v1.18.10+vmware.1" ]] || [[ $value == "v1.18.2+vmware.1" ]] || [[ $value == "v1.18.3+vmware.1" ]] || [[ $value == "v1.18.6+vmware.1" ]] || [[ $value == "v1.18.8+vmware.1" ]] || [[ $value == "v1.19.1+vmware.2" ]] || [[ $value == "v1.19.3+vmware.1" ]]
  then
    k8s_version=$value
    break
  else
    printf "${RED}ERROR: Invalid Version - must be from the supported K8s versions as mentioned in the list exactly${NC}\n"
  fi
done

# CNI CHOICE
while true; do
  get_input "What CNI would you like to use (antrea / calico) [ENTER]: "
  if [[ $value == "antrea" ]] || [[ $value == "calico" ]]
  then
    cni=$value
    break
  else
    printf "${RED}ERROR: Invalid Option - Please choose antrea or calico${NC}\n"
  fi
done
# AUTO SCALING
while true; do
  get_input "Enable Autoscaling? (yes / no) [ENTER]: "
  if [[ $value == "yes" ]] || [[ $value == "no" ]]
  then
    autoscale_enabled=$value
    break
  else
     printf "${RED}ERROR: Invalid Choice - select either yes or no${NC}\n"
  fi
done
echo ""
echo "########################################"
echo "###### Control Plane Nodes Sizing ######"
echo "########################################"
echo ""
# CONTROL PLANE NODE COUNT
while true; do
  get_input "Number of Control Plane Nodes [ENTER]: "
  if [[ $value == 1 ]] || [[ $value == 3 ]] || [[ $value == 5 ]]
  then
    control_plane_node_count=$value
    break
  else
     printf "${RED}ERROR: Invalid Choice - select either 1, 3 or 5${NC}\n"
  fi
done

# CONTROL PLANE VCPU COUNT
while true; do
  get_input "Number of vCPU for Control Plane nodes [ENTER]: "
  if [[ $value =~ \d*[02468]$ ]]
  then
    control_plane_vcpu_count=$value
    break
  else
    printf "${RED}ERROR: Invalid Choice - must be an even number greater than 0${NC}\n"
  fi
done
# CONTROL PLANE RAM GB
while true; do
  get_input "Ammount of RAM (GB) for Control Plane nodes [ENTER]: "
  if [[ $value =~ ^[1-9][0-9]*$ ]] && [[ $value -gt 1 ]]
  then
    control_plane_ram_mb=$(( $value * 1024 ))
    break
  else
    printf "${RED}ERROR: Invalid Choice - must be a number greater than 1${NC}\n"
  fi
done
# CONTROL PLANE STORAGE SIZE GB
while true; do
  get_input "Ammount of Storage (GB) for Control Plane nodes [ENTER]: "
  if [[ $value =~ ^[1-9][0-9]*$ ]] && [[ $value -gt 25 ]]
  then
    control_plane_disk_gb=$value
    break
  else
    printf "${RED}ERROR: Invalid Choice - must be a number greater than 25${NC}\n"
  fi
done
# MULTI MD CONFIG FOR COMPLEX PLAN
if [ $cluster_plan = "complex" ]; then
  echo ""
  echo "########################################"
  echo "####### MD-0 Worker Nodes Sizing #######"
  echo "########################################"
  echo ""
  # AUTOSCALE CONFIG FOR MD 0
  if [ $autoscale_enabled = "yes" ]; then
    # MD 0 MINIMUM VM COUNT
    while true; do
      get_input "Minimum Number of Worker nodes in MD-0 [ENTER]: "
      if [[ $value =~ ^[1-9][0-9]*$ ]]
      then
        md_0_min_vm_count=$value
        break
      else
        printf "${RED}ERROR: Invalid Choice - must be a number greater than 0${NC}\n"
      fi
    done

    # MD 0 MAXIMUM VM COUNT
    while true; do
      get_input "Maximum Number of Worker nodes in MD-0 [ENTER]: "
      if [[ $value =~ ^[1-9][0-9]*$ ]] && [[ $value -gt $md_0_min_vm_count ]]
      then
        md_0_max_vm_count=$value
        break
      else
        printf "${RED}ERROR: Invalid Choice - must be a number greater than $md_0_min_vm_count${NC}\n"
      fi
    done
  else
    # MD 0 VM COUNT WITHOUT AUTO SCALING ENABLED
    while true; do
      get_input "Number of Worker nodes in MD-0 [ENTER]: "
      if [[ $value =~ ^[1-9][0-9]*$ ]]
      then
        md_0_vm_count=$value
        break
      else
        printf "${RED}ERROR: Invalid Choice - must be a number greater than 0${NC}\n"
      fi
    done
  fi
  # MD 0 VCPU COUNT
  while true; do
    get_input "Number of vCPU for Worker nodes in MD-0 [ENTER]: "
    if [[ $value =~ \d*[02468]$ ]]
    then
      md_0_vcpu_count=$value
      break
    else
      printf "${RED}ERROR: Invalid Choice - must be an even number greater than 0${NC}\n"
    fi
  done

  # MD 0 RAM GB
  while true; do
    get_input "Ammount of RAM (GB) for Worker nodes in MD-0 [ENTER]: "
    if [[ $value =~ ^[1-9][0-9]*$ ]] && [[ $value -gt 1 ]]
    then
      md_0_ram_mb=$(( $value * 1024 ))
      break
    else
      printf "${RED}ERROR: Invalid Choice - must be a number greater than 1${NC}\n"
    fi
  done

  # MD 0 STORAGE SIZE GB
  while true; do
    get_input "Ammount of Storage (GB) for Worker nodes in MD-0 [ENTER]: "
    if [[ $value =~ ^[1-9][0-9]*$ ]] && [[ $value -gt 25 ]]
    then
      md_0_disk_gb=$value
      break
    else
      printf "${RED}ERROR: Invalid Choice - must be a number greater than 25${NC}\n"
    fi
  done

  echo ""
  echo "########################################"
  echo "####### MD-1 Worker Nodes Sizing #######"
  echo "########################################"
  echo ""
  # AUTOSCALE CONFIG FOR MD 1
  if [ $autoscale_enabled = "yes" ]; then
    # MD 1 MINIMUM VM COUNT
    while true; do
      get_input "Minimum Number of Worker nodes in MD-1 [ENTER]: "
      if [[ $value =~ ^[1-9][0-9]*$ ]]
      then
        md_1_min_vm_count=$value
        break
      else
        printf "${RED}ERROR: Invalid Choice - must be a number greater than 0${NC}\n"
      fi
    done

    # MD 1 MAXIMUM VM COUNT
    while true; do
      get_input "Maximum Number of Worker nodes in MD-1 [ENTER]: "
      if [[ $value =~ ^[1-9][0-9]*$ ]] && [[ $value -gt $md_1_min_vm_count ]]
      then
        md_1_max_vm_count=$value
        break
      else
        printf "${RED}ERROR: Invalid Choice - must be a number greater than $md_1_min_vm_count${NC}\n"
      fi
    done
  else
    # MD 1 VM COUNT WITHOUT AUTO SCALING ENABLED
    while true; do
      get_input "Number of Worker nodes in MD-1 [ENTER]: "
      if [[ $value =~ ^[1-9][0-9]*$ ]]
      then
        md_1_vm_count=$value
        break
      else
        printf "${RED}ERROR: Invalid Choice - must be a number greater than 0${NC}\n"
      fi
    done
  fi
  # MD 1 VCPU COUNT
  while true; do
    get_input "Number of vCPU for Worker nodes in MD-1 [ENTER]: "
    if [[ $value =~ \d*[02468]$ ]]
    then
      md_1_vcpu_count=$value
      break
    else
      printf "${RED}ERROR: Invalid Choice - must be an even number greater than 0${NC}\n"
    fi
  done

  # MD 1 RAM GB
  while true; do
    get_input "Ammount of RAM (GB) for Worker nodes in MD-1 [ENTER]: "
    if [[ $value =~ ^[1-9][0-9]*$ ]] && [[ $value -gt 1 ]]
    then
      md_1_ram_mb=$(( $value * 1024 ))
      break
    else
      printf "${RED}ERROR: Invalid Choice - must be a number greater than 1${NC}\n"
    fi
  done

  # MD 1 STORAGE SIZE GB
  while true; do
    get_input "Ammount of Storage (GB) for Worker nodes in MD-1 [ENTER]: "
    if [[ $value =~ ^[1-9][0-9]*$ ]] && [[ $value -gt 25 ]]
    then
      md_1_disk_gb=$value
      break
    else
      printf "${RED}ERROR: Invalid Choice - must be a number greater than 25${NC}\n"
    fi
  done

  echo ""
  echo "########################################"
  echo "####### MD-2 Worker Nodes Sizing #######"
  echo "########################################"
  echo ""
  # AUTOSCALE CONFIG FOR MD 2
  if [ $autoscale_enabled = "yes" ]; then
    # MD 2 MINIMUM VM COUNT
    while true; do
      get_input "Minimum Number of Worker nodes in MD-2 [ENTER]: "
      if [[ $value =~ ^[1-9][0-9]*$ ]]
      then
        md_2_min_vm_count=$value
        break
      else
        printf "${RED}ERROR: Invalid Choice - must be a number greater than 0${NC}\n"
      fi
    done

    # MD 2 MAXIMUM VM COUNT
    while true; do
      get_input "Maximum Number of Worker nodes in MD-2 [ENTER]: "
      if [[ $value =~ ^[1-9][0-9]*$ ]] && [[ $value -gt $md_2_min_vm_count ]]
      then
        md_2_max_vm_count=$value
        break
      else
        printf "${RED}ERROR: Invalid Choice - must be a number greater than $md_2_min_vm_count${NC}\n"
      fi
    done
  else
    # MD 2 VM COUNT WITHOUT AUTO SCALING ENABLED
    while true; do
      get_input "Number of Worker nodes in MD-2 [ENTER]: "
      if [[ $value =~ ^[1-9][0-9]*$ ]]
      then
        md_2_vm_count=$value
        break
      else
        printf "${RED}ERROR: Invalid Choice - must be a number greater than 0${NC}\n"
      fi
    done
  fi
  # MD 2 VCPU COUNT
  while true; do
    get_input "Number of vCPU for Worker nodes in MD-2 [ENTER]: "
    if [[ $value =~ \d*[02468]$ ]]
    then
      md_2_vcpu_count=$value
      break
    else
      printf "${RED}ERROR: Invalid Choice - must be an even number greater than 0${NC}\n"
    fi
  done

  # MD 2 RAM GB
  while true; do
    get_input "Ammount of RAM (GB) for Worker nodes in MD-2 [ENTER]: "
    if [[ $value =~ ^[1-9][0-9]*$ ]] && [[ $value -gt 1 ]]
    then
      md_2_ram_mb=$(( $value * 1024 ))
      break
    else
      printf "${RED}ERROR: Invalid Choice - must be a number greater than 1${NC}\n"
    fi
  done

  # MD 2 STORAGE SIZE GB
  while true; do
    get_input "Ammount of Storage (GB) for Worker nodes in MD-2 [ENTER]: "
    if [[ $value =~ ^[1-9][0-9]*$ ]] && [[ $value -gt 25 ]]
    then
      md_2_disk_gb=$value
      break
    else
      printf "${RED}ERROR: Invalid Choice - must be a number greater than 25${NC}\n"
    fi
  done
else
  echo ""
  echo "########################################"
  echo "#########  Worker Nodes Sizing #########"
  echo "########################################"
  echo ""
  
  if [ $autoscale_enabled = "yes" ]; then
    # MD 0 MINIMUM VM COUNT
    while true; do
      get_input "Minimum Number of Worker nodes [ENTER]: "
      if [[ $value =~ ^[1-9][0-9]*$ ]]
      then
        md_0_min_vm_count=$value
        break
      else
        printf "${RED}ERROR: Invalid Choice - must be a number greater than 0${NC}\n"
      fi
    done

    # MD 0 MAXIMUM VM COUNT
    while true; do
      get_input "Maximum Number of Worker nodes [ENTER]: "
      if [[ $value =~ ^[1-9][0-9]*$ ]] && [[ $value -gt $md_0_min_vm_count ]]
      then
        md_0_max_vm_count=$value
        break
      else
        printf "${RED}ERROR: Invalid Choice - must be a number greater than $md_0_min_vm_count${NC}\n"
      fi
    done
  else
    # MD 0 VM COUNT
    while true; do
      get_input "Number of Worker nodes [ENTER]: "
      if [[ $value =~ ^[1-9][0-9]*$ ]]
      then
    	md_0_vm_count=$value
    	break
      else
    	printf "${RED}ERROR: Invalid Choice - must be a number greater than 0${NC}\n"
      fi
    done
    # MD 0 VCPU COUNT
    while true; do
      get_input "Number of vCPU for Worker nodes [ENTER]: "
      if [[ $value =~ \d*[02468]$ ]]
      then
        md_0_vcpu_count=$value
        break
      else
        printf "${RED}ERROR: Invalid Choice - must be an even number greater than 0${NC}\n"
      fi
    done
    
    # MD 0 RAM GB
    while true; do
      get_input "Ammount of RAM (GB) for Worker nodes [ENTER]: "
      if [[ $value =~ ^[1-9][0-9]*$ ]] && [[ $value -gt 1 ]]
      then
        md_0_ram_mb=$(( $value * 1024 ))
        break
      else
        printf "${RED}ERROR: Invalid Choice - must be a number greater than 1${NC}\n"
      fi
    done
    
    # MD 0 STORAGE SIZE GB
    while true; do
      get_input "Ammount of Storage (GB) for Worker nodes [ENTER]: "
      if [[ $value =~ ^[1-9][0-9]*$ ]] && [[ $value -gt 25 ]]
      then
        md_0_disk_gb=$value
        break
      else
        printf "${RED}ERROR: Invalid Choice - must be a number greater than 25${NC}\n"
      fi
    done
  fi
fi

echo ""
echo "########################################"
echo "######## CUSTOM CLUSTER OPTIONS ########"
echo "########################################"
echo ""

# CHECK IF WE SHOULD INSTALL CUSTOM CRS SOLUTIONS
while true; do
  get_input "Would you like to install some basic apps on your cluster automatically? (yes / no) [ENTER]: "
  if [[ $value == "yes" ]] || [[ $value == "no" ]]
  then
    use_crs=$value
    break
  else
    printf "${RED}ERROR: Invalid Choice - must be yes or no${NC}\n"
  fi
done

# IF CRS SHOULD BE INSTALLED
if [[ $use_crs = "yes" ]]
then
  echo ""
  echo "########################################"
  echo "######## LOAD BALANCING OPTIONS ########"
  echo "########################################"
  echo ""
  # SELECT LB PROVIDER FOR ALL SERVICES
  while true; do
    get_input "Which Service Type Load Balancer Solution would you like to use (metallb / kubevip) [ENTER]: "
    if [[ $value == "metallb" ]] || [[ $value == "kubevip" ]]
    then
      svc_lb_provider=$value
      break
    else
      printf "${RED}ERROR: Invalid Choice - must be metallb or kubevip${NC}\n"
    fi
  done
  
  if [[ $svc_lb_provider == "metallb" ]]
  then
    while true; do
      get_input "IP Range for Load Balancer services [ENTER]: "
      if [[ $value =~ ^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)-((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$ ]]
      then
        metallb_lb_ip_range=$value
        break
      else
        printf "${RED}ERROR: Invalid Choice - must be a valid IP range in the format x.x.x.x-x.x.x.y${NC}\n"
      fi
    done
  else
    while true; do
      get_input "CIDR for Load Balancer services [ENTER]: "
      if [[ $value =~ ^((?:\d{1,3}.){3}\d{1,3})\/(\d{1,2})$ ]]
      then
        =$value
        break
      else
        printf "${RED}ERROR: Invalid Choice - must be a valid CIDR in the format x.x.x.x/y${NC}\n"
      fi
    done
  fi
  echo ""
  echo "########################################"
  echo "########## MONTIROING OPTIONS ##########"
  echo "########################################"
  echo ""
  while true; do
    get_input "Do you want to install a monitoring stack? (yes / no) [ENTER]: "
    if [[ $value == "yes" ]] || [[ $value == "no" ]]
    then
      install_monitoring_stack=$value
      break
    else
      printf "${RED}ERROR: Invalid Choice - must be yes or no${NC}\n"
    fi
  done
  if [[ $install_monitoring_stack = "yes" ]]
  then
    while true; do
      get_input "Do you want to install the official TKG monitoring stack or an open source stack? (tkg / oss) [ENTER]: "
      if [[ $value == "tkg" ]] || [[ $value == "oss" ]]
      then
        monitoring_stack_type=$value
        break
      else
        printf "${RED}ERROR: Invalid Choice - must be tkg or oss${NC}\n"
      fi
    done
    if [[ $monitoring_stack_type = "tkg" ]]
    then
      while true; do
        get_input "Prometheus FQDN [ENTER]: "
        if [[ $value =~ ^[a-zA-Z0-9][a-zA-Z0-9_-]+[.][a-zA-Z0-9._-]+[a-zA-Z0-9]$ ]]
        then
          prometheus_fqdn=$value
          break
        else
          printf "${RED}ERROR: Invalid input - must be a valid FQDN${NC}\n"
        fi
      done
      while true; do
        get_input "Grafana FQDN [ENTER]: "
        if [[ $value =~ ^[a-zA-Z0-9][a-zA-Z0-9_-]+[.][a-zA-Z0-9._-]+[a-zA-Z0-9]$ ]]
        then
          grafana_fqdn=$value
          break
        else
          printf "${RED}ERROR: Invalid input - must be a valid FQDN${NC}\n"
        fi
      done
      while true; do
        get_secret_input "Grafana Password [ENTER]: "
        if [[ ${#value} -ge 8 ]]
        then
          grafana_password=$value
          break
        else
          printf "${RED}ERROR: Invalid input - Password must be 8 chars at least${NC}\n"
        fi
      done
    fi
  fi
  echo ""
  echo "########################################"
  echo "######### UI UTILITIES OPTIONS #########"
  echo "########################################"
  echo ""
  while true; do
    get_input "Do you want to install Kubeapps (yes / no) [ENTER]: "
    if [[ $value == "yes" ]] || [[ $value == "no" ]]
    then
      install_kubeapps=$value
      break
    else
      printf "${RED}ERROR: Invalid Choice - must be yes or no${NC}\n"
    fi
  done
  if [[ $install_kubeapps == "yes" ]]
  then
    if [[ $monitoring_stack_type != "tkg" ]]
    then
      install_oss_cert_manager="yes"
      install_oss_contour="yes"
    fi
    
    while true; do
      get_input "Kubeapps FQDN [ENTER]: "
      if [[ $value =~ ^[a-zA-Z0-9][a-zA-Z0-9_-]+[.][a-zA-Z0-9._-]+[a-zA-Z0-9]$ ]]
      then
        kubeapps_fqdn=$value
        break
      else
        printf "${RED}ERROR: Invalid input - must be a valid FQDN${NC}\n"
      fi
    done
  fi
  while true; do
    get_input "Do you want to install Rancher in the cluster (yes / no) [ENTER]: "
    if [[ $value == "yes" ]] || [[ $value == "no" ]]
    then
      install_rancher=$value
      break
    else
      printf "${RED}ERROR: Invalid Choice - must be yes or no${NC}\n"
    fi
  done
  if [[ $install_rancher == "yes" ]]
  then
    if [[ $monitoring_stack_type != "tkg" ]]
    then
      install_oss_cert_manager="yes"
      install_oss_contour="yes"
    fi

    while true; do
      get_input "Rancher FQDN [ENTER]: "
      if [[ $value =~ ^[a-zA-Z0-9][a-zA-Z0-9_-]+[.][a-zA-Z0-9._-]+[a-zA-Z0-9]$ ]]
      then
        rancher_fqdn=$value
        break
      else
        printf "${RED}ERROR: Invalid input - must be a valid FQDN${NC}\n"
      fi
    done
  fi
  echo ""
  echo "########################################"
  echo "######### POLICY ENGINE OPTIONS ########"
  echo "########################################"
  echo ""
  while true; do
    get_input "Do you want to install Kyverno (yes / no) [ENTER]: "
    if [[ $value == "yes" ]] || [[ $value == "no" ]]
    then
      install_kyverno=$value
      break
    else
      printf "${RED}ERROR: Invalid Choice - must be yes or no${NC}\n"
    fi
  done
  if [[ $install_kyverno == "yes" ]]
  then
    while true; do
      get_input "Do you want to create Best Practice security policies automatically (yes / no) [ENTER]: "
      if [[ $value == "yes" ]] || [[ $value == "no" ]]
      then
        kyverno_create_policies=$value
        if [[ $kyverno_create_policies == "yes" ]]
        then
          while true; do
            get_input "Do you want these policies to be enforced or to just audit the cluster (audit / enforce) [ENTER]: "
            if [[ $value == "audit" ]] || [[ $value == "enforce" ]]
            then
              kyverno_policy_type=$value
              if [[ $kyverno_policy_type = "enforce" ]]
              then
                kyverno_enforce_policies="yes"
              else
                kyverno_audit_policies="yes"
              fi
              break
            else
              printf "${RED}ERROR: Invalid Choice - must be audit or enforce${NC}\n"
            fi
          done
        fi
        break
      else
        printf "${RED}ERROR: Invalid Choice - must be yes or no${NC}\n"
      fi
    done
  fi
  echo ""
  echo "########################################"
  echo "########### METRICS OPTIONS ############"
  echo "########################################"
  echo ""
  while true; do
    get_input "Do you want to install the Kubernetes Metrics Server (yes / no) [ENTER]: "
    if [[ $value == "yes" ]] || [[ $value == "no" ]]
    then
      install_metrics_server=$value
      break
    else
      printf "${RED}ERROR: Invalid Choice - must be yes or no${NC}\n"
    fi
  done
  echo ""
  echo "########################################"
  echo "######## IMAGE REGISTRY OPTIONS ########"
  echo "########################################"
  echo ""
  while true; do
    get_input "Do you want to install OSS Harbor (yes / no) [ENTER]: "
    if [[ $value == "yes" ]] || [[ $value == "no" ]]
    then
      install_harbor=$value
      break
    else
      printf "${RED}ERROR: Invalid Choice - must be yes or no${NC}\n"
    fi
  done
  if [[ $install_harbor == "yes" ]]
  then
    while true; do
      get_input "Harbor FQDN [ENTER]: "
      if [[ $value =~ ^[a-zA-Z0-9][a-zA-Z0-9_-]+[.][a-zA-Z0-9._-]+[a-zA-Z0-9]$ ]]
      then
        harbor_fqdn=$value
        break
      else
        printf "${RED}ERROR: Invalid input - must be a valid FQDN${NC}\n"
      fi
    done
    while true; do
      get_secret_input "Harbor Password [ENTER]: "
      if [[ ${#value} -ge 8 ]]
      then
        harbor_password=$value
        break
      else
        printf "${RED}ERROR: Invalid Password - must be at least 8 chars long${NC}\n"
      fi
    done
  fi
  echo ""
  echo "########################################"
  echo "####### SaaS INTEGRATION OPTIONS #######"
  echo "########################################"
  echo ""
  while true; do
    get_input "Do you want to attach your cluster to TMC (yes / no) [ENTER]: "
    if [[ $value == "yes" ]] || [[ $value == "no" ]]
    then
      attach_to_tmc=$value
      break
    else
      printf "${RED}ERROR: Invalid Choice - must be yes or no${NC}\n"
    fi
  done
  if [[ $attach_to_tmc == "yes" ]]
  then
    while true; do
      get_secret_input "TMC API Token [ENTER]: "
      if [[ ${#value} -ge 1 ]]
      then
        tmc_api_token=$value
        break
      else
        printf "${RED}ERROR: You must enter an API Key for TMC${NC}\n"
      fi
    done
    printf "\n"
    while true; do
      get_input "Cluster Group to add the cluster to [ENTER]: "
      if [[ ${#value} -ge 1 ]]
      then
        tmc_cluster_group=$value
        break
      else
        printf "${RED}ERROR: You must enter a cluster group name${NC}\n"
      fi
    done
    while true; do
      get_input "Do you want to enable TMC Data Protection (Velero) on your cluster (yes / no) [ENTER]: "
      if [[ $value == "yes" ]] || [[ $value == "no" ]]
      then
        tmc_enable_dp=$value
        if [[ $tmc_enable_dp == "yes" ]]
        then
          while true; do
            get_input "TMC Data Protection Account Name [ENTER]: "
            if [[ ${#value} -ge 1 ]]
            then
              tmc_dp_account_name=$value
              break
            else
              printf "${RED}ERROR: You must enter an existing TMC Data Protection account name${NC}\n"
            fi
          done
	fi
        break
      else
        printf "${RED}ERROR: You must enter an API Key for TMC${NC}\n"
      fi
    done
  fi
fi

clear
finalcmd=""
printf "########################################\n"
printf "################ SUMMARY ###############\n"
printf "########################################\n\n"
printf "CLUSTER NAME: ${GREEN}$cluster_name${NC}\n"
printf "CLUSTER PLAN: ${GREEN}$cluster_plan${NC}\n"
printf "K8S API ENDPOINT: ${GREEN}$control_plane_endpoint${NC}\n"
printf "ENABLE AUTO SCALING: ${GREEN}$autoscale_enabled${NC}\n"

printf "\n"
printf "########################################\n"
printf "######### CONTROL PLANE DETAILS ########\n"
printf "########################################\n\n"
printf "NUMBER OF CONTROL PLANE NODES: ${GREEN}$control_plane_node_count${NC}\n"
printf "CONTROL PLANE vCPU COUNT: ${GREEN}$control_plane_vcpu_count${NC}\n"
printf "CONTROL PLANE NODE RAM SIZE: ${GREEN}$(( $control_plane_ram_mb / 1024 )) GB${NC}\n"
printf "CONTROL PLANE NODE DISK SIZE: ${GREEN}$control_plane_disk_gb GB${NC}\n"
finalcmd+="CONTROL_PLANE_MACHINE_COUNT=$control_plane_node_count VSPHERE_CONTROL_PLANE_NUM_CPUS=$control_plane_vcpu_count VSPHERE_CONTROL_PLANE_MEM_MIB=$control_plane_ram_mb VSPHERE_CONTROL_PLANE_DISK_GIB=$control_plane_disk_gb"

printf "\n"
printf "########################################\n"
printf "####### MD-0 WORKER NODE DETAILS #######\n"
printf "########################################\n\n"
if [[ $autoscale_enabled == "yes" ]]
then
  printf "MINIMUM NUMBER OF MD-0 WORKER NODES: ${GREEN}$md_0_min_vm_count${NC}\n"
  printf "MAXIMUM NUMBER OF MD-0 WORKER NODES : ${GREEN}$md_0_max_vm_count${NC}\n"
  finalcmd+=" AUTOSCALER_MIN_SIZE_0=$md_0_min_vm_count AUTOSCALER_MAX_SIZE_0=$md_0_max_vm_count WORKER_MACHINE_COUNT=$md_0_min_vm_count"
else
  printf "NUMBER OF MD-0 WORKER NODES: ${GREEN}$md_0_vm_count${NC}\n"
  finalcmd+=" WORKER_MACHINE_COUNT=$md_0_vm_count"
fi
printf "MD-0 WORKER NODES vCPU COUNT: ${GREEN}$md_0_vcpu_count${NC}\n"
printf "MD-0 WORKER NODES RAM SIZE: ${GREEN}$(( $md_0_ram_mb / 1024 )) GB${NC}\n"
printf "MD-0 WORKER NODES DISK SIZE: ${GREEN}$md_0_disk_gb GB${NC}\n"
finalcmd+=" VSPHERE_WORKER_NUM_CPUS=$md_0_vcpu_count VSPHERE_WORKER_MEM_MIB=$md_0_ram_mb VSPHERE_WORKER_DISK_GIB=$md_0_disk_gb"

if [[ $cluster_plan == "complex" ]]
then
  printf "\n"
  printf "########################################\n"
  printf "########### MD-1 NODE DETAILS ##########\n"
  printf "########################################\n\n"
  if [[ $autoscale_enabled == "yes" ]]
  then
    printf "MINIMUM NUMBER OF MD-1 WORKER NODES: ${GREEN}$md_1_min_vm_count${NC}\n"
    printf "MAXIMUM NUMBER OF MD-1 WORKER NODES : ${GREEN}$md_1_max_vm_count${NC}\n"
	finalcmd+=" AUTOSCALER_MIN_SIZE_1=$md_1_min_vm_count AUTOSCALER_MAX_SIZE_1=$md_1_max_vm_count WORKER_MACHINE_COUNT_1=$md_1_min_vm_count"
  else
    printf "NUMBER OF MD-1 WORKER NODES: ${GREEN}$md_1_vm_count${NC}\n"
	finalcmd+=" WORKER_MACHINE_COUNT_1=$md_1_min_vm_count"
  fi
  printf "MD-1 WORKER NODES vCPU COUNT: ${GREEN}$md_1_vcpu_count${NC}\n"
  printf "MD-1 WORKER NODES RAM SIZE: ${GREEN}$(( $md_1_ram_mb / 1024 )) GB${NC}\n"
  printf "MD-1 WORKER NODES DISK SIZE: ${GREEN}$md_1_disk_gb GB${NC}\n"
  finalcmd+=" VSPHERE_WORKER_NUM_CPUS_1=$md_1_vcpu_count VSPHERE_WORKER_MEM_MIB_1=$md_1_ram_mb VSPHERE_WORKER_DISK_GIB_1=$md_1_disk_gb"
  printf "\n"
  printf "########################################\n"
  printf "########### MD-2 NODE DETAILS ##########\n"
  printf "########################################\n\n"
  if [[ $autoscale_enabled == "yes" ]]
  then
    printf "MINIMUM NUMBER OF MD-2 WORKER NODES: ${GREEN}$md_2_min_vm_count${NC}\n"
    printf "MAXIMUM NUMBER OF MD-2 WORKER NODES : ${GREEN}$md_2_max_vm_count${NC}\n"
	finalcmd+=" AUTOSCALER_MIN_SIZE_2=$md_2_min_vm_count AUTOSCALER_MAX_SIZE_2=$md_2_max_vm_count WORKER_MACHINE_COUNT_2=$md_2_min_vm_count"
  else
    printf "NUMBER OF MD-2 WORKER NODES: ${GREEN}$md_2_vm_count${NC}\n"
	finalcmd+=" WORKER_MACHINE_COUNT_2=$md_2_min_vm_count"
  fi
  printf "MD-2 WORKER NODES vCPU COUNT: ${GREEN}$md_2_vcpu_count${NC}\n"
  printf "MD-2 WORKER NODES RAM SIZE: ${GREEN}$(( $md_2_ram_mb / 1024 )) GB${NC}\n"
  printf "MD-2 WORKER NODES DISK SIZE: ${GREEN}$md_2_disk_gb GB${NC}\n"
  finalcmd+=" VSPHERE_WORKER_NUM_CPUS_2=$md_2_vcpu_count VSPHERE_WORKER_MEM_MIB_2=$md_2_ram_mb VSPHERE_WORKER_DISK_GIB_2=$md_2_disk_gb"
fi

printf "\n"
printf "########################################\n"
printf "######## CUSTOM APP DEPLOYMENT #########\n"
printf "########################################\n\n"
printf "INSTALL APPS AUTOMATICALLY: ${GREEN}$use_crs${NC}\n"

if [[ $use_crs == "yes" ]]
then
  printf "\n"
  printf "########################################\n"
  printf "## SERVICE TYPE LOAD BALANCER DETAILS ##\n"
  printf "########################################\n\n"
  printf "SERVICE TYPE LOAD BALNCER SOLUTION: ${GREEN}$svc_lb_provider${NC}\n"
  if [[ $svc_lb_provider == "kubevip" ]]
  then
    printf "KUBE-VIP GLOBAL CIDR: ${GREEN}$kubevip_lb_cidr${NC}\n"
	finalcmd+=" ENABLE_SVC_LB_KUBEVIP=true KUBEVIP_GLOBAL_VIP_CIDR=$kubevip_lb_cidr"
  else
    printf "METALLB IP RANGE: ${GREEN}$metallb_lb_ip_range${NC}\n"
	finalcmd+=" ENABLE_SVC_LB_METALLB=true METALLB_VIP_RANGE=$metallb_lb_ip_range"
  fi
  
  printf "\n"
  printf "########################################\n"
  printf "####### MONITORING STACK DETAILS #######\n"
  printf "########################################\n\n"
  printf "INSTALL A MONITORING STACK: ${GREEN}$install_monitoring_stack${NC}\n"
  
  if [[ $install_monitoring_stack == "yes" ]]
  then
    printf "MONITORING STACK TYPE: ${GREEN}$monitoring_stack_type${NC}\n"
    if [[ $monitoring_stack_type == "tkg" ]]
	then
      printf "PROMETHEUS FQDN: ${GREEN}$prometheus_fqdn${NC}\n"
      printf "GRAFANA FQDN: ${GREEN}$grafana_fqdn${NC}\n"
      printf "GRAFANA PASSWORD: ${GREEN}**********${NC}\n"
	  finalcmd+=" ENABLE_TKG_MONITORING_STACK=true PROMETHEUS_FQDN=$prometheus_fqdn GRAFANA_FQDN=$grafana_fqdn GRAFANA_PASSWORD=$grafana_password"
    else
	  finalcmd+=" ENABLE_OSS_MONITORING_STACK=true"
	fi
  fi
  
  printf "\n"
  printf "########################################\n"
  printf "######### UI UTILITIES DETAILS #########\n"
  printf "########################################\n\n"
  printf "INSTALL KUBEAPPS: ${GREEN}$install_kubeapps${NC}\n"
  if [[ $install_kubeapps == "yes" ]]
  then
    printf "KUBEAPPS FQDN: ${GREEN}$kubeapps_fqdn${NC}\n"
	finalcmd+=" ENABLE_KUBEAPPS=true KUBEAPPS_HOSTNAME=$kubeapps_fqdn"
  fi
  printf "INSTALL RANCHER: ${GREEN}$install_rancher${NC}\n"
  if [[ $install_rancher == "yes" ]]
  then
    printf "RANCHER FQDN: ${GREEN}$rancher_fqdn${NC}\n"  
	finalcmd+=" INSTALL_RANCHER=true RANCHER_FQDN=$rancher_fqdn"
  fi
  if [[ $install_kubeapps == "yes" ]] || [[ $install_rancher == "yes" ]]
  then
    if [[ $monitoring_stack_type != "tkg" ]]
    then
      printf "NOTE: Open source versions of Contour and Cert-Manager will be deployed to enable these installations\n"
	  finalcmd+=" ENABLE_OSS_CERT_MANAGER=true ENABLE_OSS_CONTOUR=true"
    fi
  fi
  
  printf "\n"
  printf "########################################\n"
  printf "######### POLICY ENGINE DETAILS ########\n"
  printf "########################################\n\n"
  printf "INSTALL KYVERNO: ${GREEN}$install_kyverno${NC}\n"
  
  if [[ $install_kyverno == "yes" ]]
  then
    printf "DEFAULT POLICY GENERATION: ${GREEN}$kyverno_create_policies${NC}\n"
	finalcmd+=" INSTALL_KYVERNO=true"
	if [[ $kyverno_create_policies == "yes" ]]
	then
      printf ": ${GREEN}$kyverno_policy_type${NC}\n"
	  if [[ $kyverno_policy_type == "audit" ]]
	  then
	    finalcmd+=" KYVERNO_AUDIT_BASELINE=true"
	  else
        finalcmd+=" KYVERNO_ENFORCE_BASELINE=true"
	  fi
    fi
  fi
  
  printf "\n"
  printf "########################################\n"
  printf "########## K8S METRICS DETAILS #########\n"
  printf "########################################\n\n"
  printf "INSTALL METRICS SERVER: ${GREEN}$install_metrics_server${NC}\n"
  if [[ $install_metrics_server == "yes" ]]
  then
    finalcmd+=" ENABLE_METRICS_SERVER=true"
  fi
  
  printf "\n"
  printf "########################################\n"
  printf "######## IMAGE REGISTRY DETAILS ########\n"
  printf "########################################\n\n"
  printf "INSTALL HARBOR: ${GREEN}$install_harbor${NC}\n"
  if [[ $install_harbor == "yes" ]]
  then
    printf "HARBOR FQDN: ${GREEN}$harbor_fqdn${NC}\n"
    printf "HARBOR PASSWORD: ${GREEN}***********${NC}\n"
    finalcmd+=" ENABLE_OSS_HARBOR=true HARBOR_OSS_FQDN=$harbor_fqdn HARBOR_OSS_PASSWORD=$harbor_password"
  fi
  
  printf "\n"
  printf "########################################\n"
  printf "####### SaaS INTEGRATION DETAILS #######\n"
  printf "########################################\n\n"
  printf "ATTACH CLUSTER TO TMC: ${GREEN}$attach_to_tmc${NC}\n"
  
  if [[ $attach_to_tmc == "yes" ]]
  then
    printf "TMC API TOKEN: ${GREEN}*************${NC}\n"
    printf "ADD CLUSTER TO THE CLUSTER GROUP: ${GREEN}$tmc_cluster_group${NC}\n"
    printf "ENABLE TMC DATA PROTECTION: ${GREEN}$tmc_enable_dp${NC}\n"
	finalcmd+=" ATTACH_TO_TMC=true TMC_API_TOKEN=$tmc_api_token TMC_CLUSTER_GROUP_NAME=$tmc_cluster_group"
    if [[ $tmc_enable_dp == "yes" ]]
	then
      printf "TMC DATA PROTECTION ACCOUNT: ${GREEN}$tmc_dp_account_name${NC}\n"
	  finalcmd+=" TMC_ENABLE_DATA_PROTECTION=\"true\" TMC_DATA_PROTECTION_ACCOUNT_NAME=$tmc_dp_account_name"
    fi
  fi
fi

finalcmd+=" tkg create cluster $cluster_name --plan $cluster_plan --vsphere-controlplane-endpoint $control_plane_endpoint --cni $cni --kubernetes-version $k8s_version"

if [[ $autoscale_enabled == "yes" ]]
then
  finalcmd+=" --enable-cluster-options autoscaler"
fi

while true; do
  get_input "Would you like to run the command or just print what it would be? ( run / print / exit ) [ENTER]: "
  if [[ $value == "run" ]]
  then
    eval $finalcmd
    break
  elif [[ $value == "print" ]]
  then
    printf "TO DEPLOY THE CLUSTER BASED ON YOUR SPECIFICATIONS YOU CAN RUN THE FOLLOWING COMMAND:\n $finalcmd"
    break
  elif [[ $value == "exit" ]]
  then
    printf "GOODBYE"
    break
  else
    printf "${RED}ERROR: Invalid Choice - please select either run, print or exit${NC}\n" 
  fi
done
