import tkinter as tk

# تابع برای افزایش تعداد کلیک
def click():
    global count
    count += 1
    label.config(text=f"تعداد کلیک: {count}")

# تابع ریست
def reset():
    global count
    count = 0
    label.config(text="تعداد کلیک: 0")

# شروع برنامه
root = tk.Tk()
root.title("بازی کلیکر ساده")
root.geometry("300x200")

count = 0

# لیبل
label = tk.Label(root, text="تعداد کلیک: 0", font=("Arial", 16))
label.pack(pady=20)

# دکمه کلیک
click_button = tk.Button(root, text="کلیک کن!", font=("Arial", 14), command=click)
click_button.pack(pady=10)

# دکمه ریست
reset_button = tk.Button(root, text="ریست", command=reset)
reset_button.pack()

# اجرای برنامه
root.mainloop()
