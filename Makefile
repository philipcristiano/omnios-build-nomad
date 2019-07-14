PROJECT=nomad
VERSION=0.9.3
PROJECT_NAME=${PROJECT}
PROJECT_VERSION=${VERSION}
DOWNLOAD_SRC=https://github.com/cneira/${PROJECT}/archive/master.tar.gz
LOCAL_SRC_TAR=src.tar.gz
LOCAL_SRC=nomad-master

USERNAME=${PROJECT}
GROUPNAME=${PROJECT}
BUILD_OUTPUT_DIR=go

clone:
	curl -L ${DOWNLOAD_SRC} -o ${LOCAL_SRC_TAR}
	tar -zxf ${LOCAL_SRC_TAR}
	ls

build:
	@ echo 'Print env before building'
	@ bash -c 'env'
	cd ${LOCAL_SRC}; make -j 8 tools
	cd ${LOCAL_SRC}; make -j 8 dev-build

package:
	@echo do packagey things!
	mkdir -p ${IPS_BUILD_DIR}/opt/nomad/bin ${IPS_TMP_DIR}

	cp -r ${BUILD_OUTPUT_DIR}/bin/nomad ${IPS_BUILD_DIR}/opt/nomad/bin

	# SMF
	mkdir -p ${IPS_BUILD_DIR}/lib/svc/manifest/database/
	mkdir -p ${IPS_BUILD_DIR}/lib/svc/method/
	mkdir -p ${IPS_BUILD_DIR}/etc/nomad.d
	mkdir -p ${IPS_BUILD_DIR}/var/nomad
	cp smf.xml ${IPS_BUILD_DIR}/lib/svc/manifest/database/${PROJECT_NAME}.xml

	#cp -r default.hcl ${IPS_BUILD_DIR}/etc/nomad.d/default.hcl

publish: ips-package
ifndef PKGSRVR
	echo "Need to define PKGSRVR, something like http://localhost:10000"
	exit 1
endif
	pkgsend publish -s ${PKGSRVR} -d ${IPS_BUILD_DIR} ${IPS_TMP_DIR}/pkg.pm5.final
	pkgrepo refresh -s ${PKGSRVR}

include ips.mk
