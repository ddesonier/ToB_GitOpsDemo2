#!/bin/bash
# A simple Bash script

#export GITHUB_TOKEN=<your-token>
#export GITHUB_USER=<your-username>
#export GITHUB_REPO=<name-of-your-repo>




cd ~/repos/demos/ToB_GitOpsDemo2

mkdir manifests

cat > ./manifests/namespace.yaml <<EOF
---
apiVersion: v1
kind: Namespace
metadata:
  name: demoapp
EOF


cat > ./manifests/deployment.yaml <<EOF
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demoapp
  namespace: demoapp
spec:
  replicas: 2
  selector:
    matchLabels:
      app: demoapp
  template:
    metadata:
      labels:
        app: demoapp
    spec:
      containers:
        - name: demoapp
          image: "mcr.microsoft.com/dotnet/core/samples:aspnetapp"
          ports:
            - containerPort: 80
              protocol: TCP
EOF

cat > ./manifests/service.yaml <<EOF
---
apiVersion: v1
kind: Service
metadata:
  name: demoapp
  namespace: demoapp
spec:
  type: ClusterIP
  selector:
    app: demoapp
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
EOF