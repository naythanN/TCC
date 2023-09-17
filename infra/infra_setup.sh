eksctl create cluster -f cluster_config.yaml
# sudo apt install nvidia-driver-535 run this on node for nvidia, create the /dev/dri render devices
helm repo add jetstack https://charts.jetstack.io
helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
   && helm repo update

helm install --wait --generate-name \
     -n gpu-operator --create-namespace \
     nvidia/gpu-operator --version v23.6.0 \
     --set driver.enabled=false \
     --set migManager.enabled=false \
     --set mig.strategy=mixed \
     --set toolkit.enabled=true

# Remove default nvidia device driver,
# k edit daemonset.apps/nvidia-device-plugin-daemonset -n gpu-operator
# nvidia.com/gpu.deploy.device-plugin=false


kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.12.0/cert-manager.yaml

kubectl label nodes $(kubectl get nodes | cut -f1 -d " " | tail -1) "nos.nebuly.com/gpu-partitioning=mps"
kubectl label nodes $(kubectl get nodes | cut -f1 -d " " | tail -1) "smarter-device-manager=enabled"

helm install oci://ghcr.io/nebuly-ai/helm-charts/nvidia-device-plugin \
  --version 0.13.0 \
  --generate-name \
  -n nebuly-nvidia \
  --create-namespace

helm install oci://ghcr.io/nebuly-ai/helm-charts/nos \
  --version 0.1.2 \
  --namespace nebuly-nos \
  --generate-name \
  --create-namespace

aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://setup_files/iam_policy.json

eksctl create iamserviceaccount \
  --cluster=gpu \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::380285632927:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve

helm repo add eks https://aws.github.io/eks-charts

helm repo update eks

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=gpu \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller


kubectl apply -f service/service.yaml

bash setup_files/script_session_affinity.sh > logs/script_session_affinity.log

kubectl apply -f statefulSet/nijima_statefulset.yaml

