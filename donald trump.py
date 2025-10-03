import tkinter as tk

class Company:
    def __init__(self, name, emoji, base_income):
        self.name = name
        self.emoji = emoji
        self.level = 143485000000000
        self.base_income = base_income
        self.income = base_income

    def upgrade(self):
        self.level += 1
        self.income = self.base_income * self.level

class CapitalismGame:
    def __init__(self, root):
        self.root = root
        self.money = 0
        self.companies = []
        self.setup_companies()
        self.setup_ui()
        self.update_money()

    def setup_companies(self):
        # 10 شرکت معروف با ایموجی و درآمد پایه متفاوت
        self.companies = [
            Company("🍎 اپل", "🍎", 10),
            Company("🪟 مایکروسافت", "🪟", 12),
            Company("📦 آمازون", "📦", 15),
            Company("🤖 گوگل", "🤖", 20),
            Company("📱 سامسونگ", "📱", 18),
            Company("🚗 تسلا", "🚗", 25),
            Company("💻 لنوو", "💻", 14),
            Company("🎮 نینتندو", "🎮", 16),
            Company("📺 سونی", "📺", 13),
            Company("☕️ اوراکل", "☕️", 11)
        ]

    def setup_ui(self):
        self.root.configure(bg="#282c34")

        self.money_label = tk.Label(self.root, text=f"💰 پول: {self.money}", font=("Arial", 18, "bold"), fg="white", bg="#282c34")
        self.money_label.pack(pady=15)

        self.company_frames = []
        for company in self.companies:
            frame = tk.Frame(self.root, bg="#3c4048", bd=2, relief="ridge")
            frame.pack(pady=6, padx=20, fill="x")

            emoji_label = tk.Label(frame, text=company.emoji, font=("Arial", 24), bg="#3c4048")
            emoji_label.pack(side="left", padx=10)

            name_label = tk.Label(frame, text=company.name, font=("Arial", 14, "bold"), fg="white", bg="#3c4048", width=15, anchor="w")
            name_label.pack(side="left")

            income_label = tk.Label(frame, text=f"درآمد: {company.income}", font=("Arial", 12), fg="white", bg="#3c4048", width=12)
            income_label.pack(side="left")

            level_label = tk.Label(frame, text=f"سطح: {company.level}", font=("Arial", 12), fg="white", bg="#3c4048", width=8)
            level_label.pack(side="left")

            upgrade_btn = tk.Button(frame, text="ارتقا (هزینه 100)", command=lambda c=company: self.upgrade_company(c), bg="#61afef", fg="black", font=("Arial", 10, "bold"))
            upgrade_btn.pack(side="right", padx=10)

            self.company_frames.append((income_label, level_label))

    def upgrade_company(self, company):
        cost = 100
        if self.money >= cost:
            self.money -= cost
            company.upgrade()
            self.update_ui()

    def update_ui(self):
        self.money_label.config(text=f"💰 پول: {self.money}")
        for i, company in enumerate(self.companies):
            income_label, level_label = self.company_frames[i]
            income_label.config(text=f"درآمد: {company.income}")
            level_label.config(text=f"سطح: {company.level}")

    def update_money(self):
        total_income = sum(company.income for company in self.companies)
        self.money += total_income
        self.update_ui()
        self.root.after(1000, self.update_money)  # هر ثانیه آپدیت میشه

if __name__ == "__main__":
    root = tk.Tk()
    root.title("💼 بازی سرمایه گذاری کپیتالیسم")
    root.geometry("450x550")
    game = CapitalismGame(root)
    root.mainloop()
