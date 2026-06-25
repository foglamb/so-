# -*- coding: utf-8 -*-
# cython: language_level=3
import os
import re
import time
import random
import hashlib
import requests
import threading
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
            print(f"[{now()}] 📩 Qmsg通知发送成功")
    except:
        pass

def get_tokens(time_str):
    raw = PREFIX + time_str + SUFFIX
    return hashlib.sha256(raw.encode()).hexdigest()

def fetch_coins(account):
    timestamp = str(int(time.time()))
    headers = {
        "Host": "dcjzapi.666666hh.cn",
        "tokens": get_tokens(timestamp),
        "x-api-time": timestamp,
        "token": account["token"],
        "version": API_VERSION,
        "appid": APPID,
        "content-type": "application/x-www-form-urlencoded",
        "accept-encoding": "gzip",
        "user-agent": "okhttp/4.9.0",
    }
    ecpm = random.randint(ECPM_MIN, ECPM_MAX)
    net = random.choice(NETWORKS)
    now_ms = str(int(time.time() * 1000))
    data = {
        "type": "", "lat": "", "lng": "", "device_id": account["device_id"],
        "sign": "", "token1": "", "brand_model": account["brand_model"],
        "brand": account["brand"], "model": account["model"],
        "ecpm": str(ecpm), "loadid": "",
        "networkName": net["networkName"], "networkPlacementId": net["networkPlacementId"],
        "local_type": net["local_type"], "version": "36", "time": now_ms, "cate": net["cate"],
    }
    try:
        resp = requests.post(BASE_URL, headers=headers, data=data, timeout=10)
        result = resp.json()
        if result.get("code") == 200 and result.get("data"):
            coins_str = result["data"].get("unclaimed_coins", "0金币")
            match = re.search(r'(\d+)', coins_str)
            if match:
                return int(match.group(1))
    except:
        pass
    return None

def run_account(note, account):
    print(f"[{now()}] [{note}] device_id:{account['device_id'][:12]}... | 开始运行")
    last_coins = -1
    last_state = ""
    while True:
        coins = fetch_coins(account)
        if coins is None:
            time.sleep(2)
            continue
        if coins >= COIN_MAX:
            state = "已达上限"
            wait_time = random.uniform(60, 70)
            if last_state != "已达上限":
                print(f"[{now()}] [{note}] 金币:{coins} | 状态:{state} | 等待{wait_time:.1f}秒")
                qmsg_send(f"【dcjz】{note}\n💰 已达上限 {COIN_MAX}\n当前金币: {coins}\n⏳ {wait_time:.1f}秒后自动继续")
            last_coins = coins
            last_state = state
            time.sleep(wait_time)
        elif coins <= COIN_MIN:
            state = "恢复运行"
            if coins != last_coins:
                print(f"[{now()}] [{note}] 金币:{coins} | 状态:{state}")
            last_coins = coins
            last_state = state
            time.sleep(random.uniform(15, 21))
        else:
            state = "运行中"
            if coins != last_coins:
                print(f"[{now()}] [{note}] 金币:{coins} | 状态:{state}")
            last_coins = coins
            last_state = state
            time.sleep(random.uniform(15, 21))

def main():
    print(f"[{now()}] 🚀 脚本启动 多财金猪foglamb内部")
    raw = os.environ.get(ENV_NAME, "")
    if not raw:
        print(f"[{now()}] ❌ 请设置环境变量 {ENV_NAME}")
        return
    raw_index = os.environ.get("dcjz_INDEX", "")
    allowed_indices = None
    if raw_index.strip():
        try:
            allowed_indices = set()
            for part in raw_index.split(","):
                part = part.strip()
                if "-" in part:
                    s, e = part.split("-", 1)
                    allowed_indices.update(range(int(s), int(e) + 1))
                else:
                    allowed_indices.add(int(part))
        except:
            print(f"[{now()}] ❌ dcjz_INDEX 格式错误")
            return
        print(f"[{now()}] 🎯 仅执行指定账号: {sorted(allowed_indices)}")
    accounts = []
    for i, acc in enumerate(raw.split("&"), 1):
        parts = acc.strip().split("#")
        if len(parts) != 6:
            print(f"[{now()}] ❌ 第{i}个账号格式错误！正确格式：备注#token#device_id#brand_model#brand#model")
            continue
        if allowed_indices is not None and i not in allowed_indices:
            continue
        accounts.append({
            "note": parts[0], "token": parts[1], "device_id": parts[2],
            "brand_model": parts[3], "brand": parts[4], "model": parts[5],
        })
    if not accounts:
        print(f"[{now()}] ❌ 无有效账号")
        return
    print(f"[{now()}] ✅ 加载 {len(accounts)} 个账号\n")
    threads = []
    for acc in accounts:
        t = threading.Thread(target=run_account, args=(acc["note"], acc))
        threads.append(t)
        t.start()
    for t in threads:
        t.join()

if __name__ == "__main__":
    main()
