const std = @import("std");
const rl = @import("raylib");

const windowWidth = 1280;
const windowHeight = 720;
const targetFPS = 35;

// Score
var playerScore: usize = 0;
var cpuScore: usize = 0;
const fontSize = 60;
const fontWidth = fontSize / 2;
const scoreY = fontSize / 2;
const middle = (windowWidth / 2);
const playerX = middle * 0.8;
const cpuX = middle * 1.2 - fontWidth;
const paddingTop = fontSize + (fontSize / 2);

// Paddles
const paddleHeight = 80;
const paddleWidth = paddleHeight / 5;
const paddleStartY: i16 = (windowHeight / 2) - (paddleHeight / 2);
const playerPaddleX = paddleWidth;
const cpuPaddleX = windowWidth - (2 * paddleWidth);
var playerPaddleY = paddleStartY;
var cpuPaddleY = paddleStartY;

// ball
const ballSize = 16;
var ballX: i16 = 3 * paddleWidth;
const ballStartY = (windowHeight / 2) - (ballSize / 2);
var ballY: i16 = ballStartY;
const ballBaseSpeed = 4;
var ballDX: i8 = ballBaseSpeed;
var ballDY: i8 = -ballBaseSpeed;

pub fn main() anyerror!void {
	rl.initWindow(windowWidth, windowHeight, "zig sandbox");
	defer rl.closeWindow();

	rl.setTargetFPS(targetFPS);

	while(!rl.windowShouldClose()) {
		update();
		draw();
	}
}

fn update() void {
	updateBall();
	updatePlayerPaddle();
	updateCpuPaddle();
}

fn updateBall() void {
	ballX += ballDX;
	ballY += ballDY;

	if (ballY <= paddingTop) ballDY = -ballDY;
	if ((ballY + ballSize) >= windowHeight) ballDY = -ballDY;

	// player paddle hit
	if (ballDX < 0
		and ballX <= paddleWidth * 2
		and ((ballY+ballSize) >= playerPaddleY and ballY < (playerPaddleY+paddleHeight))) {
		ballDX = (-ballDX)+1;
		ballDY += if (ballDY < 0) -1 else 1;
		return;
	}

	//cpu paddle hit
	if (ballDX > 0
		and (ballX+ballSize) >= (windowWidth-(paddleWidth*2))
		and ((ballY+ballSize) >= cpuPaddleY and ballY < (cpuPaddleY+paddleHeight))) {
		ballDX = (-ballDX)-1;
		ballDY += if (ballDY < 0) -1 else 1;
		return;
	}

	// cpu score
	if (ballX <= 0) {
		cpuScore += 1;
		playerServe();
		return;
	}

	// player score
	if ((ballX + ballSize) > windowWidth) {
		playerScore += 1;
		cpuServe();
	}
}

fn playerServe() void {
		ballX = 3 * paddleWidth;
		ballY = ballStartY;
		ballDX = ballBaseSpeed;
		ballDY = -ballBaseSpeed;
}

fn cpuServe() void {
		ballX = windowWidth - (3 * paddleWidth);
		ballY = ballStartY;
		ballDX = -ballBaseSpeed;
		ballDY = -ballBaseSpeed;
}

fn updatePlayerPaddle() void {
	if (rl.isKeyDown(.up)) {
		playerPaddleY -= ballBaseSpeed * 2;
		if (playerPaddleY < paddingTop) {
			playerPaddleY = paddingTop;
		}
	}
	if (rl.isKeyDown(.down)) {
		playerPaddleY += ballBaseSpeed * 2;
		if (playerPaddleY + paddleHeight > windowHeight) {
			playerPaddleY = windowHeight - paddleHeight;
		}
	}
}

fn updateCpuPaddle() void {
	const ballCenterY = ballY + (ballSize / 2);

	if (ballCenterY < cpuPaddleY) {
		cpuPaddleY -= (ballBaseSpeed * 2);
		return;
	}
	if (ballCenterY > cpuPaddleY + paddleHeight) {
		cpuPaddleY += (ballBaseSpeed * 2);
	}
}

fn draw() void {
	rl.beginDrawing();
	defer rl.endDrawing();

	clear();
	drawDivider();
	drawScore();
	drawPaddles();
	drawBall();
}

fn clear() void {
	rl.clearBackground(rl.Color.black);
}

fn drawDivider() void {
	const x = windowWidth / 2;
	const height = windowHeight;
	const width = 10;
	const hashCount = 30;
	const hashHeight = height / hashCount;
	var hashNum: i32 = 0;

	while (hashNum < hashCount) : (hashNum += 1) {
		if (@rem(hashNum, 2) == 0) {
			const hashY = hashNum * hashHeight;
			rl.drawRectangle(x, hashY, width, hashHeight, rl.Color.white);
		}
	}
}

fn drawScore() void {
	rl.drawText(rl.textFormat("%01i", .{playerScore}), playerX, scoreY, fontSize, rl.Color.white);
	rl.drawText(rl.textFormat("%01i", .{cpuScore}), cpuX, scoreY, fontSize, rl.Color.white);
}

fn drawPaddles() void {
	rl.drawRectangle(playerPaddleX, playerPaddleY, paddleWidth, paddleHeight, rl.Color.white);
	rl.drawRectangle(cpuPaddleX, cpuPaddleY, paddleWidth, paddleHeight, rl.Color.white);
}

fn drawBall() void {
	rl.drawRectangle(ballX, ballY, ballSize, ballSize, rl.Color.white);
}