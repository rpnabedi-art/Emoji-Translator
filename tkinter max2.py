import tkinter as tk
import json
import os
import time

coins = 10000000000
click_power = 10000000
auto_click_level = 100000
click_count = 100000
start_time = time.time()

SAVE_FILE = "clicker_save.json"

BG_COLOR = "#282c34"
FG_COLOR = "#abb2bf"
BTN_COLOR = "#61afef"
BTN_HOVER_COLOR = "#528ecc"
FONT_TITLE = ("Segoe UI", 18, "bold")
FONT_BTN = ("Segoe UI", 14, "bold")
FONT_LABEL = ("Segoe UI", 12)
FONT_STATS = ("Segoe UI", 10)

def update_labels():
    coin_label.config(text=f"🪙 سکه: {coins}", fg="#e5c07b")
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

def on_enter(e):
    e.widget['background'] = BTN_HOVER_COLOR

def on_leave(e):
    e.widget['background'] = BTN_COLOR

#UI design
root = tk.Tk()
root.title("🎮 بازی کلیکر پیشرفته")
root.geometry("420x480")
root.config(bg=BG_COLOR)
root.protocol("WM_DELETE_WINDOW", on_closing)

coin_label = tk.Label(root, text="🪙 سکه: 0", font=FONT_TITLE, bg=BG_COLOR, fg="#e5c07b")
coin_label.pack(pady=15)

click_button = tk.Button(root, text="کلیک کن!", font=FONT_BTN, width=22, height=2, bg=BTN_COLOR, fg="white", activebackground=BTN_HOVER_COLOR, command=click, relief="raised", bd=3)
click_button.pack(pady=15)
click_button.bind("<Enter>", on_enter)
click_button.bind("<Leave>", on_leave)

click_upgrade_btn = tk.Button(root, text="", font=FONT_LABEL, bg=BTN_COLOR, fg="white", command=upgrade_click, relief="raised", bd=2)
click_upgrade_btn.pack(pady=8, ipadx=10, ipady=5)
click_upgrade_btn.bind("<Enter>", on_enter)
click_upgrade_btn.bind("<Leave>", on_leave)

auto_click_btn = tk.Button(root, text="", font=FONT_LABEL, bg=BTN_COLOR, fg="white", command=upgrade_auto_click, relief="raised", bd=2)
auto_click_btn.pack(pady=8, ipadx=10, ipady=5)
auto_click_btn.bind("<Enter>", on_enter)
auto_click_btn.bind("<Leave>", on_leave)

click_stats = tk.Label(root, text="📊 کلیک‌ها: 0", font=FONT_STATS, bg=BG_COLOR, fg=FG_COLOR)
click_stats.pack(pady=5)

time_stats = tk.Label(root, text="⏱ زمان بازی: 0 ثانیه", font=FONT_STATS, bg=BG_COLOR, fg=FG_COLOR)
time_stats.pack(pady=5)

# دکمه‌ها ذخیره و بارگذاری و ریست
btn_frame = tk.Frame(root, bg=BG_COLOR)
btn_frame.pack(pady=20)

save_btn = tk.Button(btn_frame, text="💾 ذخیره بازی", font=FONT_LABEL, bg=BTN_COLOR, fg="white", command=save_game, relief="raised", bd=2)
save_btn.grid(row=0, column=0, padx=10)
save_btn.bind("<Enter>", on_enter)
save_btn.bind("<Leave>", on_leave)

load_btn = tk.Button(btn_frame, text="📂 بارگذاری بازی", font=FONT_LABEL, bg=BTN_COLOR, fg="white", command=load_game, relief="raised", bd=2)
load_btn.grid(row=0, column=1, padx=10)
load_btn.bind("<Enter>", on_enter)
load_btn.bind("<Leave>", on_leave)

reset_btn = tk.Button(btn_frame, text="🔄 ریست بازی", font=FONT_LABEL, bg=BTN_COLOR, fg="white", command=reset_game, relief="raised", bd=2)
reset_btn.grid(row=0, column=2, padx=10)
reset_btn.bind("<Enter>", on_enter)
reset_btn.bind("<Leave>", on_leave)


load_game()
update_labels()
auto_click_loop()
root.mainloop()

