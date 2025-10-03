import tkinter as tk


cookies = 0
cps = 0   # cookies per second

def click_cookie():
    global cookies
    cookies += 1
    label.config(text=f"Cookies: {cookies}")

def buy_cursor():
    global cookies, cps
    if cookies >= 10:
        cookies -= 10
        cps += 1
        label.config(text=f"Cookies: {cookies}")
        cps_label.config(text=f"CPS: {cps}")

def auto_produce():
    global cookies
    cookies += cps
    label.config(text=f"Cookies: {cookies}")
    root.after(1000, auto_produce)

root = tk.Tk()
root.title("Mini Cookie Clicker")

label = tk.Label(root, text="Cookies: 0", font=("Arial", 16))
label.pack()

cps_label = tk.Label(root, text="CPS: 0", font=("Arial", 12))
cps_label.pack()

btn_click = tk.Button(root, text="🍪 Click", command=click_cookie)
btn_click.pack()

btn_buy = tk.Button(root, text="buy Cursor (10 🍪)", command=buy_cursor)
btn_buy.pack()

auto_produce()
root.mainloop()
