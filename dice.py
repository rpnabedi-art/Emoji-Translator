import tkinter as tk
from tkinter import messagebox
import random
import os

class DiceRollerApp:
    def __init__(self, master):
        self.master = master
        master.title("بازی تاس (Dice Roller)")

        self.label = tk.Label(master, text="عدد تاس: ", font=("Arial", 24))
        self.label.pack(pady=20)

        self.roll_button = tk.Button(master, text="تاس بنداز!", command=self.roll_dice, font=("Arial", 18))
        self.roll_button.pack(pady=10)

        self.history_button = tk.Button(master, text="نمایش تاریخچه", command=self.show_history)
        self.history_button.pack(pady=5)

        self.history_file = "dice_history.txt"

    def roll_dice(self):
        try:
            roll = random.randint(1, 6)
            self.label.config(text=f"عدد تاس: {roll}")
            self.save_roll(roll)
        except Exception as e:
            messagebox.showerror("خطا", f"خطایی رخ داد: {e}")

    def save_roll(self, roll):
        try:
            with open(self.history_file, "a", encoding="utf-8") as f:
                f.write(f"{roll}\n")
        except Exception as e:
            messagebox.showerror("خطا", f"ذخیره تاریخچه ممکن نیست: {e}")

    def show_history(self):
        if not os.path.exists(self.history_file):
            messagebox.showinfo("تاریخچه", "هیچ تاسی انداخته نشده.")
            return
        try:
            with open(self.history_file, "r", encoding="utf-8") as f:
                history = f.read().strip()
            if history:
                messagebox.showinfo("تاریخچه تاس‌ها", history)
            else:
                messagebox.showinfo("تاریخچه", "هیچ تاسی انداخته نشده.")
        except Exception as e:
            messagebox.showerror("خطا", f"خواندن تاریخچه ممکن نیست: {e}")

if __name__ == "__main__":
    root = tk.Tk()
    app = DiceRollerApp(root)
    root.mainloop()
