
KUBE_VERSION=1.14.8-aliyun.3
REGION=cn-shanghai
CLOUD_TYPE=public
DOCKER_VERSION=19.03.5
PKG_FILE_SERVER=http://aliacs-k8s-${REGION}.oss-$REGION.aliyuncs.com
function echot() {
	echo $(date +"[%Y%m%d %H:%M:%S]: ") $1
}

function prepare_package() {
	local PKG_TYPE=$1
	local PKG_VERSION=$2
	echot "download pkg [$PKG_TYPE] from ${PKG_FILE_SERVER}"
	file=${PKG_TYPE}-${PKG_VERSION}.tar.gz
	if [ ! -f ${file} ]; then
		if [ -z $PKG_FILE_SERVER ]; then
			echot "empty file server"; exit 1
		fi
		wget $PKG_FILE_SERVER/$CLOUD_TYPE/pkg/$PKG_TYPE/${PKG_TYPE}-${PKG_VERSION}.tar.gz || (echot "download failed with 4 retry,exit 1" ; exit 1)
		tar -xvf ${PKG_TYPE}-${PKG_VERSION}.tar.gz
	fi
}

prepare_package "docker" "${DOCKER_VERSION}"
pkg=pkg/docker/$DOCKER_VERSION/rpm/
# install docker
yum localinstall -y $(ls ${pkg} | xargs -I '{}' echo -n "$pkg{} ")

yum install -y ntpdate  socat fuse fuse-libs nfs-utils nfs-utils-lib pciutils bash-completion
cp /lib/systemd/system/docker.service /etc/systemd/system/docker.service
systemctl daemon-reload
systemctl enable docker.service
systemctl restart docker.service

prepare_package "kubernetes" "${KUBE_VERSION}"
dir=pkg/kubernetes/${KUBE_VERSION}/rpm
yum localinstall -y $(ls $dir | xargs -I '{}' echo -n "$dir/{} ")

