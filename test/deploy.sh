#!/bin/bash
set -e

NAMESPACE=${NAMESPACE:-agari}
TIMEOUT_DB=${TIMEOUT_DB:-5m}
TIMEOUT_SERVICE=${TIMEOUT_SERVICE:-10m}

echo "===================================="
echo "Deploying components to ${NAMESPACE}"
echo "===================================="

# Deploy MinIO
echo ""
echo "Deploying MinIO..."
helm install minio ./helm/minio \
  -f ./helm/values/dev/minio.yaml \
  -n "${NAMESPACE}" \
  --wait \
  --timeout "${TIMEOUT_SERVICE}"

echo "Verifying MinIO deployment..."
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/instance=minio --timeout=300s --namespace="${NAMESPACE}"

# Deploy Kafka
echo ""
echo "Adding bitnami helm repo..."
helm repo add bitnami https://charts.bitnami.com/bitnami 2>/dev/null || true
helm repo update

echo "Deploying Kafka..."
helm install kafka bitnami/kafka \
  -f helm/kafka/values-bitnami.yaml \
  -n "${NAMESPACE}" \
  --wait \
  --timeout "${TIMEOUT_SERVICE}"

echo "Verifying Kafka deployment..."
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/instance=kafka --timeout=300s --namespace="${NAMESPACE}"

# Deploy keycloak-db
echo ""
echo "Deploying keycloak-db..."
helm install keycloak-db ./helm/keycloak-db \
  -f ./helm/values/dev/keycloak.yaml \
  -n "${NAMESPACE}" \
  --wait \
  --timeout "${TIMEOUT_DB}"

echo "Verifying keycloak-db deployment..."
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/instance=keycloak-db --timeout=300s --namespace="${NAMESPACE}"

# Deploy keycloak
echo ""
echo "Deploying keycloak..."
helm install keycloak ./helm/keycloak \
  -f ./helm/values/dev/keycloak.yaml \
  -n "${NAMESPACE}" \
  --wait \
  --timeout "${TIMEOUT_SERVICE}"

echo "Verifying keycloak deployment..."
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/instance=keycloak --timeout=600s --namespace="${NAMESPACE}"

# Deploy song-db
echo ""
echo "Deploying song-db..."
helm install song-db ./helm/song-db \
  -n "${NAMESPACE}" \
  --wait \
  --timeout "${TIMEOUT_DB}"

echo "Verifying song-db deployment..."
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/instance=song-db --timeout=300s --namespace="${NAMESPACE}"

# Deploy song
echo ""
echo "Deploying song..."
helm install song ./helm/song \
  -f ./helm/values/dev/song.yaml \
  -n "${NAMESPACE}" \
  --wait \
  --timeout "${TIMEOUT_SERVICE}"

echo "Verifying song deployment..."
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/instance=song --timeout=300s --namespace="${NAMESPACE}"

# Deploy score
echo ""
echo "Deploying score..."
helm install score ./helm/score \
  -n "${NAMESPACE}" \
  --wait \
  --timeout "${TIMEOUT_SERVICE}"

echo "Verifying score deployment..."
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/instance=score --timeout=300s --namespace="${NAMESPACE}"

# Deploy elasticsearch
echo ""
echo "Deploying elasticsearch..."
helm install elasticsearch ./helm/elasticsearch \
  -n "${NAMESPACE}" \
  --wait \
  --timeout "${TIMEOUT_SERVICE}"

echo "Verifying elasticsearch deployment..."
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/instance=elasticsearch --timeout=300s --namespace="${NAMESPACE}"

# Deploy maestro
echo ""
echo "Deploying maestro..."
helm install maestro ./helm/maestro \
  -f ./helm/values/dev/maestro.yaml \
  -n "${NAMESPACE}" \
  --wait \
  --timeout "${TIMEOUT_SERVICE}"

echo "Verifying maestro deployment..."
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/instance=maestro --timeout=300s --namespace="${NAMESPACE}"

# Deploy arranger
echo ""
echo "Deploying arranger..."
helm install arranger ./helm/arranger \
  -f ./helm/values/dev/arranger.yaml \
  -n "${NAMESPACE}" \
  --wait \
  --timeout "${TIMEOUT_SERVICE}"

echo "Verifying arranger deployment..."
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/instance=arranger --timeout=300s --namespace="${NAMESPACE}"

# Deploy folio-db
echo ""
echo "Deploying folio-db..."
helm install folio-db ./helm/folio-db \
  -n "${NAMESPACE}" \
  --wait \
  --timeout "${TIMEOUT_DB}"

echo "Verifying folio-db deployment..."
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/instance=folio-db --timeout=300s --namespace="${NAMESPACE}"

# Deploy folio
echo ""
echo "Deploying folio..."
helm install folio ./helm/folio \
  -f ./helm/values/dev/folio.yaml \
  -n "${NAMESPACE}" \
  --wait \
  --timeout "${TIMEOUT_SERVICE}"

echo "Verifying folio deployment..."
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/instance=folio --timeout=300s --namespace="${NAMESPACE}"

echo ""
echo "===================================="
echo "Deployment completed successfully!"
echo "===================================="
