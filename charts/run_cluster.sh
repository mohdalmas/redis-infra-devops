#!/bin/bash

# Ensure the script exits on error
set -e

# Usage function
usage() {
    echo "Usage: $0 -a <context_cluster_a> -b <context_cluster_b>"
    exit 1
}

# Parse command-line arguments
while getopts "a:b:" opt; do
    case ${opt} in
        a )
            CONTEXT_CLUSTER_A=$OPTARG
            ;;
        b )
            CONTEXT_CLUSTER_B=$OPTARG
            ;;
        \? )
            usage
            ;;
    esac
done
shift $((OPTIND -1))

# Check if the required parameters are set
if [ -z "$CONTEXT_CLUSTER_A" ] || [ -z "$CONTEXT_CLUSTER_B" ]; then
    usage
fi

# Construct contexts
CONTEXT_CLUSTER_A_ARN="arn:aws:eks:us-east-1:194722417082:cluster/${CONTEXT_CLUSTER_A}"
CONTEXT_CLUSTER_B_ARN="arn:aws:eks:us-east-1:194722417082:cluster/${CONTEXT_CLUSTER_B}"

# Update kubeconfig for both clusters
echo "Updating kubeconfig for cluster context ${CONTEXT_CLUSTER_A}..."
aws eks update-kubeconfig --region "us-east-1" --name "${CONTEXT_CLUSTER_A}"

echo "Updating kubeconfig for cluster context ${CONTEXT_CLUSTER_B}..."
aws eks update-kubeconfig --region "us-east-1" --name "${CONTEXT_CLUSTER_B}"

echo "Installing Helm Charts"
helm upgrade --install redis-cluster-a ./../charts/ -f ./../charts/values_a.yaml -n redis-cluster --create-namespace --set global.redis.password=global --kube-context="${CONTEXT_CLUSTER_A_ARN}" & 
helm upgrade --install redis-cluster-b ./../charts/ -f ./../charts/values_b.yaml -n redis-cluster --create-namespace --set global.redis.password=global --kube-context="${CONTEXT_CLUSTER_B_ARN}" & 

# Wait for both Helm installs to complete
wait

echo "Both Helm installations are complete."