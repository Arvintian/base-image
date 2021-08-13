import signal
import subprocess
import time

def start_service(service):
    cmd = ["service", service, "start"]
    return subprocess.run(cmd)


def stop_service(service):
    cmd = ["service", service, "stop"]
    return subprocess.run(cmd)


def main():
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
