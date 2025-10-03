import tkinter as tk
import json
import os


coins = 0
click_power = 1
auto_click_level = 0

def update_labels():
    coin_label.config(text=f"🪙 coin: {coins}")
    click_upgrade_btn.config(text=f"افزایش قدرت کلیک (+{click_power}) - قیمت: {click_power * 10}")
    auto_click_btn.config(text=f"کلیک خودکار سطح {auto_click_level} - قیمت: {(auto_click_level + 1) * 50}")

def click():
    global coins
    coins += click_power
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
    root.after(1000, auto_click_loop)  # هر ثانیه یک بار اجرا شود

def save_game():
    state = {
        "coins": coins,
        "click_power": click_power,
        "auto_click_level": auto_click_level
    }
    with open("clicker_save.json", "w") as f:
        json.dump(state, f)

def load_game():
    global coins, click_power, auto_click_level
    if os.path.exists("clicker_save.json"):
        with open("clicker_save.json", "r") as f:
            state = json.load(f)
            coins = state.get("coins", 0)
            click_power = state.get("click_power", 1)
            auto_click_level = state.get("auto_click_level", 0)
            update_labels()


root = tk.Tk()
root.title("🎮profesional clicker game")
root.geometry("400x400")

coin_label = tk.Label(root, text="🪙 coin: 0", font=("Arial", 16))
coin_label.pack(pady=10)

click_button = tk.Button(root, text="click here!", font=("Arial", 20), width=20, command=click)
click_button.pack(pady=20)

click_upgrade_btn = tk.Button(root, text="", command=upgrade_click)
click_upgrade_btn.pack(pady=10)

auto_click_btn = tk.Button(root, text="", command=upgrade_auto_click)
auto_click_btn.pack(pady=10)


tk.Button(root, text="save game", command=save_game).pack(side="left", padx=20, pady=20)
tk.Button(root, text="load game", command=load_game).pack(side="right", padx=20, pady=20)


load_game()
update_labels()
auto_click_loop()
root.mainloop()
