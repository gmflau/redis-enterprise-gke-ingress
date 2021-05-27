#!/bin/bash

set -ex

kubectl create clusterrolebinding my-cluster-admin-binding --clusterrole cluster-admin --user $(gcloud config get-value account)
kubectl apply -f rec-operator/role.yaml
kubectl apply -f rec-operator/role_binding.yaml
kubectl apply -f rec-operator/service_account.yaml
kubectl apply -f rec-operator/crds/v1alpha1/rec_crd.yaml
kubectl apply -f rec-operator/crds/v1alpha1/redb_crd.yaml
kubectl apply -f rec-operator/operator.yaml

