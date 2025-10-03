import random
import turtle

# تنظیم صفحه
wn = turtle.Screen()
wn.title("Guess the Number Game")
wn.bgcolor("lightblue")

# قلم برای نمایش متن
pen = turtle.Turtle()
pen.hideturtle()
pen.penup()
pen.goto(0, 100)

def display_message(message):
    pen.clear()
    pen.write(message, align="center", font=("Arial", 18, "bold"))

def get_guess():
    while True:
        try:
            guess = wn.numinput("Your Guess", "Enter a number between 1 and 20:", minval=1, maxval=20)
            if guess is None:  # اگر کاربر Cancel زد
                continue
            return int(guess)
        except (ValueError, TypeError):
            display_message("Please enter a valid number!")

def play_game():
    display_message("Hello! Guess a number between 1 and 20.")
    computer_number = random.randint(1, 20)
    count = 0
    guessed = False

    while not guessed:
        guess = get_guess()
        count += 1
        if guess < computer_number:
            display_message("My number is higher!")
        elif guess > computer_number:
            display_message("My number is lower!")
        else:
            display_message(f"You win! Guessed in {count} tries.")
            guessed = True

    play_again = wn.textinput("Play Again?", "Do you want to play again? (Y/N)").strip().upper()
    if play_again in ["Y", "YES", "BALE"]:
        play_game()
    else:
        display_message("Thanks for playing!")
        wn.bye()

play_game()
