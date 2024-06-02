import pygame
import random

colors = [
    (0, 0, 0),  # black
    (120, 37, 179),  # purple
    (100, 179, 179),  # teal
    (80, 34, 22),  # brown
    (80, 134, 22),  # green
    (180, 34, 22),  # red
    (180, 34, 122),  # mauve
]

# LABELS
# 00 01 02 03
# 04 05 06 07
# 08 09 10 11
# 12 13 14 15


class Figure:
    x = 0
    y = 0

    extetetrominoes = [
        [[0, 5, 10, 15], [3, 6, 9, 12]],
        [[4, 9, 14, 11], [13, 10, 7, 2], [11, 6, 1, 4], [2, 5, 8, 13]],
        [[12, 13, 10, 7], [15, 11, 6, 1], [3, 2, 5, 8], [0, 4, 9, 14]],
        [[12, 9, 10, 7], [15, 10, 6, 1], [3, 6, 5, 8], [0, 5, 9, 14]],
        [[8, 9, 14, 11], [14, 10, 7, 2], [7, 6, 1, 4], [1, 5, 8, 13]],
        [[8, 13, 10, 15], [14, 11, 6, 3], [7, 2, 5, 0], [1, 4, 9, 12]],
        [[8, 13, 14, 11], [14, 11, 7, 2], [7, 2, 1, 4], [1, 4, 8, 13]],
        [[8, 9, 14, 15], [14, 10, 7, 3], [7, 6, 1, 0], [1, 5, 8, 12]],
        [[0, 5, 6, 10], [12, 9, 5, 6], [15, 10, 9, 5], [3, 6, 10, 9]],
        [[1, 4, 6, 9], [1, 4, 6, 9], [1, 4, 6, 9], [1, 4, 6, 9]],
        [[0, 2, 5, 9], [0, 8, 5, 6], [8, 10, 5, 1], [2, 10, 5, 4]],
        [[5, 14, 10, 11], [9, 7, 6, 2], [10, 1, 5, 4], [6, 8, 9, 13]],
        [[4, 5, 10, 14], [13, 9, 6, 7], [11, 10, 5, 1], [2, 6, 9, 8]],
        [[4, 8, 13, 10], [9, 10, 7, 2], [11, 7, 2, 5], [2, 1, 4, 9]],
        [[5, 13, 10, 7], [9, 11, 6, 1], [10, 2, 5, 8], [6, 4, 9, 14]],
        [[9, 14, 15, 11], [10, 7, 3, 2], [6, 1, 0, 4], [5, 8, 12, 13]],
        [[8, 13, 14, 15], [14, 11, 7, 3], [7, 2, 1, 0], [1, 4, 8, 12]],
    ]

    tetrominoes = [
        [[1, 5, 9, 13], [4, 5, 6, 7]],
        [[4, 5, 9, 10], [2, 6, 5, 9]],
        [[6, 7, 9, 10], [1, 5, 6, 10]],
        [[1, 2, 5, 9], [0, 4, 5, 6], [1, 5, 9, 8], [4, 5, 6, 10]],
        [[1, 2, 6, 10], [5, 6, 7, 9], [2, 6, 10, 11], [3, 5, 6, 7]],
        [[1, 4, 5, 6], [1, 4, 5, 9], [4, 5, 6, 9], [1, 5, 6, 9]],
        [[1, 2, 5, 6]],
    ]

    def __init__(self, x, y, choice="all", prob=0.5, color="random"):
        self.x = x
        self.y = y
        self.prob = prob  # used for "all" case
        self.choice = choice
        if self.choice == "all":
            self.figures = self.tetrominoes + self.extetetrominoes
        elif self.choice == "extetetrominoes":
            self.figures = self.extetetrominoes
        else:
            self.figures = self.tetrominoes

        if self.choice == "all":
            if random.random() > self.prob:
                self.type = random.randint(0, len(self.tetrominoes) - 1)
            else:
                self.type = random.randint(
                    len(self.tetrominoes), len(self.extetetrominoes) - 1
                )
        else:
            self.type = random.randint(0, len(self.figures) - 1)

        if color == "random":
            self.color = random.randint(1, len(colors) - 1)
        elif color == "black":
            self.color = 0
        elif color == "purple":
            self.color = 1
        elif color == "teal":
            self.color = 2
        elif color == "brown":
            self.color = 3
        elif color == "green":
            self.color = 4
        elif color == "red":
            self.color = 5
        elif color == "mauve":
            self.color = 6

        self.rotation = 0

    def image(self):
        return self.figures[self.type][self.rotation]

    def rotate(self):
        self.rotation = (self.rotation + 1) % len(self.figures[self.type])


class Tetris:
    def __init__(
        self,
        height=20,
        width=10,
        baselevel=2,
        levelup=1,
        choice="all",
        prob=10,
        color="random",
    ):
        self.score = 0
        self.state = "start"
        self.field = []
        self.figure = None
        self.x = 100
        self.y = 60
        self.zoom = 20

        self.height = height
        self.width = width
        self.baselevel = baselevel
        self.level = baselevel
        self.levelup = levelup
        self.choice = choice
        self.prob = prob / 100
        self.color = color

        for i in range(height):
            new_line = []
            for j in range(width):
                new_line.append(0)
            self.field.append(new_line)

    def new_figure(self):
        self.figure = Figure(
            random.randint(0, self.width - 4), 0, self.choice, self.prob, self.color
        )

    def intersects(self):
        intersection = False
        for i in range(4):
            for j in range(4):
                if i * 4 + j in self.figure.image():
                    if (
                        i + self.figure.y > self.height - 1
                        or j + self.figure.x > self.width - 1
                        or j + self.figure.x < 0
                        or self.field[i + self.figure.y][j + self.figure.x] > 0
                    ):
                        intersection = True
        return intersection

    def break_lines(self):
        lines = 0
        for i in range(1, self.height):
            zeros = 0
            for j in range(self.width):
                if self.field[i][j] == 0:
                    zeros += 1
            if zeros == 0:
                lines += 1
                for i1 in range(i, 1, -1):
                    for j in range(self.width):
                        self.field[i1][j] = self.field[i1 - 1][j]
        self.score += lines**2
        self.level = self.score / self.levelup + self.baselevel

    def go_space(self):
        while not self.intersects():
            self.figure.y += 1
        self.figure.y -= 1
        self.freeze()

    def go_down(self):
        self.figure.y += 1
        if self.intersects():
            self.figure.y -= 1
            self.freeze()

    def freeze(self):
        for i in range(4):
            for j in range(4):
                if i * 4 + j in self.figure.image():
                    self.field[i + self.figure.y][j + self.figure.x] = self.figure.color
        self.break_lines()
        self.new_figure()
        if self.intersects():
            self.state = "gameover"

    def go_side(self, dx):
        old_x = self.figure.x
        self.figure.x += dx
        if self.intersects():
            self.figure.x = old_x

    def rotate(self):
        old_rotation = self.figure.rotation
        self.figure.rotate()
        if self.intersects():
            self.figure.rotation = old_rotation

    def run(self):
        # Initialize the game engine
        pygame.init()

        # # Define some colors
        BLACK = (0, 0, 0)
        WHITE = (255, 255, 255)
        GRAY = (128, 128, 128)

        size = (
            self.x + self.zoom * self.width + self.x,
            self.x + self.zoom * self.height + self.y,
        )
        screen = pygame.display.set_mode(size)

        pygame.display.set_caption("Tetris")

        # Loop until the user clicks the close button.
        done = False
        clock = pygame.time.Clock()
        fps = 25
        counter = 0

        pressing_down = False

        while not done:
            if self.figure is None:
                self.new_figure()
            counter += 1
            if counter > 100000:
                counter = 0

            if counter % (fps // self.level // 2) == 0 or pressing_down:
                if self.state == "start":
                    self.go_down()

            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    done = True
                if event.type == pygame.KEYDOWN:
                    if event.key == pygame.K_UP:
                        self.rotate()
                    if event.key == pygame.K_DOWN:
                        pressing_down = True
                    if event.key == pygame.K_LEFT:
                        self.go_side(-1)
                    if event.key == pygame.K_RIGHT:
                        self.go_side(1)
                    if event.key == pygame.K_SPACE:
                        self.go_space()
                    if event.key == pygame.K_ESCAPE:
                        self.__init__(self.height, self.width)

            if event.type == pygame.KEYUP:
                if event.key == pygame.K_DOWN:
                    pressing_down = False

            screen.fill(WHITE)

            for i in range(self.height):
                for j in range(self.width):
                    pygame.draw.rect(
                        screen,
                        GRAY,
                        [
                            self.x + self.zoom * j,
                            self.y + self.zoom * i,
                            self.zoom,
                            self.zoom,
                        ],
                        1,
                    )
                    if self.field[i][j] > 0:
                        pygame.draw.rect(
                            screen,
                            colors[self.field[i][j]],
                            [
                                self.x + self.zoom * j + 1,
                                self.y + self.zoom * i + 1,
                                self.zoom - 2,
                                self.zoom - 1,
                            ],
                        )

            if self.figure is not None:
                for i in range(4):
                    for j in range(4):
                        p = i * 4 + j
                        if p in self.figure.image():
                            pygame.draw.rect(
                                screen,
                                colors[self.figure.color],
                                [
                                    self.x + self.zoom * (j + self.figure.x) + 1,
                                    self.y + self.zoom * (i + self.figure.y) + 1,
                                    self.zoom - 2,
                                    self.zoom - 2,
                                ],
                            )

            font = pygame.font.SysFont("Calibri", 25, True, False)
            font1 = pygame.font.SysFont("Calibri", 65, True, False)
            text = font.render("Score: " + str(self.score), True, BLACK)
            text_game_over = font1.render("Game Over", True, (255, 125, 0))
            text_game_over1 = font1.render("Press ESC", True, (255, 215, 0))

            screen.blit(text, [0, 0])
            if self.state == "gameover":
                screen.blit(text_game_over, [20, 200])
                screen.blit(text_game_over1, [25, 265])

            pygame.display.flip()
            clock.tick(fps)

        pygame.quit()


# game = Tetris(20, 10, choice="extetetrominoes", baselevel=1)
# game.run()
