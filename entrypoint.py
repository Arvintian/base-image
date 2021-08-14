import signal
import subprocess
import time
import traceback
import schedule
import threading


def start_service(service):
    cmd = ["service", service, "start"]
    return subprocess.run(cmd, check=True)


def stop_service(service):
    cmd = ["service", service, "stop"]
    return subprocess.run(cmd, check=True)


def restart_service(service):
    cmd = ["service", service, "restart"]
    return subprocess.run(cmd, check=True)


def main():
    services = ["ssh", "rsyslog", "cron", "nginx", "php7.2-fpm"]

    # start services
    for svc in services:
        try:
            start_service(svc)
        except Exception as e:
            print(traceback.format_exc())
        time.sleep(1)

    # register daily restart services
    def restart_services():
        for svc in services:
            try:
                restart_service(svc)
            except Exception as e:
                print(traceback.format_exc())
            time.sleep(1)

    def daily_restart():
        print("*Start daily restart thread")
        schedule.every().day.at("00:30").do(restart_services)
        while True:
            schedule.run_pending()
            time.sleep(1)

    threading.Thread(target=daily_restart, daemon=True).run()

    # exit and kill services
    def exit_kill(sig, frame):
        for svc in services:
            try:
                stop_service(svc)
            except Exception as e:
                print(traceback.format_exc())
    for sig in [signal.SIGINT, signal.SIGHUP, signal.SIGTERM]:
        signal.signal(sig, exit_kill)
    signal.pause()


if __name__ == "__main__":
    main()
