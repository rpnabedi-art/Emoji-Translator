import pygame
import random
import sys

# Initialize Pygame
pygame.init()

# Screen settings
WIDTH, HEIGHT = 400, 600
SCREEN = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("Flappy Bird")

# Colors
WHITE = (255, 255, 255)
BLUE = (135, 206, 250)
GREEN = (0, 200, 0)
RED = (255, 0, 0)

# Game variables
GRAVITY = 0.5
FLAP_STRENGTH = -10
PIPE_WIDTH = 70
PIPE_GAP = 150
FPS = 60

# Fonts
FONT = pygame.font.SysFont(None, 40)

# Bird
bird_x = 50
bird_y = HEIGHT // 2
bird_vel = 0
bird_radius = 20

# Pipes
pipes = []
SPAWNPIPE = pygame.USEREVENT
pygame.time.set_timer(SPAWNPIPE, 1500)

# Score
score = 0

def draw_bird(y):
    pygame.draw.circle(SCREEN, RED, (bird_x, int(y)), bird_radius)

def draw_pipes(pipes):
    for pipe in pipes:
        pygame.draw.rect(SCREEN, GREEN, pipe['top'])
        pygame.draw.rect(SCREEN, GREEN, pipe['bottom'])

def display_score(score):
    text = FONT.render(f"Score: {score}", True, WHITE)
    SCREEN.blit(text, (10, 10))

def check_collision(bird_y, pipes):
    if bird_y - bird_radius <= 0 or bird_y + bird_radius >= HEIGHT:
        return True
    for pipe in pipes:
        if pipe['top'].collidepoint(bird_x, bird_y) or pipe['bottom'].collidepoint(bird_x, bird_y):
            return True
    return False

clock = pygame.time.Clock()
running = True

while running:
    SCREEN.fill(BLUE)
    
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            pygame.quit()
            sys.exit()
        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_SPACE:
                bird_vel = FLAP_STRENGTH
        if event.type == SPAWNPIPE:
            height = random.randint(100, HEIGHT - 200)
            top_pipe = pygame.Rect(WIDTH, 0, PIPE_WIDTH, height)
            bottom_pipe = pygame.Rect(WIDTH, height + PIPE_GAP, PIPE_WIDTH, HEIGHT - height - PIPE_GAP)
            pipes.append({'top': top_pipe, 'bottom': bottom_pipe, 'passed': False})
    
    # Bird movement
    bird_vel += GRAVITY
    bird_y += bird_vel
    
    # Move pipes
    for pipe in pipes:
        pipe['top'].x -= 3
        pipe['bottom'].x -= 3
        # Update score
        if not pipe['passed'] and pipe['top'].right < bird_x:
            pipe['passed'] = True
            score += 1
    
    # Remove off-screen pipes
    pipes = [pipe for pipe in pipes if pipe['top'].right > 0]
    
    # Draw everything
    draw_bird(bird_y)
    draw_pipes(pipes)
    display_score(score)
    
    # Check collision
    if check_collision(bird_y, pipes):
        running = False
    
    pygame.display.update()
    clock.tick(FPS)

# Game over
SCREEN.fill(BLUE)
text = FONT.render(f"Game Over! Score: {score}", True, WHITE)
SCREEN.blit(text, (WIDTH//2 - text.get_width()//2, HEIGHT//2))
pygame.display.update()
pygame.time.delay(3000)
pygame.quit()
