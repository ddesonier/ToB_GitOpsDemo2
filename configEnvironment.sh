git clone https://github.com/ddesonier/aks-flux


az login
az account set --subscription 7c27312f-200e-47f6-a855-c308a26f1493


export resourceGroup="azure-k8stest"
export LOCATION="eastus"
export CLUSTER_NAME="k8stest"


#az group create -n $resourceGroup -l $LOCATION

#az aks create -g $resourceGroup -n $CLUSTER_NAME --enable-managed-identity

az aks get-credentials -g $resourceGroup -n $CLUSTER_NAME

kubectl get nodes

flux check --pre

#export GITHUB_TOKEN="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"
export GITHUB_TOKEN="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"
export GITHUB_USER="ddesonier"
export GITHUB_REPO="ToB_GitOpsDemo2"


flux bootstrap github \
--owner=$GITHUB_USER \
--repository=$GITHUB_REPO \
--branch=main \
--path=./clusters/$CLUSTER_NAME




flux check

git pull

mkdir manifests ; cd manifests

add files

kubectl get kustomization -A
flux reconcile ks flux-system --with-source
kubectl get kustomization -A
git add . ; git commit -m "Added DemoApp" ; git push


az aks scale --resource-group $resourceGroup  --name $CLUSTER_NAME --node-count 1 --nodepool-name "nodepool1"

az aks show --resource-group $resourceGroup  --name $CLUSTER_NAME  --query kubernetesVersion --output table

