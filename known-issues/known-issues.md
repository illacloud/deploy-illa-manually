known-issues
------------




# Mount Type Issue 

Run ```illa deploy --self -port=1000 -s={your-ip-address}``` or ```run-official-image.sh```, return following error:

```
Docker responded with status code 400: invalid mount config for type "bind": bind source path does not exist: /tmp/illa-data
```

For now, the mount type only supports ```mount```, please config ```docker -v``` as ```mount``` mode. Or reinstall the docker by following scripts.

- [reinstall-docker-with-ubuntu.sh](../utils/reinstall-docker-with-ubuntu.sh)

And run deploy command again.
