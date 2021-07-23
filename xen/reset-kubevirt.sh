KUBEVIRT_DIR=${HOME}/go/src/kubevirt.io/kubevirt
export DOCKER_PREFIX=10.169.188.118:5000
export DOCKER_TAG=mybuild
export IMAGE_PULL_POLICY=Always
export VERBOSITY=5

echo
echo
echo "########## Resetting cluster .........."
kubeadm reset -f || exit 1

echo
echo
echo "########## Initializing a new cluster .........."
swapoff -a || exit 1

kubeadm init --pod-network-cidr=10.244.0.0/16  || exit 2

cp -f /etc/kubernetes/admin.conf $HOME/.kube/config  || exit 2

chown $(id -u):$(id -g) $HOME/.kube/config || exit 2

echo
echo
echo "########## Configuring the new cluster .........."
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml || exit 3

kubectl taint nodes --all node-role.kubernetes.io/master-  || exit 3

echo
echo
echo "########## Waiting for cluster ready .........."
sleep 20s
kubectl get pods --all-namespaces


echo
echo
echo "########## Deploying kubevirt .........."
cd ${KUBEVIRT_DIR}
make manifests || exit 4
kubectl create -f ${KUBEVIRT_DIR}/_out/manifests/release/kubevirt-operator.yaml || exit 4
kubectl create -f ${KUBEVIRT_DIR}/_out/manifests/release/kubevirt-cr.yaml || exit 4

echo
echo
echo "########## Waiting for kubevirt .........."
sleep 20s
echo
echo "########## To check status: kubectl get all -n kubevirt"
echo
kubectl get all -n kubevirt

kubectl wait --for=condition=available --timeout=120s kubevirt.kubevirt.io/kubevirt -n kubevirt || exit 4
echo
echo "########## Kubevirt is deployed successfully"
echo

kubectl apply -f https://kubevirt.io/labs/manifests/vm.yaml || exit 5
virtctl start testvm || 5
sleep 5s
kubectl get vms
kubectl get vmis
echo
echo "########## testvm created"
echo
