Deploy Docker Image by Docker Compose
-------------------------------------


# Desc

Build illa utils slim image and run it by docker compose on your machine.  
You can check out the scripts file which in [scripts](./scripts/) folder for more details.

Note:

We highly recommended deploying with our auto-deploy tools [illa-cli](https://github.com/illacloud/illa).

And for the moment we do not support Apple Silicon M1 (darwin-arm64 arch).


# Index

- [Desc](#desc)
- [Index](#index)
- [Run with official slim image](#run-with-official-slim-image)
- [For Database Persistent Storage](#for-database-persistent-storage)
- [For HTTPS Config](#for-https-config)


# Run with official slim image

Config your server address in: 

- [illa-frontend.yaml](illa-frontend.yaml) 
- [illa-backend.yaml](illa-backend.yaml)
- [illa-backend-ws.yaml](illa-backend-ws.yaml)


replace the ```API_SERVER_ADDRESS```, ```WEBSOCKET_SERVER_ADDRESS``` with your server ingress address or domain.

Install GNU make and type: 

```sh
make deploy
```

or just execute:

```sh
/bin/bash scripts/deploy.sh
```

this command will pull illasoft official slim image and deploy it on your kubernetes cluster.

And Login with default username **```root```** and password **```password```**.

# For Database Persistent Storage

Edit [illa-database.yaml](illa-database.yaml), add your IAAS persistent storage config on it.


# For HTTPS Config

You can route the NodePort to your kubernetes cluster ingress gateway and rewrite to 443 port, and add https cert in your ingress gateway.  

Or, you can deploy an ingress gateway manually into your kubernetes server, config like this:  

```yaml
static_resources:
  listeners:
  - name: https_listener
    address:
      socket_address:
        address: 0.0.0.0
        port_value: 443
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: https_listener
          route_config:
            name: local_route
            virtual_hosts:
            - name: illa_frontend
              domains:
              - "illa.yourdomian.com" # replace with your domain
              routes:
              - match:
                  prefix: "/"
                route:
                  cluster: illa_frontend
            - name: illa_backend
              domains:
              - "illa-api.yourdomian.com" # replace with your domain
              routes:
              - match:
                  prefix: "/"
                route:
                  cluster: illa_backend
            - name: illa_backend_ws
              domains:
              - "illa-ws.yourdomian.com" # replace with your domain
              routes:
              - match:
                  prefix: "/"
                route:
                  cluster: illa_backend_ws
          http_filters:
          - name: envoy.filters.http.router
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.http.router.v3.Router
      transport_socket:
        name: envoy.transport_sockets.tls
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.DownstreamTlsContext
          common_tls_context:
            tls_certificates:
            # replace this with your cert file
            - certificate_chain:
                filename: /your-cert-folder/fullchain.pem
              private_key:
                filename: /your-cert-folder/privkey.pem

  clusters:
  - name: illa_frontend
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    connect_timeout: 10s
    load_assignment:
      cluster_name: illa_frontend
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: illa-frontend
                port_value: 80
  - name: illa_backend
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    connect_timeout: 10s
    load_assignment:
      cluster_name: illa_backend
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: illa-backend
                port_value: 9999
  - name: illa_backend_ws
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    connect_timeout: 10s
    load_assignment:
      cluster_name: illa_backend_ws
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: illa-backend-ws
                port_value: 8000
