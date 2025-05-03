#!/bin/bash

set -e

# Step 1: Create the Argo CD namespace
echo "🔧 Creating Argo CD namespace..."
kubectl create namespace argocd || echo "Namespace 'argocd' already exists."

# Step 2: Install Argo CD components
echo "📦 Installing Argo CD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Step 3: Download Argo CD CLI
echo "⬇️ Downloading Argo CD CLI..."
VERSION=$(curl -s https://api.github.com/repos/argoproj/argo-cd/releases/latest | grep tag_name | cut -d '"' -f 4)
curl -sSL -o /usr/local/bin/argocd "https://github.com/argoproj/argo-cd/releases/download/${VERSION}/argocd-linux-amd64"
chmod +x /usr/local/bin/argocd

# Step 4: Wait for Argo CD server pod to be ready
echo "⏳ Waiting for Argo CD server to be ready..."
kubectl wait --for=condition=available --timeout=180s deployment/argocd-server -n argocd

# Step 5: Output port-forward command
echo "✅ Argo CD installed successfully!"
echo "🔐 To access the UI, run:"
echo "kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "Then open https://localhost:8080 in your browser."

# Step 6: Get the initial admin password
echo "🔑 Fetching Argo CD admin password..."
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d && echo
