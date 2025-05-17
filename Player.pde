// ==== Player.pde ====
class Player {
  PVector pos, vel;
  float angle;
  boolean upPressed, downPressed, leftPressed, rightPressed;
  float scaleFactor;
  int bombCount; // Current number of bombs
  int bombRegenTimer; // Timer for bomb regeneration

  Player(float scale) {
    pos = new PVector(width / 2, height / 2);
    vel = new PVector();
    upPressed = false;
    downPressed = false;
    leftPressed = false;
    rightPressed = false;
    scaleFactor = scale;
    bombCount = 3; // Start with max bombs
    bombRegenTimer = 0;
  }

  void update() {
    PVector input = new PVector();
    if (upPressed) input.y -= 1;
    if (downPressed) input.y += 1;
    if (leftPressed) input.x -= 1;
    if (rightPressed) input.x += 1;
    
    input.normalize();
    input.mult(4.5);
    vel = input;
    pos.add(vel);

    float minX = 20 * scaleFactor;
    float maxX = width - 25 * scaleFactor;
    float minY = 15 * scaleFactor;
    float maxY = height - 15 * scaleFactor;
    pos.x = constrain(pos.x, minX, maxX);
    pos.y = constrain(pos.y, minY, maxY);

    angle = atan2(mouseY - pos.y, mouseX - pos.x);

    // Regenerate bombs every 30 seconds (1800 frames)
    bombRegenTimer++;
    if (bombRegenTimer >= 1800 && bombCount < 3) {
      bombCount++;
      bombRegenTimer = 0;
    }
  }

  void draw() {
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(angle);
    
    // Glow layer
    fill(0, 255, 255, 50);
    noStroke();
    triangle(-25 * scaleFactor, -20 * scaleFactor, -25 * scaleFactor, 20 * scaleFactor, 30 * scaleFactor, 0);
    
    // Main shape
    fill(0, 255, 255);
    stroke(255, 255, 255, 150);
    strokeWeight(3 * pixelDensity);
    triangle(-20 * scaleFactor, -15 * scaleFactor, -20 * scaleFactor, 15 * scaleFactor, 25 * scaleFactor, 0);
    
    // Neon pink thruster trails
    stroke(255, 0, 255, 200);
    strokeWeight(5 * pixelDensity);
    line(-15 * scaleFactor, -15 * scaleFactor, -30 * scaleFactor, -22 * scaleFactor);
    line(-15 * scaleFactor, 15 * scaleFactor, -30 * scaleFactor, 22 * scaleFactor);
    
    // Glowing core
    fill(255, 255, 255, 200);
    noStroke();
    ellipse(10 * scaleFactor, 0, 10 * scaleFactor, 10 * scaleFactor);
    fill(255, 255, 255, 50);
    ellipse(10 * scaleFactor, 0, 15 * scaleFactor, 15 * scaleFactor);
    
    popMatrix();
  }

  void stop() {
    vel = new PVector(0, 0);
  }

  void deployBlackHole() {
    if (bombCount > 0 && !gameOver) {
      blackHoles.add(new BlackHole(pos.copy(), scaleFactor));
      bombCount--;
    }
  }
}
