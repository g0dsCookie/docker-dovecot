#!/usr/bin/env python3
import subprocess
import os
import os.path
import argparse
from threading import Thread, Lock
from sys import exit
import sys

DEBUG = False
LOGDIR = "logs"

PRINT_LOCK = Lock()

tag = "g0dscookie/dovecot"
versions = {
    "2.2.35": {
        "latest": False,
        "sieve": "0.4.23",
    },
    "2.2.36": {
        "latest": False,
        "sieve": "0.4.24",
    },
    "2.3.1": {
        "latest": False,
        "sieve": "0.5.1",
    },
    "2.3.2": {
        "latest": False,
        "sieve": "0.5.2",
    },
    "2.3.2.1": {
        "latest": True,
        "sieve": "0.5.2",
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

def build_tags(ver, latest, jumbo=False):
    if jumbo:
        return [
            "-t", "{}:{}-jumbo".format(tag, ver[0]),
            "-t", "{}:{}.{}-jumbo".format(tag, ver[0], ver[1]),
            "-t", "{}:{}.{}.{}-jumbo".format(tag, ver[0], ver[1], ver[2]),
        ]
    tags = []
    if latest:
        tags.extend(("-t", "{}:latest".format(tag)))
    tags.extend((
        "-t", "{}:{}".format(tag, ver[0]),
        "-t", "{}:{}.{}".format(tag, ver[0], ver[1]),
        "-t", "{}:{}.{}.{}".format(tag, ver[0], ver[1], ver[2]),
    ))
    return tags

def build_args(dovecot_ver, sieve_ver, jumbo=False, makeopts="-j1", cflags="-O2", cppflags="-O2"):
    return [
        "--build-arg", "DOVECOT_MAJOR={}".format(dovecot_ver[0]),
        "--build-arg", "DOVECOT_MINOR={}".format(dovecot_ver[1]),
        "--build-arg", "DOVECOT_PATCH={}".format(dovecot_ver[2]),
        "--build-arg", "SIEVE_VERSION={}".format(sieve_ver),
        "--build-arg", "JUMBO={}".format(str(jumbo)),
        "--build-arg", "MAKEOPTS={}".format(makeopts),
        "--build-arg", "CFLAGS={}".format(cflags),
        "--build-arg", "CPPFLAGS={}".format(cppflags),
    ]

def docker_build(ver, jumbo=False):
    PRINT_LOCK.acquire()
    print("Building {}-{}...".format(tag, ver))

    makeopts = os.getenv("MAKEOPTS", "-j1")
    cflags = os.getenv("CFLAGS", "-O2")
    cppflags = os.getenv("CPPFLAGS", "-O2")

    tags = build_tags(ver.split("."), versions[ver]["latest"], jumbo=jumbo)
    bargs = build_args(ver.split("."),
                       versions[ver]["sieve"],
                       makeopts=makeopts,
                       cflags=cflags,
                       cppflags=cppflags,
                       jumbo=jumbo)

    if LOGDIR != "stdout" and not os.path.isdir(LOGDIR):
        os.mkdir(LOGDIR)

    if DEBUG:
        print("JUMBO:           {}".format(str(jumbo)))
        print("MAKEOPTS:        {}".format(makeopts))
        print("CFLAGS:          {}".format(cflags))
        print("CPPFLAGS:        {}".format(cppflags))
        print("")
    PRINT_LOCK.release()

    if LOGDIR == "stdout":
        stdout = sys.stdout
        stderr = sys.stderr
    else:
        stdout = open(os.path.join(LOGDIR, "dovecot-" + ver + ".log"), mode="w")
        stderr = open(os.path.join(LOGDIR, "dovecot-" + ver + ".err"), mode="w")
    
    ret = subprocess.call(["docker", "build"] + tags + bargs + ["."], stdout=stdout, stderr=stderr)
    
    if LOGDIR != "stdout":
        stdout.close()
        stderr.close()
    
    if ret != 0:
        print("{} returned non-zero exit code: {}".format(" ".join(["docker", "build"] + tags + bargs + ["."]), ret))
        exit(ret)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="{} build script".format(tag))
    parser.add_argument("--version", default="all", type=str, help="Set the version to build (Defaults to %(default)s)")
    parser.add_argument("-d", "--debug", action='store_true', help="Enable debug output.")
    parser.add_argument("-l", "--logdir", metavar="LOGDIR", default="logs", type=str, help="Set the log directory (Defaults to %(default)s)")
    parser.add_argument("--stdout", action='store_true', help="Print log to stdout.")

    args = parser.parse_args()
    DEBUG = args.debug
    LOGDIR = args.logdir
    if args.stdout:
        LOGDIR = "stdout"

    if args.version == "all":
        if args.stdout:
            for ver in versions:
                docker_build(ver)
                docker_build(ver, jumbo=True)
        else:
            threads = []
            for ver in versions:
                t = Thread(target=docker_build, args=(ver,))
                t1 = Thread(target=docker_build, args=(ver,True,))
                t.start()
                t1.start()
                threads.extend([t, t1])
            for t in threads:
                t.join()
    elif args.version == "latest":
        for ver in versions:
            if versions[ver]["latest"]:
                docker_build(ver)
                exit(0)
        raise Exception('No "latest" version specified!')
    else:
        docker_build(args.version)
