# Accessing a Redis Enterprise database from outside a GKE cluster

## High Level Workflow
The following is the high level workflow which you will follow:
1. Create a GKE cluster
2. Create a namespace for this deployment and deploy the Redis Enterprise Operator bundle
3. Deploy a Redis Enterprise Cluster (REC)
4. Create a Redis Enterprise database instance with SSL/TLS enabled
5. Deploy Nginx ingress controller
6. Create an Ingress resource for the Redis Enterprise cluster for web UI access
7. Generate and upload a SSL certificate for the Redis Enterprise database
8. Create an Ingress resource for external traffic going into the Redis Enterprise database
9. Verify SSL/TLS connection using openssl
10. Connect to the Redis Enterprise database over SSL/TLS via a Python program


#### 1. Create a GKE cluster
```
./create_cluster.sh glau-gke-cluster us-west1-a
```


#### 2. Create a namespace for this deployment and deploy the Redis Enterprise Operator bundle
```
kubectl create namespace redis
kubectl config set-context --current --namespace=redis

./bundle.sh
```


#### 3. Deploy a Redis Enterprise Cluster (REC)
```
kubectl apply -f rec.yaml -n redis
```


#### 4. Create a Redis Enterprise database instance with SSL/TLS enabled
```
kubectl apply -f redb.yaml -n redis
```


#### 5. Deploy Nginx ingress controller
```
kubectl apply -f nginx-ingress-controller.yaml
```
Grab the external IP of the Nginx ingress controller for later use:
```
kubectl get service/ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```


#### 6. Create an Ingress resource for the Redis Enterprise cluster for web UI access
Replace <ingress-external-ip> with external IP of the Nginx ingress controller from step 5 in rec-ingress.yaml. Then run:
```
kubectl apply -f rec-ingress.yaml -n redis
```
Grab the password for demo@redislabs.com user for accessing REC's configuration manager (CM):
```
kubectl get secrets -n redis rec  -o json | jq '.data | {password}[] | @base64d'
```
Access the CM's login page using the following URL:
```
https://rec.<ingress-external-ip>.nip.io:443

For example:
https://rec.34.82.246.32.nip.io:443
```


#### 7. Generate and upload a SSL certificate for the Redis Enterprise database
```
openssl genrsa -out client.key 2048
```
When running the following command, just hit ENTER for every question except to enter *.rec.<ingress-external-ip>.nip.io for Common Name`:
```
openssl req -new -x509 -key client.key -out client.cert -days 1826
```
Copy and paste the content of client.cert file and upload it as SSL certificate for TLS communication as follows:
[TLS 01](./img/tls_01.png)
[TLS 02](./img/tls_02.png)
Copy the content of proxy_cert.pem from one of the REC pod to your machine running **openssl** command later:
```
kubectl exec -it rec-0 -c redis-enterprise-node -n redis -- /bin/bash
cd /etc/opt/redislabs
more proxy_cert.pem
```


#### 8. Create an Ingress resource for external traffic going into the Redis Enterprise database
Replace <ingress-external-ip> with external IP of the Nginx ingress controller from step 5 in redb-ingress.yaml.
Replace <redis-enterprise-database-port> with the Redis Enterprise database's listening port in redb-ingress.yaml.
Then run the following: 
```
kubectl apply -f redb-ingress.yaml -n redis
```


#### 9. Verify SSL/TLS connection using openssl
Grab the password of the Redis Enterprise database:
```
kubectl get secrets -n redis \
redb-redis-enterprise-database  -o json \
| jq '.data | {password}[] | @base64d'
```
Run the following to open a SSL session:
```
openssl s_client -connect redis-<redis-enterprise-database-port>.demo.rec.<ingress-external-ip>.nip.io:443 -key client.key -cert client.cert -CAfile ./proxy_cert.pem -servername redis-<redis-enterprise-database-port>.demo.rec.<ingress-external-ip>.nip.io

For example,
openssl s_client -connect redis-11338.demo.rec.34.127.23.12.nip.io:443 -key client.key -cert client.cert -CAfile ./proxy_cert.pem -servername redis-11338.demo.rec.34.127.23.12.nip.io
``` 
You should see a similar output as follows:
[openssl auth](./img/openssl_auth.png)
Replace the <redis-enterprise-database-password> with your Redis Enterprise database instance's password. Make sure there is a space after the password on MacOS. See below:
[openssl auth](./img/openssl_auth.png)
Send a **PING** command by entering PING followed by a blank spacei before hitting the **RETURN** button:
[openssl ping](./img/openssl_auth_ping.png)


#### 10. Connect to the Redis Enterprise database over SSL/TLS via a Python program
Run test.py to verify SSL/TLS connection:
```
python test.py <ingress-external-ip> <redis-enterprise-database-port> <redis-enterprise-database-password>

For example,
python test.py 34.83.49.103 16667 QUhZiDXB 
```
It should produce output about the Redis Enterprise database's information as follows:
[bdb info output](./img/test-py.png)
