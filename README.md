# Accessing a Redis Enterprise database from outside a GKE cluster

## High Level Workflow
The following is the high level workflow which you will follow:
1. Create a GKE cluster
2. Create a namespace for this deployment and the Redis Enterprise Operator bundle
3. Deploy a Redis Enterprise Cluster (REC)
4. Create a Redis Enterprise database instance with SSL/TLS enabled
5. Deploy Nginx ingress controller
6. Create an Ingress resource for the Redis Enterprise cluster for web UI access
7. Create an Ingress resource for external traffic going into the Redis Enterprise database
8. Generate and upload a SSL certificate for the Redis Enterprise database
9. Verify SSL/TLS connection using openssl
10. Connect to the Redis Enterprise database over SSL/TLS via a Python program


#### 1. Create a GKE cluster
```
./create_cluster.sh glau-gke-cluster us-west1-a
```


#### 2. Create a namespace for this deployment and the Redis Enterprise Operator bundle
```
kubectl create namespace redis
kubectl config set-context --current --namespace=redis

kubectl apply -f "https://raw.githubusercontent.com/RedisLabs/redis-enterprise-k8s-docs/master/bundle.yaml"
```


#### 3. Deploy a Redis Enterprise Cluster (REC)
```
kubectl apply -f rec.yaml
```


#### 4. Create a Redis Enterprise database instance with SSL/TLS enabled
```
ubectl apply -f redb.yaml
```


#### 5. Deploy Nginx ingress controller
```
kubectl apply -f nginx-ingress-controller.yaml
```
Grab the external IP of the Nginx ingress controller for later use:
```
kubectl get service -n ingress-nginx
```


#### 6.  



