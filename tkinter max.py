import tkinter as tk
import json
import os
import time

# متغیرهای بازی
coins = 0
click_power = 1
auto_click_level = 0
click_count = 0
start_time = time.time()

SAVE_FILE = "clicker_save.json"

def update_labels():
    coin_label.config(text=f"🪙 سکه: {coins}")
    click_upgrade_btn.config(text=f"قدرت کلیک (+{click_power}) - قیمت: {click_power * 10}")
    auto_click_btn.config(text=f"کلیک خودکار سطح {auto_click_level} - قیمت: {(auto_click_level + 1) * 50}")
    click_stats.config(text=f"📊 کلیک‌ها: {click_count}")
    time_stats.config(text=f"⏱ زمان بازی: {int(time.time() - start_time)} ثانیه")

def click():
    global coins, click_count
    coins += click_power
    click_count += 1
    update_labels()

def upgrade_click():
    global coins, click_power
    cost = click_power * 10
    if coins >= cost:
        coins -= cost
        click_power += 1
        update_labels()

def upgrade_auto_click():
    global coins, auto_click_level
    cost = (auto_click_level + 1) * 50
    if coins >= cost:
        coins -= cost
        auto_click_level += 1
        update_labels()

def auto_click_loop():
    global coins
    coins += auto_click_level
    update_labels()
    root.after(1000, auto_click_loop)

def save_game():
    state = {
        "coins": coins,
        "click_power": click_power,
        "auto_click_level": auto_click_level,
        "click_count": click_count,
        "start_time": start_time
    }
    with open(SAVE_FILE, "w") as f:
        json.dump(state, f)

def load_game():
    global coins, click_power, auto_click_level, click_count, start_time
    if os.path.exists(SAVE_FILE):
        with open(SAVE_FILE, "r") as f:
            state = json.load(f)
            coins = state.get("coins", 0)
            click_power = state.get("click_power", 1)
            auto_click_level = state.get("auto_click_level", 0)
            click_count = state.get("click_count", 0)
            start_time = state.get("start_time", time.time())

def reset_game():
    global coins, click_power, auto_click_level, click_count, start_time
    coins = 0
    click_power = 1
    auto_click_level = 0
    click_count = 0
    start_time = time.time()
    save_game()
    update_labels()

def on_closing():
    save_game()
    root.destroy()

# UI
root = tk.Tk()
root.title("🎮 بازی کلیکر پیشرفته")
root.geometry("400x450")
root.protocol("WM_DELETE_WINDOW", on_closing)

coin_label = tk.Label(root, text="🪙 سکه: 0", font=("Arial", 16))
coin_label.pack(pady=10)

click_button = tk.Button(root, text="کلیک کن!", font=("Arial", 20), width=20, command=click)
click_button.pack(pady=10)

click_upgrade_btn = tk.Button(root, text="", command=upgrade_click)
click_upgrade_btn.pack(pady=5)

auto_click_btn = tk.Button(root, text="", command=upgrade_auto_click)
auto_click_btn.pack(pady=5)

click_stats = tk.Label(root, text="📊 کلیک‌ها: 0", font=("Arial", 12))
click_stats.pack(pady=5)

time_stats = tk.Label(root, text="⏱ زمان بازی: 0 ثانیه", font=("Arial", 12))
time_stats.pack(pady=5)

# دکمه‌ها
tk.Button(root, text="ذخیره بازی", command=save_game).pack(side="left", padx=10, pady=20)
tk.Button(root, text="بارگذاری بازی", command=load_game).pack(side="left", padx=10)
tk.Button(root, text="🔄 ریست بازی", command=reset_game).pack(side="right", padx=10)

# راه‌اندازی
load_game()
update_labels()
auto_click_loop()
root.mainloop()
