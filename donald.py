import tkinter as tk

class Company:
    def __init__(self, name, base_income):
        self.name = name
        self.level = 1
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
        # ایجاد 10 شرکت با درآمد پایه متفاوت
        for i in range(10):
            self.companies.append(Company(f"شرکت {i+1}", base_income=10*(i+1)))

    def setup_ui(self):
        self.money_label = tk.Label(self.root, text=f"💰 پول: {self.money}", font=("Arial", 16))
        self.money_label.pack(pady=10)

        self.company_frames = []
        for company in self.companies:
            frame = tk.Frame(self.root)
            frame.pack(pady=5, fill="x", padx=20)

            name_label = tk.Label(frame, text=company.name, width=15)
            name_label.pack(side="left")

            income_label = tk.Label(frame, text=f"درآمد: {company.income}")
            income_label.pack(side="left", padx=10)

            level_label = tk.Label(frame, text=f"سطح: {company.level}")
            level_label.pack(side="left", padx=10)

            upgrade_btn = tk.Button(frame, text="ارتقا (هزینه 100)", command=lambda c=company: self.upgrade_company(c))
            upgrade_btn.pack(side="right")

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
        self.root.after(1000, self.update_money)  # هر ثانیه درآمد جمع میشه

if __name__ == "__main__":
    root = tk.Tk()
    root.title("بازی سرمایه گذاری کپیتالیسم")
    root.geometry("400x400")
    game = CapitalismGame(root)
    root.mainloop()
