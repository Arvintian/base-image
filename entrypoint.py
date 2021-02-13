import signal
import subprocess
import time
import random
import json
import os


def ranstr(num):
    s = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
    salt = ''
    for i in range(num):
        salt += random.choice(s)
    return salt


def setup_passwd():
    init_dict = {}
    with open("/entrypoint/init.json", "r") as fd:
        init_dict = json.loads(fd.read())
    if not init_dict.get("passwd"):
        password = ranstr(16)
        cmd = "echo ubuntu:{}|chpasswd".format(password)
        os.popen(cmd)
        print(" * setup init password {}".format(password))
        init_dict.update({
            "passwd": True
        })
    with open("/entrypoint/init.json", "w") as fd:
        fd.write(json.dumps(init_dict))


def start_service(service):
    cmd = ["service", service, "start"]
    return subprocess.run(cmd)


def stop_service(service):
    cmd = ["service", service, "stop"]
    return subprocess.run(cmd)


def main():
    setup_passwd()
    services = ["ssh", "rsyslog", "cron", "nginx", "php7.2-fpm"]
    for svc in services:
        start_service(svc)
        time.sleep(1)

    def exit_kill(sig, frame):
        for svc in services:
            stop_service(svc)
    for sig in [signal.SIGINT, signal.SIGHUP, signal.SIGTERM]:
        signal.signal(sig, exit_kill)
    signal.pause()


if __name__ == "__main__":
    main()
