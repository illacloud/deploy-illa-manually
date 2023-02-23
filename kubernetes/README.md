Deploy Docker Image by Docker Compose
-------------------------------------


# Desc

Build illa all-in-one image and run it by k8s on your machine.  
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

Install GNU make and type: 

```sh
make deploy
```

or just execute:

```sh
/bin/bash scripts/deploy.sh
```

this command will pull illasoft official all-in-one image and deploy it on your kubernetes cluster.

# For Database Persistent Storage

Edit [illa-builder.yaml](illa-builder.yaml), add your IAAS persistent storage config on it.


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
            - name: illa_builder
              domains:
              - "illa.yourdomian.com" # replace with your domain
              routes:
              - match:
                  prefix: "/"
                route:
                  cluster: illa_builder
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
  - name: illa_builder
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    connect_timeout: 10s
    load_assignment:
      cluster_name: illa_builder
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: illa-builder
                port_value: 80
