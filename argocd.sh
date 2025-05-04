#!/bin/bash

set -e

echo "🔧 Creating Argo CD namespace..."
kubectl create namespace argocd 2>/dev/null || echo "Namespace 'argocd' already exists."

echo "📦 Installing Argo CD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "⬇️ Downloading Argo CD CLI..."
VERSION=$(curl -s https://api.github.com/repos/argoproj/argo-cd/releases/latest | grep tag_name | cut -d '"' -f 4)

curl -sSL -o argocd "https://github.com/argoproj/argo-cd/releases/download/${VERSION}/argocd-linux-amd64"
chmod +x argocd
sudo mv argocd /usr/local/bin/

echo "✅ Argo CD CLI installed at /usr/local/bin/argocd"

echo "🔑 Fetching initial admin password..."
# Wait briefly to ensure secret is created
sleep 10

ADMIN_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

if [ -z "$ADMIN_PASSWORD" ]; then
  echo "❌ Failed to retrieve admin password. Please check if the Argo CD pods are running."
else
  echo "✅ Argo CD admin password: $ADMIN_PASSWORD"
fi

echo ""
echo "🌐 Access the Argo CD UI by running:"
echo "   kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "Then open: https://localhost:8080"
echo ""
echo "🧑 Username: admin"
echo "🔐 Password: $ADMIN_PASSWORD"

kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

echo "Use below load balancer endpoint below to access the argocd"
kubectl get svc -n argocd

