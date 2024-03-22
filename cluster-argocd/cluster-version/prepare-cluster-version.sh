#!/bin/bash
set -Eeuf -o pipefail

PWD=$(dirname $(readlink -f $0))

help() {
  echo
  echo "Prepare an Openshift Version by setting the values in the values.yaml file"
  echo
  echo "USAGE: $0 OCP_VERSION"
  echo 
}

OCP_VERSION=${1:-}
ARCHITECTURE=x86_64

if [ -z "${OCP_VERSION}" ]; then
  help
  exit 1
fi

echo "Validating provided Openshift Version..."
if ! ([[ "${OCP_VERSION}" =~ ^4\.[0-9]{1,2}\.[0-9]{1,2}$ ]] && curl -k -If https://mirror.openshift.com/pub/openshift-v4/${ARCHITECTURE}/clients/ocp/${OCP_VERSION}/ >/dev/null 2>&1); then
  echo "Invalid Openshift version: ${OCP_VERSION}"
  exit 1
fi
echo "The provided Openshift Version is valid"

CHANNEL=stable-$(echo ${OCP_VERSION} | awk -F. '{print $1"."$2}')
IMAGE=$(oc adm release info quay.io/openshift-release-dev/ocp-release:${OCP_VERSION}-${ARCHITECTURE} | sed -n 's/Pull From: //p')
DIGEST=${IMAGE#*@}
DIGEST_ALGORITHM=${DIGEST%%:*}
DIGEST_ENCODED=${DIGEST#*:}
if [[ "$OSTYPE" == "darwin"* ]]; then
  SIGNATURE_BASE64=$(curl -s "https://mirror.openshift.com/pub/openshift-v4/signatures/openshift/release/${DIGEST_ALGORITHM}=${DIGEST_ENCODED}/signature-1" | base64)
else
  SIGNATURE_BASE64=$(curl -s "https://mirror.openshift.com/pub/openshift-v4/signatures/openshift/release/${DIGEST_ALGORITHM}=${DIGEST_ENCODED}/signature-1" | base64 -w0)
fi

echo -n "Generating helm values file..."
cat << EOF > ${PWD}/values.yaml
channel: ${CHANNEL}
release_image: ${IMAGE}
openshift_version: ${OCP_VERSION}
digest_algorithm: ${DIGEST_ALGORITHM}
digest_encoded: ${DIGEST_ENCODED}
signature_base64: ${SIGNATURE_BASE64}
EOF
echo " Done"
