import redis

r = redis.StrictRedis(host='redis-11338.demo.rec.34.127.23.12.nip.io',
                port=443, db=0, ssl=True, password='pjv4P1OB',
                ssl_keyfile='/Users/gilbertlau/Documents/Demo/GKE/client.key',
                ssl_certfile='/Users/gilbertlau/Documents/Demo/GKE/client.cert',
                ssl_ca_certs='/Users/gilbertlau/Documents/Demo/GKE/proxy_cert.pem')


print(r.info())
