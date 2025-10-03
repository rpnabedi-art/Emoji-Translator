import tkinter as tk
import random

def roll_dice():
    dice_number = random.randint(1, 6)
    label.config(text=f"عدد تاس: {dice_number}")

root = tk.Tk()
root.title("بازی تاس ساده")

label = tk.Label(root, text="عدد تاس: ", font=("Helvetica", 24))
label.pack(pady=20)

roll_button = tk.Button(root, text="تاس بنداز!", command=roll_dice)
roll_button.pack(pady=10)

root.mainloop()
