#!/bin/bash

# Ensure the script exits on error
set -e

# Usage function
usage() {
    echo "Usage: $0 -c <context_cluster_a> -d <context_cluster_b> -f <path_to_configmap> -r <aws_region> -z <route53_zone_id> -n <route53_zone_name> -a <iam_role_arn>"
    exit 1
}

# Parse command-line arguments
while getopts "c:d:f:r:z:n:a:" opt; do
    case ${opt} in
        c )
            CONTEXT_CLUSTER_A=$OPTARG
            ;;
        d )
            CONTEXT_CLUSTER_B=$OPTARG
            ;;
        f )
            CONFIGMAP_FILE=$OPTARG
            ;;
        r )
            AWS_REGION=$OPTARG
            ;;
        z )
            ROUTE53_ZONE_ID=$OPTARG
            ;;
        n )
            ROUTE53_ZONE_NAME=$OPTARG
            ;;
        a )
            IAM_ROLE_ARN=$OPTARG
            ;;
        \? )
            usage
            ;;
    esac
done
shift $((OPTIND -1))

# Check for missing parameters
if [ -z "$CONTEXT_CLUSTER_A" ] || [ -z "$CONTEXT_CLUSTER_B" ] || [ -z "$CONFIGMAP_FILE" ] || [ -z "$AWS_REGION" ] || [ -z "$ROUTE53_ZONE_ID" ] || [ -z "$ROUTE53_ZONE_NAME" ] || [ -z "$IAM_ROLE_ARN" ]; then
    usage
fi

# Update kubeconfig for both clusters
echo "Updating kubeconfig for cluster context ${CONTEXT_CLUSTER_A}..."
aws eks update-kubeconfig --region "${AWS_REGION}" --name "${CONTEXT_CLUSTER_A}"

echo "Updating kubeconfig for cluster context ${CONTEXT_CLUSTER_B}..."
aws eks update-kubeconfig --region "${AWS_REGION}" --name "${CONTEXT_CLUSTER_B}"

# Apply ConfigMap and restart CoreDNS on cluster A
echo "Applying ConfigMap ${CONFIGMAP_FILE} to cluster ${CONTEXT_CLUSTER_A}..."
kubectl --context="arn:aws:eks:${AWS_REGION}:${CONTEXT_CLUSTER_A}" apply -f "${CONFIGMAP_FILE}"
kubectl --context="arn:aws:eks:${AWS_REGION}:${CONTEXT_CLUSTER_A}" rollout restart deploy coredns -n kube-system

# Apply ConfigMap and restart CoreDNS on cluster B
echo "Applying ConfigMap ${CONFIGMAP_FILE} to cluster ${CONTEXT_CLUSTER_B}..."
kubectl --context="arn:aws:eks:${AWS_REGION}:${CONTEXT_CLUSTER_B}" apply -f "${CONFIGMAP_FILE}"
kubectl --context="arn:aws:eks:${AWS_REGION}:${CONTEXT_CLUSTER_B}" rollout restart deploy coredns -n kube-system

# Install Core DNS Helm chart on cluster A
echo "Installing Core DNS Helm chart on cluster ${CONTEXT_CLUSTER_A}..."
aws eks update-kubeconfig --region "${AWS_REGION}" --name "${CONTEXT_CLUSTER_A}"
helm install externaldns-release \
  --namespace kube-system \
  --repository oci://registry-1.docker.io/bitnamicharts \
  --chart external-dns \
  --set provider=aws \
  --set aws.region=${AWS_REGION} \
  --set txtOwnerId=${ROUTE53_ZONE_ID} \
  --set domainFilters[0]=${ROUTE53_ZONE_NAME} \
  --set serviceAccount.name=external-dns \
  --set serviceAccount.create=true \
  --set serviceAccount.annotations="eks.amazonaws.com/role-arn: ${IAM_ROLE_ARN}" \
  --set policy=sync \
  --timeout 900 \
  --wait

# Install Core DNS Helm chart on cluster B
echo "Installing Core DNS Helm chart on cluster ${CONTEXT_CLUSTER_B}..."
aws eks update-kubeconfig --region "${AWS_REGION}" --name "${CONTEXT_CLUSTER_B}"
helm install externaldns-release \
  --namespace kube-system \
  --repository oci://registry-1.docker.io/bitnamicharts \
  --chart external-dns \
  --set provider=aws \
  --set aws.region=${AWS_REGION} \
  --set txtOwnerId=${ROUTE53_ZONE_ID} \
  --set domainFilters[0]=${ROUTE53_ZONE_NAME} \
  --set serviceAccount.name=external-dns \
  --set serviceAccount.create=true \
  --set serviceAccount.annotations="eks.amazonaws.com/role-arn: ${IAM_ROLE_ARN}" \
  --set policy=sync \
  --timeout 900 \
  --wait

echo "ConfigMap updates applied, CoreDNS restarted, and Helm charts installed successfully!"
