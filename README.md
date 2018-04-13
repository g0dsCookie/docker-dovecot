# dovecot image

This image provides an *unofficial* dockerized dovecot image.

## Table of Contents

1. [Supported tags and versions](#supported-tags-and-versions)
2. [Quick reference](#quick-reference)
3. [How to use this image](#how-to-use-this-image)
    1. [Run the container](#run-the-container)
    2. [Use custom container](#use-custom-container)
    3. [Use bind mounts](#use-bind-mounts)
    4. [Available volumes](#available-volumes)

## Supported tags and versions

* [`2.2.35`, `2.2` (*2.2/Dockerfile*)](https://github.com/g0dsCookie/docker-dovecot/blob/master/Dockerfile)
* [`2.3.1`, `2.3`, `2`, `latest` (*2.3/Dockerfile*)](https://github.com/g0dsCookie/docker-dovecot/blob/master/Dockerfile)

## Quick reference

* **Where to file issues**:

    [https://github.com/g0dsCookie/docker-dovecot/issues](https://github.com/g0dsCookie/docker-dovecot/issues)

* **Maintained by**:

    [g0dsCookie](https://github.com/g0dsCookie)

## How to use this image

### Run the container

This container has no default configuration. You need to either build your own container
with this as base and `COPY` your configuration, or you can use bind mounts.

### Use custom container

```Dockerfile
FROM g0dscookie/dovecot:2.3
COPY config /etc/dovecot/dovecot.cfg
```

Now build your container with `$ docker build -t my-dovecot .`.

### Use bind mounts

`$ docker run -d --name my-dovecot -v /path/to/config:/etc/dovecot:ro g0dscookie/dovecot:2.3`

Note that **/path/to/config** is a directory.

### Available volumes

* /data
  * Here you can store your mails
* /certs
  * Here you can mount your certificates used by dovecot.
* /etc/dovecot
  * Dovecot configuration files.
* /sieve-pipe
  * Here you can mount extra programs which you can then use in your configuration for sieve-pipe.
* /sieve-filter
  * Here you can mount extra programs which you can then use in your configuration for sieve-filter.

## Update instructions

1. Add new dovecot version to `build.py`
2. `make VERSION="<VERSION>"`
    1. Omit `VERSION=` or set `<VERSION>` to **latest** if you are building a latest version.
3. `make push`
4. Commit your changes and push them
