import random

def welcome():
    print("Hello!")
    print("You have to guess a number between 1 and 20.\n")

def finish(number, count):
    print("Good game!")
    print(f"You guessed {number} in {count} guesses.\n")
    do_you_want_to_play_again = input("Do you want to play again? (Y/N): ")
    if do_you_want_to_play_again.upper() in ["YES", "Y", "BALE", "ARE"]:
        return True
    else:
        return False

def win(computer_number, guess):
    return computer_number == guess

def answer(computer, user):
    if computer > user:
        return "My number is higher."
    elif computer < user:
        return "My number is lower."
    else:
        return "You win!"

def get_a_guess():
    while True:
        try:
            ans = int(input("What is your guess? "))
            return ans
        except ValueError:
            print("Please enter a valid integer.")

# شروع بازی
welcome()
continue_playing = True

while continue_playing:
    computer_number = random.randint(1, 20)
    guess = 0
    count = 0
    
    while not win(computer_number, guess):
        guess = get_a_guess()
        count += 1
        print(answer(computer_number, guess))
    
    continue_playing = finish(computer_number, count)
