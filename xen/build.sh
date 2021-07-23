KUBEVIRT_DIR=${HOME}/go/src/kubevirt.io/kubevirt
export DOCKER_PREFIX=10.169.188.118:5000
export DOCKER_TAG=mybuild
export IMAGE_PULL_POLICY=Always
export VERBOSITY=5

cd ${KUBEVIRT_DIR}
make && make push && make manifests
