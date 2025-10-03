import random


EMOJI_DICT = {
    "love": "❤️",
    "pizza": "🍕",
    "coffee": "☕",
    "sleep": "💤",
    "book": "📚",
    "happy": "😊",
    "sad": "😢",
    "cat": "🐱",
    "dog": "🐶",
    "sun": "☀️",
    "moon": "🌙",
    "star": "⭐",
    "fire": "🔥",
    "water": "💧",
    "earth": "🌍",
    "air": "💨",
    "tree": "🌳",
    "flower": "🌸",
    "heart": "💖",
    "music": "🎵",
    "dance": "💃",
    "party": "🥳",
    "car": "🚗",
    "bus": "🚌",
    "train": "🚆",
    "plane": "✈️",
    "bike": "🚲",
    "computer": "💻",
    "phone": "📱",
    "camera": "📷",
    "game": "🎮",
    "soccer": "⚽",
    "basketball": "🏀",
    "tennis": "🎾",
    "run": "🏃",
    "swim": "🏊",
    "food": "🍔",
    "drink": "🥤",
    "cake": "🍰",
    "icecream": "🍦",
    "chocolate": "🍫",
    "beer": "🍺",
    "wine": "🍷",
    "money": "💰",
    "idea": "💡",
    "work": "💼",
    "school": "🏫",
    "hospital": "🏥",
    "house": "🏠",
    "city": "🏙️",
    "beach": "🏖️",
    "mountain": "⛰️",
    "rain": "🌧️",
    "snow": "❄️",
    "thunder": "⚡",
    "rainbow": "🌈",
    "baby": "👶",
    "boy": "👦",
    "girl": "👧",
    "man": "👨",
    "woman": "👩",
    "family": "👨‍👩‍👧‍👦",
    "friend": "🧑‍🤝‍🧑",
    "doctor": "👨‍⚕️",
    "teacher": "👩‍🏫",
    "student": "👨‍🎓",
    "police": "👮",
    "artist": "🎨",
    "writer": "✍️",
    "coder": "👨‍💻",
    "robot": "🤖",
    "alien": "👽",
    "ghost": "👻",
    "dragon": "🐉",
    "unicorn": "🦄",
    "king": "🤴",
    "queen": "👸"
}


TEXT_DICT = {v: k for k, v in EMOJI_DICT.items()}


def text_to_emoji(text: str) -> str:
    """تبدیل متن به ایموجی در صورت وجود"""
    words = text.lower().split()
    result = []
    for w in words:
        if w in EMOJI_DICT:
            result.append(EMOJI_DICT[w])
        else:
            result.append(w)
    return " ".join(result)


def emoji_to_text(text: str) -> str:
    """Translate text to emoji"""
    result = []
    for ch in text:
        if ch in TEXT_DICT:
            result.append(TEXT_DICT[ch])
        else:
            result.append(ch)
    return " ".join(result)


if __name__ == "__main__":
    print("Emoji Translator 😎")
    print("for example: I love pizza →", text_to_emoji("I love pizza"))
    print("for example: ❤️🍕 →", emoji_to_text("❤️🍕"))

    while True:
        mode = input("mode (1=text→emoji, 2=emoji→text, q=quit): ")
        if mode == "q":
            break
        elif mode == "1":
            txt = input("Enter text: ")
            print("→", text_to_emoji(txt))
        elif mode == "2":
            emo = input("Enter emojis: ")
            print("→", emoji_to_text(emo))
        else:
            print("invalid option")
