import tkinter as tk
from tkinter import ttk, messagebox
import json
import os
import time
import random
import pygame
from pygame import mixer
from datetime import datetime
import firebase_admin
from firebase_admin import credentials, db

# Initialize Firebase (remove if not using online save)
try:
    cred = credentials.Certificate("serviceAccountKey.json")
    firebase_admin.initialize_app(cred, {
        'databaseURL': 'https://your-project.firebaseio.com/'
    })
except:
    print("Firebase not configured. Using local saves only.")

# Initialize pygame mixer
mixer.init()

class ClickerGame:
    def __init__(self, root):
        self.root = root
        self.setup_game()
        self.setup_ui()
        self.load_assets()
        self.setup_bindings()
        self.load_game()
        
    def setup_game(self):
        # Game state
        self.coins = 0
        self.click_power = 1
        self.auto_click_level = 0
        self.click_count = 0
        self.start_time = time.time()
        self.play_time = 0
        self.xp = 0
        self.level = 1
        self.prestige = 0
        self.achievements = {}
        self.upgrades = {
            "click_power": {"base_cost": 10, "cost_multiplier": 1.15, "level": 0},
            "auto_click": {"base_cost": 50, "cost_multiplier": 1.2, "level": 0},
            "critical_chance": {"base_cost": 200, "cost_multiplier": 1.25, "level": 0}
        }
        self.stats = {
            "total_clicks": 0,
            "total_coins": 0,
            "highest_click": 0,
            "critical_hits": 0
        }
        
        # Game settings
        self.critical_chance = 0.05
        self.critical_multiplier = 2.0
        self.theme = "dark"
        self.sound_enabled = True
        self.music_enabled = True
        
        # Visual effects
        self.click_animations = []
        self.floating_texts = []
        
    def setup_ui(self):
        # Configure root window
        self.root.title("🎮 بازی کلیکر حرفه‌ای")
        self.root.geometry("800x600")
        self.apply_theme()
        
        # Create main frames
        self.main_frame = ttk.Frame(self.root)
        self.main_frame.pack(fill=tk.BOTH, expand=True)
        
        # Left panel (main game)
        self.left_panel = ttk.Frame(self.main_frame)
        self.left_panel.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        
        # Right panel (stats and upgrades)
        self.right_panel = ttk.Frame(self.main_frame)
        self.right_panel.pack(side=tk.RIGHT, fill=tk.Y, padx=10, pady=10)
        
        # Create UI elements
        self.create_main_ui()
        self.create_stats_ui()
        self.create_upgrades_ui()
        
    def create_main_ui(self):
        # Coin display
        self.coin_label = ttk.Label(
            self.left_panel, 
            text="🪙 سکه: 0", 
            font=("Segoe UI", 24, "bold")
        )
        self.coin_label.pack(pady=20)
        
        # Click button
        self.click_button = ttk.Button(
            self.left_panel,
            text="کلیک کن!",
            style="Accent.TButton",
            command=self.click
        )
        self.click_button.pack(pady=20, ipadx=30, ipady=15)
        
        # XP progress bar
        self.xp_frame = ttk.Frame(self.left_panel)
        self.xp_frame.pack(fill=tk.X, padx=20, pady=10)
        
        self.level_label = ttk.Label(
            self.xp_frame,
            text="سطح 1",
            font=("Segoe UI", 12)
        )
        self.level_label.pack(side=tk.LEFT)
        
        self.xp_bar = ttk.Progressbar(
            self.xp_frame,
            orient=tk.HORIZONTAL,
            length=200,
            mode='determinate'
        )
        self.xp_bar.pack(side=tk.LEFT, expand=True, fill=tk.X, padx=10)
        
        self.xp_label = ttk.Label(
            self.xp_frame,
            text="0/100 XP",
            font=("Segoe UI", 10)
        )
        self.xp_label.pack(side=tk.RIGHT)
        
        # Animation canvas for click effects
        self.animation_canvas = tk.Canvas(
            self.left_panel,
            bg=self.root.cget("bg"),
            height=100,
            highlightthickness=0
        )
        self.animation_canvas.pack(fill=tk.BOTH, expand=True)
    
    def create_stats_ui(self):
        # Stats notebook (tabbed interface)
        self.stats_notebook = ttk.Notebook(self.right_panel)
        self.stats_notebook.pack(fill=tk.BOTH, expand=True)
        
        # Stats tab
        self.stats_tab = ttk.Frame(self.stats_notebook)
        self.stats_notebook.add(self.stats_tab, text="آمار")
        
        # Achievements tab
        self.achievements_tab = ttk.Frame(self.stats_notebook)
        self.stats_notebook.add(self.achievements_tab, text="دستاوردها")
        
        # Settings tab
        self.settings_tab = ttk.Frame(self.stats_notebook)
        self.stats_notebook.add(self.settings_tab, text="تنظیمات")
        
        # Create content for each tab
        self.create_stats_tab()
        self.create_achievements_tab()
        self.create_settings_tab()
    
    def create_stats_tab(self):
        # Stats labels
        stats = [
            ("⏱ زمان بازی:", "play_time"),
            ("🖱 کلیک‌ها:", "click_count"),
            ("💥 ضربات بحرانی:", "stats.critical_hits"),
            ("💰 کل سکه‌ها:", "stats.total_coins"),
            ("🏆 بالاترین کلیک:", "stats.highest_click"),
            ("⭐ سطح:", "level"),
            ("✨ تجربه:", "xp"),
            ("🏆 prestige:", "prestige")
        ]
        
        for i, (label, stat_key) in enumerate(stats):
            frame = ttk.Frame(self.stats_tab)
            frame.pack(fill=tk.X, padx=5, pady=2)
            
            ttk.Label(frame, text=label, width=15).pack(side=tk.LEFT)
            ttk.Label(frame, text="0", width=10, anchor=tk.E).pack(side=tk.RIGHT)
            setattr(self, f"stat_{stat_key.replace('.', '_')}_label", frame.children['!label2'])
    
    def create_achievements_tab(self):
        self.achievements_frame = ttk.Frame(self.achievements_tab)
        self.achievements_frame.pack(fill=tk.BOTH, expand=True)
        
        self.achievement_labels = {}
        
        # Sample achievements
        self.all_achievements = {
            "first_click": {
                "name": "اولین کلیک!",
                "description": "انجام اولین کلیک",
                "target": 1,
                "reward": 100,
                "unlocked": False
            },
            "click_100": {
                "name": "۱۰۰ کلیک",
                "description": "انجام ۱۰۰ کلیک",
                "target": 100,
                "reward": 500,
                "unlocked": False
            },
            # Add more achievements...
        }
        
        for ach_id, ach in self.all_achievements.items():
            frame = ttk.Frame(self.achievements_frame)
            frame.pack(fill=tk.X, padx=5, pady=2)
            
            # Achievement icon (locked/unlocked)
            icon = "🔒" if not ach["unlocked"] else "✅"
            ttk.Label(frame, text=icon, width=3).pack(side=tk.LEFT)
            
            # Achievement info
            info_frame = ttk.Frame(frame)
            info_frame.pack(side=tk.LEFT, fill=tk.X, expand=True)
            
            ttk.Label(info_frame, text=ach["name"], font=("Segoe UI", 10, "bold")).pack(anchor=tk.W)
            ttk.Label(info_frame, text=ach["description"]).pack(anchor=tk.W)
            
            self.achievement_labels[ach_id] = frame
    
    def create_settings_tab(self):
        # Theme switcher
        ttk.Label(self.settings_tab, text="تم:").pack(anchor=tk.W, padx=5, pady=(10,0))
        self.theme_var = tk.StringVar(value=self.theme)
        ttk.Radiobutton(
            self.settings_tab, 
            text="تاریک", 
            variable=self.theme_var, 
            value="dark",
            command=self.change_theme
        ).pack(anchor=tk.W, padx=20)
        ttk.Radiobutton(
            self.settings_tab, 
            text="روشن", 
            variable=self.theme_var, 
            value="light",
            command=self.change_theme
        ).pack(anchor=tk.W, padx=20)
        
        # Sound settings
        ttk.Separator(self.settings_tab).pack(fill=tk.X, pady=10)
        ttk.Label(self.settings_tab, text="صدا:").pack(anchor=tk.W, padx=5)
        
        self.sound_var = tk.BooleanVar(value=self.sound_enabled)
        ttk.Checkbutton(
            self.settings_tab,
            text="فعال کردن صداها",
            variable=self.sound_var,
            command=self.toggle_sound
        ).pack(anchor=tk.W, padx=20)
        
        self.music_var = tk.BooleanVar(value=self.music_enabled)
        ttk.Checkbutton(
            self.settings_tab,
            text="فعال کردن موسیقی",
            variable=self.music_var,
            command=self.toggle_music
        ).pack(anchor=tk.W, padx=20)
        
        # Save buttons
        ttk.Separator(self.settings_tab).pack(fill=tk.X, pady=10)
        ttk.Button(
            self.settings_tab,
            text="ذخیره بازی",
            command=self.save_game
        ).pack(fill=tk.X, padx=20, pady=5)
        
        ttk.Button(
            self.settings_tab,
            text="بارگذاری بازی",
            command=self.load_game
        ).pack(fill=tk.X, padx=20, pady=5)
        
        ttk.Button(
            self.settings_tab,
            text="بازنشانی بازی",
            style="Danger.TButton",
            command=self.reset_game
        ).pack(fill=tk.X, padx=20, pady=5)
    
    def create_upgrades_ui(self):
        self.upgrades_frame = ttk.LabelFrame(
            self.right_panel,
            text="ارتقاها",
            padding=(10, 5)
        )
        self.upgrades_frame.pack(fill=tk.BOTH, pady=10)
        
        # Click power upgrade
        self.click_upgrade_btn = ttk.Button(
            self.upgrades_frame,
            text=f"قدرت کلیک (+1) - قیمت: 10",
            command=lambda: self.buy_upgrade("click_power"),
            style="Upgrade.TButton"
        )
        self.click_upgrade_btn.pack(fill=tk.X, pady=5)
        
        # Auto clicker upgrade
        self.auto_click_btn = ttk.Button(
            self.upgrades_frame,
            text=f"کلیک خودکار سطح 0 - قیمت: 50",
            command=lambda: self.buy_upgrade("auto_click"),
            style="Upgrade.TButton"
        )
        self.auto_click_btn.pack(fill=tk.X, pady=5)
        
        # Critical chance upgrade
        self.critical_btn = ttk.Button(
            self.upgrades_frame,
            text=f"شانس بحرانی 5% - قیمت: 200",
            command=lambda: self.buy_upgrade("critical_chance"),
            style="Upgrade.TButton"
        )
        self.critical_btn.pack(fill=tk.X, pady=5)
    
    def setup_bindings(self):
        # Bind mouse enter/leave events for hover effects
        for btn in [self.click_button, self.click_upgrade_btn, 
                   self.auto_click_btn, self.critical_btn]:
            btn.bind("<Enter>", lambda e: e.widget.config(style="Accent.Hover.TButton"))
            btn.bind("<Leave>", lambda e: e.widget.config(style="Accent.TButton"))
        
        # Bind keyboard shortcuts
        self.root.bind("<space>", lambda e: self.click())
        self.root.bind("<c>", lambda e: self.click())
        
        # Right-click for prestige
        self.click_button.bind("<Button-3>", self.prestige_popup)
    
    def load_assets(self):
        # Load sounds
        try:
            self.click_sound = mixer.Sound("click.wav")
            self.upgrade_sound = mixer.Sound("upgrade.wav")
            self.critical_sound = mixer.Sound("critical.wav")
            self.achievement_sound = mixer.Sound("achievement.wav")
        except:
            print("Sound files not found. Continuing without sound.")
        
        # Start background music
        if self.music_enabled:
            try:
                mixer.music.load("background.mp3")
                mixer.music.play(-1)  # Loop indefinitely
                mixer.music.set_volume(0.3)
            except:
                print("Background music not found.")
    
    def apply_theme(self):
        if self.theme == "dark":
            self.root.tk_setPalette(
                background="#282c34",
                foreground="#abb2bf",
                activeBackground="#3e4451",
                activeForeground="#abb2bf",
                selectColor="#3e4451",
                selectBackground="#528ecc",
                selectForeground="#ffffff"
            )
            
            # Configure styles
            style = ttk.Style()
            style.theme_use('clam')
            
            style.configure('.', background="#282c34", foreground="#abb2bf")
            style.configure('TFrame', background="#282c34")
            style.configure('TLabel', background="#282c34", foreground="#abb2bf")
            style.configure('TButton', 
                          background="#3e4451", 
                          foreground="#abb2bf",
                          bordercolor="#3e4451",
                          lightcolor="#3e4451",
                          darkcolor="#3e4451",
                          padding=5)
            
            style.configure('Accent.TButton', 
                          background="#61afef", 
                          foreground="#282c34",
                          font=("Segoe UI", 12, "bold"),
                          bordercolor="#61afef",
                          lightcolor="#61afef",
                          darkcolor="#61afef")
            
            style.map('Accent.TButton',
                     background=[('active', '#528ecc')])
            
            style.configure('Upgrade.TButton',
                          background="#2c313a",
                          foreground="#abb2bf",
                          bordercolor="#2c313a",
                          lightcolor="#2c313a",
                          darkcolor="#2c313a")
            
            style.configure('Danger.TButton',
                          background="#e06c75",
                          foreground="#282c34",
                          bordercolor="#e06c75",
                          lightcolor="#e06c75",
                          darkcolor="#e06c75")
            
            style.configure('TNotebook', background="#21252b", borderwidth=0)
            style.configure('TNotebook.Tab', 
                          background="#21252b",
                          foreground="#abb2bf",
                          padding=[10, 5],
                          borderwidth=0)
            style.map('TNotebook.Tab',
                     background=[('selected', '#282c34')])
            
            style.configure('TProgressbar',
                          background="#61afef",
                          troughcolor="#3e4451",
                          bordercolor="#3e4451",
                          lightcolor="#61afef",
                          darkcolor="#61afef")
            
            style.configure('TFrame', background="#282c34")
            style.configure('TLabelframe', background="#282c34", foreground="#abb2bf")
            style.configure('TLabelframe.Label', background="#282c34", foreground="#61afef")
            
        else:  # Light theme
            # Similar configuration for light theme...
            pass
    
    def change_theme(self):
        self.theme = self.theme_var.get()
        self.apply_theme()
    
    def toggle_sound(self):
        self.sound_enabled = self.sound_var.get()
    
    def toggle_music(self):
        self.music_enabled = self.music_var.get()
        if self.music_enabled:
            mixer.music.play(-1)
        else:
            mixer.music.stop()
    
    def click(self, event=None):
        # Calculate coins from click
        coins_gained = self.click_power
        
        # Check for critical hit
        is_critical = random.random() < self.critical_chance
        if is_critical:
            coins_gained = int(coins_gained * self.critical_multiplier)
            self.stats["critical_hits"] += 1
            self.show_floating_text(f"CRITICAL! +{coins_gained}", "#e5c07b")
            if self.sound_enabled:
                self.critical_sound.play()
        
        self.coins += coins_gained
        self.click_count += 1
        self.stats["total_clicks"] += 1
        self.stats["total_coins"] += coins_gained
        
        if coins_gained > self.stats["highest_click"]:
            self.stats["highest_click"] = coins_gained
        
        # Add XP
        self.add_xp(1)
        
        # Play sound
        if self.sound_enabled and not is_critical:
            self.click_sound.play()
        
        # Show click effect
        self.show_click_effect()
        
        # Check achievements
        self.check_achievements()
        
        # Update UI
        self.update_labels()
    
    def auto_click(self):
        if self.auto_click_level > 0:
            self.coins += self.auto_click_level
            self.stats["total_coins"] += self.auto_click_level
            self.add_xp(0.1)
            self.update_labels()
        
        self.root.after(1000, self.auto_click)
    
    def buy_upgrade(self, upgrade_type):
        upgrade = self.upgrades[upgrade_type]
        cost = int(upgrade["base_cost"] * (upgrade["cost_multiplier"] ** upgrade["level"]))
        
        if self.coins >= cost:
            self.coins -= cost
            upgrade["level"] += 1
            
            # Apply upgrade effects
            if upgrade_type == "click_power":
                self.click_power += 1
            elif upgrade_type == "auto_click":
                self.auto_click_level += 1
            elif upgrade_type == "critical_chance":
                self.critical_chance = min(0.5, self.critical_chance + 0.01)
            
            # Play sound
            if self.sound_enabled:
                self.upgrade_sound.play()
            
            # Update UI
            self.update_labels()
            self.show_floating_text(f"ارتقا خریداری شد!", "#98c379")
        else:
            self.show_floating_text("سکه کافی نیست!", "#e06c75")
    
    def add_xp(self, amount):
        self.xp += amount
        xp_needed = self.level * 100
        
        if self.xp >= xp_needed:
            self.xp -= xp_needed
            self.level += 1
            self.show_floating_text(f"سطح جدید! {self.level}", "#61afef")
            
            # Reward for leveling up
            reward = self.level * 50
            self.coins += reward
            self.show_floating_text(f"پاداش: +{reward} سکه", "#e5c07b")
            
            if self.sound_enabled:
                self.achievement_sound.play()
        
        self.update_xp_bar()
    
    def update_xp_bar(self):
        xp_needed = self.level * 100
        progress = (self.xp / xp_needed) * 100
        self.xp_bar["value"] = progress
        self.xp_label.config(text=f"{int(self.xp)}/{xp_needed} XP")
        self.level_label.config(text=f"سطح {self.level}")
    
    def check_achievements(self):
        for ach_id, ach in self.all_achievements.items():
            if not ach["unlocked"]:
                target = ach["target"]
                current = 0
                
                if ach_id == "first_click":
                    current = self.click_count
                elif ach_id == "click_100":
                    current = self.click_count
                # Add more achievement conditions...
                
                if current >= target:
                    self.unlock_achievement(ach_id)
    
    def unlock_achievement(self, ach_id):
        ach = self.all_achievements[ach_id]
        ach["unlocked"] = True
        
        # Give reward
        reward = ach["reward"]
        self.coins += reward
        
        # Show notification
        messagebox.showinfo(
            "دستاورد باز شد!",
            f"{ach['name']}\n\n{ach['description']}\n\nپاداش: {reward} سکه"
        )
        
        # Play sound
        if self.sound_enabled:
            self.achievement_sound.play()
        
        # Update UI
        self.update_achievements_ui()
        self.update_labels()
    
    def update_achievements_ui(self):
        for ach_id, ach in self.all_achievements.items():
            frame = self.achievement_labels[ach_id]
            icon = "✅" if ach["unlocked"] else "🔒"
            frame.children['!label'].config(text=icon)
    
    def prestige_popup(self, event=None):
        if self.level < 10:
            messagebox.showwarning(
                "Prestige",
                f"برای Prestige نیاز به سطح 10 دارید!\nسطح فعلی: {self.level}"
            )
            return
        
        result = messagebox.askyesno(
            "Prestige",
            "آیا می‌خواهید Prestige کنید؟\n\n"
            f"• تمام سکه‌ها و ارتقاها از بین می‌روند\n"
            f"• به سطح 1 بازمی‌گردید\n"
            f"• یک امتیاز Prestige دریافت می‌کنید\n\n"
            f"امتیازهای فعلی: {self.prestige}"
        )
        
        if result:
            self.prestige += 1
            self.coins = 0
            self.click_power = 1 + (self.prestige * 0.1)
            self.auto_click_level = 0
            self.click_count = 0
            self.level = 1
            self.xp = 0
            
            # Reset upgrades but keep prestige bonuses
            for upgrade in self.upgrades.values():
                upgrade["level"] = 0
            
            self.critical_chance = 0.05 + (self.prestige * 0.01)
            
            self.show_floating_text(f"Prestige #{self.prestige}!", "#c678dd")
            self.update_labels()
    
    def show_click_effect(self):
        # Create a click animation
        x, y = self.click_button.winfo_rootx() + 50, self.click_button.winfo_rooty() + 30
        x -= self.root.winfo_rootx()
        y -= self.root.winfo_rooty()
        
        text = self.animation_canvas.create_text(
            x, y,
            text=f"+{self.click_power}",
            fill="#61afef",
            font=("Segoe UI", 12, "bold")
        )
        
        self.click_animations.append({
            "id": text,
            "y": y,
            "alpha": 255,
            "time": 0
        })
    
    def show_floating_text(self, text, color):
        x, y = self.click_button.winfo_rootx() + 50, self.click_button.winfo_rooty() + 30
        x -= self.root.winfo_rootx()
        y -= self.root.winfo_rooty()
        
        text_id = self.animation_canvas.create_text(
            x, y,
            text=text,
            fill=color,
            font=("Segoe UI", 14, "bold")
        )
        
        self.floating_texts.append({
            "id": text_id,
            "y": y,
            "alpha": 255,
            "time": 0
        })
    
    def update_animations(self):
        # Update click animations
        for anim in self.click_animations[:]:
            anim["y"] -= 1
            anim["alpha"] -= 5
            anim["time"] += 1
            
            self.animation_canvas.itemconfig(
                anim["id"],
                fill=self._apply_alpha("#61afef", anim["alpha"])
            )
            self.animation_canvas.coords(
                anim["id"],
                self.click_button.winfo_rootx() - self.root.winfo_rootx() + 50,
                anim["y"]
            )
            
            if anim["time"] > 50 or anim["alpha"] <= 0:
                self.animation_canvas.delete(anim["id"])
                self.click_animations.remove(anim)
        
        # Update floating texts
        for text in self.floating_texts[:]:
            text["y"] -= 1
            text["alpha"] -= 3
            text["time"] += 1
            
            color = self.animation_canvas.itemcget(text["id"], "fill")
            self.animation_canvas.itemconfig(
                text["id"],
                fill=self._apply_alpha(color, text["alpha"])
            )
            self.animation_canvas.coords(
                text["id"],
                self.click_button.winfo_rootx() - self.root.winfo_rootx() + 50,
                text["y"]
            )
            
            if text["time"] > 100 or text["alpha"] <= 0:
                self.animation_canvas.delete(text["id"])
                self.floating_texts.remove(text)
        
        self.root.after(16, self.update_animations)
    
    def _apply_alpha(self, color, alpha):
        # Convert hex to RGB
        r, g, b = tuple(int(color.lstrip('#')[i:i+2], 16) for i in (0, 2, 4))
        return f"#{r:02x}{g:02x}{b:02x}"
    
    def update_labels(self):
        # Update coin label
        self.coin_label.config(text=f"🪙 سکه: {self._format_number(self.coins)}")
        
        # Update upgrade buttons
        click_cost = int(self.upgrades["click_power"]["base_cost"] * 
                        (self.upgrades["click_power"]["cost_multiplier"] ** 
                         self.upgrades["click_power"]["level"]))
        self.click_upgrade_btn.config(
            text=f"قدرت کلیک (+1) - قیمت: {self._format_number(click_cost)}"
        )
        
        auto_cost = int(self.upgrades["auto_click"]["base_cost"] * 
                       (self.upgrades["auto_click"]["cost_multiplier"] ** 
                        self.upgrades["auto_click"]["level"]))
        self.auto_click_btn.config(
            text=f"کلیک خودکار سطح {self.auto_click_level} - قیمت: {self._format_number(auto_cost)}"
        )
        
        crit_cost = int(self.upgrades["critical_chance"]["base_cost"] * 
                       (self.upgrades["critical_chance"]["cost_multiplier"] ** 
                        self.upgrades["critical_chance"]["level"]))
        self.critical_btn.config(
            text=f"شانس بحرانی {int(self.critical_chance*100)}% - قیمت: {self._format_number(crit_cost)}"
        )
        
        # Update stats
        self.play_time = int(time.time() - self.start_time)
        hours = self.play_time // 3600
        minutes = (self.play_time % 3600) // 60
        seconds = self.play_time % 60
        time_str = f"{hours:02d}:{minutes:02d}:{seconds:02d}"
        
        self.stat_play_time_label.config(text=time_str)
        self.stat_click_count_label.config(text=self._format_number(self.click_count))
        self.stat_stats_critical_hits_label.config(text=self._format_number(self.stats["critical_hits"]))
        self.stat_stats_total_coins_label.config(text=self._format_number(self.stats["total_coins"]))
        self.stat_stats_highest_click_label.config(text=self._format_number(self.stats["highest_click"]))
        self.stat_level_label.config(text=self.level)
        self.stat_xp_label.config(text=self._format_number(self.xp))
        self.stat_prestige_label.config(text=self.prestige)
    
    def _format_number(self, num):
        if num >= 1_000_000_000:
            return f"{num/1_000_000_000:.1f}B"
        elif num >= 1_000_000:
            return f"{num/1_000_000:.1f}M"
        elif num >= 1_000:
            return f"{num/1_000:.1f}K"
        return str(num)
    
    def save_game(self):
        state = {
            "coins": self.coins,
            "click_power": self.click_power,
            "auto_click_level": self.auto_click_level,
            "click_count": self.click_count,
            "start_time": self.start_time,
            "play_time": self.play_time,
            "xp": self.xp,
            "level": self.level,
            "prestige": self.prestige,
            "achievements": self.all_achievements,
            "upgrades": self.upgrades,
            "stats": self.stats,
            "settings": {
                "theme": self.theme,
                "sound_enabled": self.sound_enabled,
                "music_enabled": self.music_enabled
            }
        }
        
        # Save locally
        with open("clicker_save.json", "w") as f:
            json.dump(state, f)
        
        # Try to save to Firebase
        try:
            ref = db.reference(f'/users/user1')
            ref.set(state)
            self.show_floating_text("بازی ذخیره شد!", "#98c379")
        except:
            self.show_floating_text("ذخیره محلی انجام شد", "#e5c07b")
    
    def load_game(self):
        try:
            # Try to load from Firebase first
            try:
                ref = db.reference('/users/user1')
                state = ref.get()
                
                if not state:
                    raise Exception("No cloud save found")
            except:
                # Fall back to local save
                with open("clicker_save.json", "r") as f:
                    state = json.load(f)
            
            # Apply loaded state
            self.coins = state.get("coins", 0)
            self.click_power = state.get("click_power", 1)
            self.auto_click_level = state.get("auto_click_level", 0)
            self.click_count = state.get("click_count", 0)
            self.start_time = state.get("start_time", time.time())
            self.play_time = state.get("play_time", 0)
            self.xp = state.get("xp", 0)
            self.level = state.get("level", 1)
            self.prestige = state.get("prestige", 0)
            self.all_achievements = state.get("achievements", {})
            self.upgrades = state.get("upgrades", {
                "click_power": {"base_cost": 10, "cost_multiplier": 1.15, "level": 0},
                "auto_click": {"base_cost": 50, "cost_multiplier": 1.2, "level": 0},
                "critical_chance": {"base_cost": 200, "cost_multiplier": 1.25, "level": 0}
            })
            self.stats = state.get("stats", {
                "total_clicks": 0,
                "total_coins": 0,
                "highest_click": 0,
                "critical_hits": 0
            })
            
            # Load settings
            settings = state.get("settings", {})
            self.theme = settings.get("theme", "dark")
            self.sound_enabled = settings.get("sound_enabled", True)
            self.music_enabled = settings.get("music_enabled", True)
            
            # Update UI
            self.theme_var.set(self.theme)
            self.sound_var.set(self.sound_enabled)
            self.music_var.set(self.music_enabled)
            self.apply_theme()
            self.update_labels()
            self.update_achievements_ui()
            self.update_xp_bar()
            
            self.show_floating_text("بازی بارگذاری شد!", "#98c379")
        except FileNotFoundError:
            self.show_floating_text("فایل ذخیره یافت نشد", "#e06c75")
        except Exception as e:
            print(f"Error loading game: {e}")
            self.show_floating_text("خطا در بارگذاری", "#e06c75")
    
    def reset_game(self):
        result = messagebox.askyesno(
            "بازنشانی بازی",
            "آیا مطمئن هستید که می‌خواهید بازی را بازنشانی کنید؟\n\nتمام پیشرفت‌های شما از بین خواهد رفت!"
        )
        
        if result:
            self.setup_game()
            self.update_labels()
            self.update_achievements_ui()
            self.update_xp_bar()
            self.show_floating_text("بازی بازنشانی شد!", "#e06c75")
    
    def run(self):
        self.update_animations()
        self.auto_click()
        self.root.mainloop()

if __name__ == "__main__":
    root = tk.Tk()
    game = ClickerGame(root)
    game.run()
