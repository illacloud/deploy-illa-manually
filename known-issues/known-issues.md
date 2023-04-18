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



# Error: file access denied (cmd.StorageErr)

The error info like:

```
API: SYSTEM()
Time: 23:20:24 UTC 04/17/2023
DeploymentID: c0e0ac14-c375-41e8-9e4d-96e1c34fa987
Error: file access denied (cmd.StorageErr)
    2: cmd/fs-v1.go:305:cmd.(*FS0bjects).NSScanner()
    1: cmd/data-scanner.go:151:cmd.runDataScanner()
API :SYSTEM()
Time: 23:21:24 UTC 04/17/2023
DeploymentID: c0e0ac14-c375-41e8-9e4d-96e1c34fa987
Error: file access denied (cmd.StorageErr)
    2: cmd/fs-v1.go:305:cmd.(*FS0bjects).NSScanner()
    1: cmd/data-scanner.go:151:cmd.runDataScanner()
```

Illa use minio for internal object storage, and the minio compatible file system list are here (linux environment):
- TMPFS
- EXT
- HFS
- MSDOS
- REISERFS
- NTFS
- XFS
- AUFS
- NFS
- EXT2OLD
- EXT4
- ecryptfs
- overlayfs
- zfs
- cifs
- wslfs
  
[Compatible file system list from minio source code](https://github.com/minio/minio/blob/202d0b64eb5fb503310ee4ae5116bbdf3219257d/internal/disk/type_linux.go#L26)

Other file systems will cause the compatible issue. So please make sure your filesystem is in these lists.
