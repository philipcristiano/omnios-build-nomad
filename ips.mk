IPS_BUILD_DIR ?= ips-build
IPS_TMP_DIR ?= tmp

PROJECT_NAME ?= ${PROJECT}
USERNAME ?= ${PROJECT}
GROUPNAME ?= ${PROJECT}

IPS_BUILD_TIME=$(shell TZ=UTC date +"%Y%m%dT%H%M%SZ")
export IPS_FMRI=server/${PROJECT_NAME}@${PROJECT_VERSION}:${IPS_BUILD_TIME}
export IPS_DESCRIPTION=${PROJECT_DESCRIPTION}
export IPS_SUMMARAY=${IPS_DESCRIPTION}

ARCH=$(shell uname -p)

define IPS_METADATA
set name=pkg.fmri value=${IPS_FMRI}
set name=pkg.description value="${IPS_DESCRIPTION}"
set name=pkg.summary value="${IPS_SUMMARAY}"
set name=variant.arch value=${ARCH}
group groupname=${GROUPNAME}
user username=${USERNAME} group=${GROUPNAME} home-dir=/var/${PROJECT}
endef
export IPS_METADATA

ips-clean:
	rm -rf ${IPS_BUILD_DIR} ${IPS_TMP_DIR}

ips-prototype:
	# Store initial transform
	echo "$$IPS_TRANSFORM" > ${IPS_TMP_DIR}/transform.mog

ips-package: ips-prototype
	pkgsend generate ${IPS_BUILD_DIR} | pkgfmt > ${IPS_TMP_DIR}/pkg.pm5.1
	# Store metadata into a file
	echo "$$IPS_METADATA" > ${IPS_TMP_DIR}/pkg.mog
	for dep in ${IPS_DEPS}; do \
		echo "depend type=require fmri=$$dep" >> tmp/pkg.mog ; \
	done

	pkgmogrify ${IPS_TMP_DIR}/pkg.pm5.1 ${IPS_TMP_DIR}/pkg.mog ${IPS_TMP_DIR}/transform.mog | pkgfmt > ${IPS_TMP_DIR}/pkg.pm5.final

	pkglint ${IPS_TMP_DIR}/pkg.pm5.final

define IPS_TRANSFORM
<transform dir path=data$$ -> drop>
<transform dir path=usr$$ -> drop>
<transform dir path=lib$$ -> drop>
<transform dir path=lib/svc$$ -> drop>
<transform dir path=lib/svc/manifest$$ -> drop>
<transform dir path=lib/svc/manifest/database$ -> drop>
<transform dir path=lib/svc/method$ -> drop>
<transform dir path=opt$$ -> drop>
<transform dir path=etc$$ -> drop>
<transform dir path=var$$ -> drop>
<transform dir path=var/lib$$ -> drop>
<transform file path=(var|lib)/svc/manifest/.*\.xml$ -> default restart_fmri svc:/system/manifest-import:default>
<transform file dir -> set owner ${USERNAME}>
<transform file dir -> set group ${GROUPNAME}>
endef
export IPS_TRANSFORM

define add-ips-transform
echo $(1) >> ${IPS_TMP_DIR}/transform.mog
endef
