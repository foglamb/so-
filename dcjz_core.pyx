# -*- coding: utf-8 -*-
import os, re, time, random, hashlib, requests, threading
from datetime import datetime

ENV_NAME = "dcjz"
ECPM_MIN = 6000
ECPM_MAX = 10000
COIN_MAX = 3000
COIN_MIN = 10
NETWORKS = [
    {"networkName": "gdt", "networkPlacementId": "4341184330757686", "local_type": "2", "cate": "2"},
    {"networkName": "adscope", "networkPlacementId": "126889", "local_type": "1", "cate": "4"},
    {"networkName": "adscope", "networkPlacementId": "126889", "local_type": "1", "cate": "4"},
    {"networkName": "AdGain", "networkPlacementId": "11003578", "local_type": "1", "cate": "4"},
    {"networkName": "gdt", "networkPlacementId": "4341184330757686", "local_type": "2", "cate": "2"},
]
BASE_URL = "https://dcjzapi.666666hh.cn/api/adver/myd/list"
APPID = "1"
API_VERSION = "1.1.5"
PREFIX = "f342ddDDWfdsEeeR@ER2F3233we423s2h2wGfWGDFgeRr@t*eFD3"
SUFFIX = "23#x9!F$g3@kL8&qW1^pZ0*rT7%vU4$nM2"

def now():
    return datetime.now().strftime('%Y-%m-%d %H:%M:%S')

def qmsg_send(msg):
    qmsg_key = os.environ.get("QMSG_KEY", "")
    if not qmsg_key:
        return
    try:
        url = f"https://qmsg.zendee.cn/send/{qmsg_key}"
        resp = requests.post(url, data={"msg": msg}, timeout=10)
        if resp.json().get("success"):
            print(f"[{now()}] Qmsg ok")
    except:
        pass

def get_tokens(ts):
    return hashlib.sha256((PREFIX + ts + SUFFIX).encode()).hexdigest()

def fetch_coins(account):
    ts = str(int(time.time()))
    headers = {"Host": "dcjzapi.666666hh.cn", "tokens": get_tokens(ts), "x-api-time": ts, "token": account["token"], "version": API_VERSION, "appid": APPID, "content-type": "application/x-www-form-urlencoded", "accept-encoding": "gzip", "user-agent": "okhttp/4.9.0"}
    ecpm = random.randint(ECPM_MIN, ECPM_MAX)
    net = random.choice(NETWORKS)
    data = {"type": "", "lat": "", "lng": "", "device_id": account["device_id"], "sign": "", "token1": "", "brand_model": account["brand_model"], "brand": account["brand"], "model": account["model"], "ecpm": str(ecpm), "loadid": "", "networkName": net["networkName"], "networkPlacementId": net["networkPlacementId"], "local_type": net["local_type"], "version": "36", "time": str(int(time.time()*1000)), "cate": net["cate"]}
    try:
        result = requests.post(BASE_URL, headers=headers, data=data, timeout=10).json()
        if result.get("code") == 200 and result.get("data"):
            m = re.search(r'(\d+)', result["data"].get("unclaimed_coins", "0"))
            if m: return int(m.group(1))
    except: pass
    return None

def run_account(note, account):
    print(f"[{now()}] [{note}] {account['device_id'][:12]}... start")
    lc, ls = -1, ""
    while True:
        c = fetch_coins(account)
        if c is None:
            time.sleep(2); continue
        if c >= COIN_MAX:
            s = "max"
            if ls != "max":
                w = random.uniform(60,70)
                print(f"[{now()}] [{note}] coins:{c} | {s} | wait {w:.0f}s")
                qmsg_send(f"dcjz {note} max {COIN_MAX} coins:{c}")
            lc, ls = c, s
            time.sleep(random.uniform(60,70))
        elif c <= COIN_MIN:
            s = "recover"
            if c != lc: print(f"[{now()}] [{note}] coins:{c} | {s}")
            lc, ls = c, s
            time.sleep(random.uniform(15,21))
        else:
            s = "running"
            if c != lc: print(f"[{now()}] [{note}] coins:{c} | {s}")
            lc, ls = c, s
            time.sleep(random.uniform(15,21))

def main():
    print(f"[{now()}] Script started")
    raw = os.environ.get(ENV_NAME, "")
    if not raw:
        print(f"[{now()}] Missing env: {ENV_NAME}")
        return
    accounts = []
    for i, acc in enumerate(raw.split("&"), 1):
        parts = acc.strip().split("#")
        if len(parts) != 6:
            print(f"[{now()}] Account {i} format error")
            continue
        accounts.append({"note": parts[0], "token": parts[1], "device_id": parts[2], "brand_model": parts[3], "brand": parts[4], "model": parts[5]})
    if not accounts:
        print(f"[{now()}] No accounts")
        return
    print(f"[{now()}] Loaded {len(accounts)} accounts")
    threads = []
    for acc in accounts:
        t = threading.Thread(target=run_account, args=(acc["note"], acc))
        threads.append(t); t.start()
    for t in threads: t.join()

if __name__ == "__main__":
    main()
