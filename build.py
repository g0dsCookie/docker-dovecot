#!/usr/bin/env python3
import subprocess
import os
import os.path
import argparse
from threading import Thread, Lock

DEBUG = False
LOGDIR = "logs"

PRINT_LOCK = Lock()

tag = "g0dscookie/dovecot"
versions = {
    "2.2.35": {
        "latest": False,
        "sieve": "0.4.23",
        "deps": [
            "curl",
            "libressl",
            "zlib",
            "bzip2",
            "libcap",
            "mariadb",
            "postgresql",
            "expat",
            "sqlite",
            "krb5",
            "openldap",
            "clucene",
            "lz4",
            "xz",
            "icu",
        ],
        "dovecot_config": [
            "--disable-rpath",
            "--with-bzlib",
            "--with-libcap",
            "--with-gssapi",
            "--with-ldap",
            "--with-sql",
            "--with-mysql",
            "--with-pgsql",
            "--with-sqlite",
            "--with-solr",
            "--with-ssl=openssl",
            "--with-zlib",
            "--without-stemmer",
            "--with-lucene",
            "--with-icu",
            "--with-lz4",
            "--with-lzma",
        ],
        "sieve_config": []
    },
    "2.3.1": {
        "latest": True,
        "sieve": "0.5.1",
        "deps": "2.2.35",
        "dovecot_config": "2.2.35",
        "sieve_config": "2.2.35"
    }
}

def check_version(version):
    if not version in versions:
        raise Exception("Unknown dovecot version " + version)

def get_config(ver, cfg):
    check_version
    tmp = versions[ver][cfg]
    if type(tmp) is str:
        return get_config(tmp, cfg)
    elif type(tmp) is dict:
        return get_config(tmp["base"], cfg) + tmp["my"]
    else:
        return tmp

def build_tags(ver, latest):
    tags = []
    if latest:
        tags.extend(("-t", "{}:latest".format(tag)))
    tags.extend((
        "-t", "{}:{}".format(tag, ver[0]),
        "-t", "{}:{}.{}".format(tag, ver[0], ver[1]),
        "-t", "{}:{}.{}.{}".format(tag, ver[0], ver[1], ver[2]),
    ))
    return tags

def build_args(dovecot_ver, sieve_ver, dovecot_cfg, sieve_cfg, deps, makeopts="-j1", cflags="-O2", cppflags="-O2"):
    return [
        "--build-arg", "DOVECOT_MAJOR={}".format(dovecot_ver[0]),
        "--build-arg", "DOVECOT_MINOR={}".format(dovecot_ver[1]),
        "--build-arg", "DOVECOT_PATCH={}".format(dovecot_ver[2]),
        "--build-arg", "SIEVE_MAJOR={}".format(sieve_ver[0]),
        "--build-arg", "SIEVE_MINOR={}".format(sieve_ver[1]),
        "--build-arg", "SIEVE_PATCH={}".format(sieve_ver[2]),
        "--build-arg", "DOVECOT_DEPS={}".format(" ".join(deps)),
        "--build-arg", "BUILD_DEPS={}".format(" ".join("{}-dev".format(d) for d in deps)),
        "--build-arg", "DOVECOT_CONFIG={}".format(" ".join(dovecot_cfg)),
        "--build-arg", "SIEVE_CONFIG={}".format(" ".join(sieve_cfg)),
        "--build-arg", "MAKEOPTS={}".format(makeopts),
        "--build-arg", "CFLAGS={}".format(cflags),
        "--build-arg", "CPPFLAGS={}".format(cppflags),
    ]

def docker_build(ver):
    PRINT_LOCK.acquire()
    print("Building {}-{}...".format(tag, ver))
    dovecot_config = get_config(ver, "dovecot_config")
    sieve_config = get_config(ver, "sieve_config")

    makeopts = os.getenv("MAKEOPTS", "-j1")
    cflags = os.getenv("CFLAGS", "-O2")
    cppflags = os.getenv("CPPFLAGS", "-O2")

    tags = build_tags(ver.split("."), versions[ver]["latest"])
    bargs = build_args(ver.split("."),
                            versions[ver]["sieve"].split("."),
                            dovecot_config,
                            sieve_config,
                            get_config(ver, "deps"),
                            makeopts=makeopts,
                            cflags=cflags,
                            cppflags=cppflags)

    if not os.path.isdir(LOGDIR):
        os.mkdir(LOGDIR)

    if DEBUG:
        print("DEPS:            {}".format(" ".join(get_config(ver, "deps"))))
        print("BUILD DEPS:      {}".format(" ".join("{}-dev".format(d) for d in get_config(ver, "deps"))))
        print("DOVECOT_CONFIG:  {}".format(dovecot_config))
        print("SIEVE_CONFIG:    {}".format(sieve_config))
        print("MAKEOPTS:        {}".format(makeopts))
        print("CFLAGS:          {}".format(cflags))
        print("CPPFLAGS:        {}".format(cppflags))
        print("")
    PRINT_LOCK.release()

    stdout = open(os.path.join(LOGDIR, "dovecot-" + ver + ".log"), mode="w")
    stderr = open(os.path.join(LOGDIR, "dovecot-" + ver + ".err"), mode="w")
    subprocess.call(["docker", "build"] + tags + bargs + ["."], stdout=stdout, stderr=stderr)
    stdout.close()
    stderr.close()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="{} build script".format(tag))
    parser.add_argument("--version", default="all", type=str, help="Set the version to build (Defaults to %(default)s")
    parser.add_argument("-d", "--debug", action='store_true', help="Enable debug output.")
    parser.add_argument("-l", "--logdir", metavar="LOGDIR", default="logs", type=str, help="Set the log directory (Defaults to %(default)s")

    args = parser.parse_args()
    DEBUG = args.debug
    LOGDIR = args.logdir

    if args.version == "all":
        
        threads = []
        for ver in versions:
            t = Thread(target=docker_build, args=(ver,))
            t.start()
            threads.append(t)
        for t in threads:
            t.join()
    else:
        docker_build(args.version)