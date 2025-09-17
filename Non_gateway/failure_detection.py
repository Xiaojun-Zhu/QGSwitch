import subprocess
import time
import argparse
from datetime import datetime
from scapy.all import ARP, Ether, srp

def log(msg):
    now = datetime.now().strftime("[%Y-%m-%d %H:%M:%S]")
    print(f"{now} {msg}")

def check_gateway_connection(gateway_ip, interface, timeout):
    command = ["ping", "-c", "1", "-W", str(timeout), "-I", interface, gateway_ip]
    process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    start_time = time.time()
    while True:
        if process.poll() is not None:
            return process.returncode == 0
        if time.time() - start_time > timeout:
            process.kill()
            return False
        time.sleep(0.1)

def clear_arp_entry(gateway_ip):
    log(f"Flushing ARP entry for {gateway_ip}...")
    subprocess.call(["sudo", "ip", "neigh", "flush", gateway_ip])

def gateway_probing(gateway_ip, interface):
    log(f"Sending ARP broadcast to {gateway_ip} on {interface}...")
    ether = Ether(dst="ff:ff:ff:ff:ff:ff")
    arp = ARP(pdst=gateway_ip)
    packet = ether / arp
    ans, _ = srp(packet, timeout=2, iface=interface, verbose=False)
    if ans:
        for sent, received in ans:
            log(f" Got ARP reply from {received.psrc} ({received.hwsrc})")
            return True
    log(" No ARP reply received.")
    return False

def failure_detection(gateway_ip, interface, fail_threshold, ping_timeout, interval):
    log("QGSwitch Failure Detection started...")
    fail_count = 0
    while True:
        alive = check_gateway_connection(gateway_ip, interface, ping_timeout)
        if alive:
            log(" Gateway is alive.")
            fail_count = 0
        else:
            fail_count += 1
            log(f" Gateway check failed ({fail_count} times)")

        if fail_count >= fail_threshold:
            log(" Gateway appears down. Entering persistent ARP broadcast mode...")
            clear_arp_entry(gateway_ip)
            while True:
                arp_ok = gateway_probing(gateway_ip, interface)
                alive = check_gateway_connection(gateway_ip, interface, ping_timeout)
                if arp_ok or alive:
                    log(" Gateway is back online.")
                    break
                time.sleep(interval)
            fail_count = 0

        time.sleep(interval)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="QGSwitch Failure Detection")
    parser.add_argument("--gateway", default="192.168.199.1", help="Gateway IP address")
    parser.add_argument("--interface", default="bat0", help="Network interface name")
    parser.add_argument("--fail-threshold", type=int, default=1, help="Failures before triggering ARP mode")
    parser.add_argument("--ping-timeout", type=int, default=1, help="Ping timeout in seconds")
    parser.add_argument("--interval", type=float, default=0.2, help="Heartbeat interval in seconds")
    args = parser.parse_args()

    failure_detection(args.gateway, args.interface, args.fail_threshold, args.ping_timeout, args.interval)
