#!/bin/bash

# Ensure the script exits on error
set -e

# Usage function
usage() {
    echo "Usage: $0 -c <context_cluster_a> -d <context_cluster_b> -f <path_to_configmap>"
    exit 1
}

# Parse command-line arguments
while getopts "c:d:f:" opt; do
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
        \? )
            usage
            ;;
    esac
done
shift $((OPTIND -1))

# Check for missing parameters
if [ -z "$CONTEXT_CLUSTER_A" ] || [ -z "$CONTEXT_CLUSTER_B" ] || [ -z "$CONFIGMAP_FILE" ]; then
    usage
fi

# Update kubeconfig with the given context
echo "Updating kubeconfig for cluster context ${CONTEXT_CLUSTER_A}..."
aws eks update-kubeconfig --name "${CONTEXT_CLUSTER_A}"

echo "Updating kubeconfig for cluster context ${CONTEXT_CLUSTER_B}..."
aws eks update-kubeconfig --name "${CONTEXT_CLUSTER_B}"

# Apply ConfigMap to cluster A
echo "Applying ConfigMap ${CONFIGMAP_FILE} to cluster ${CONTEXT_CLUSTER_A}..."
kubectl --context="arn:aws:eks:us-east-1:194722417082:cluster/${CONTEXT_CLUSTER_A}" apply -f "${CONFIGMAP_FILE}"
kubectl --context="arn:aws:eks:us-east-1:194722417082:cluster/${CONTEXT_CLUSTER_A}" rollout restart deploy coredns -n kube-system

# Apply ConfigMap to cluster B
echo "Applying ConfigMap ${CONFIGMAP_FILE} to cluster ${CONTEXT_CLUSTER_B}..."
kubectl --context="arn:aws:eks:us-east-1:194722417082:cluster/${CONTEXT_CLUSTER_B}" apply -f "${CONFIGMAP_FILE}"
kubectl --context="arn:aws:eks:us-east-1:194722417082:cluster/${CONTEXT_CLUSTER_B}" rollout restart deploy coredns -n kube-system

echo "ConfigMap updates applied successfully and core dns restarted successfully!"
