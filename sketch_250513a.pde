// ==== GeometryWars.pde ====
Player myPlayer;
ArrayList<Bullet> bullets;
ArrayList<EnemyBullet> enemyBullets;
ArrayList<Enemy> enemies;
ArrayList<BlackHole> blackHoles;
int lives = 3;
int score = 0; // Track player score
boolean gameOver = false;
PVector[] stars = new PVector[100]; // More stars for dynamic background
float shakeAmount = 0;
float scaleFactor;
int pixelDensity; // Store pixel density for scaling
int gameStartFrame; // Track game start for survival time
int difficultyStage; // 1: Wandering, 2: +Chasing, 3: +Splitting, 4: +Shooting, 5: +Custom
int enemiesDestroyed; // Track total enemies destroyed
float lastKillTime; // Time of last kill (in seconds)
CustomEnemyFactory enemyFactory;

void setup() {
  fullScreen(P2D); // Use P2D renderer for high quality
  try {
    pixelDensity = displayDensity();
    println("Raw displayDensity: " + pixelDensity);
    pixelDensity = constrain(pixelDensity, 1, 2);
    println("Clamped pixelDensity: " + pixelDensity);
    pixelDensity(pixelDensity);
  } catch (Exception e) {
    println("pixelDensity error: " + e.getMessage() + ", falling back to 1");
    pixelDensity = 1;
    pixelDensity(1);
  }
  smooth(8); // High-quality anti-aliasing
  frameRate(60);
  scaleFactor = min(width / pixelDensity, height / pixelDensity) / 1200.0; // Adjust for high-DPI
  resetGame();
  for (int i = 0; i < stars.length; i++) {
    stars[i] = new PVector(random(width), random(height));
  }
  enemyFactory = new CustomEnemyFactory();
}

void draw() {
  if (shakeAmount > 0) {
    translate(random(-shakeAmount, shakeAmount), random(-shakeAmount, shakeAmount));
    shakeAmount *= 0.95; // Smoother decay
  }
  
  background(10, 10, 20); // Darker, bluish background for neon contrast
  
  // Neon stars with faint glow
  noStroke();
  for (PVector star : stars) {
    fill(255, 255, 255, 50);
    ellipse(star.x, star.y, 4 * scaleFactor * pixelDensity, 4 * scaleFactor * pixelDensity);
    fill(255, 255, 255, 150);
    ellipse(star.x, star.y, 2 * scaleFactor * pixelDensity, 2 * scaleFactor * pixelDensity);
    star.y += 0.8 * scaleFactor;
    if (star.y > height) star.y -= height;
  }
  
  // Subtle neon cyan grid
  stroke(0, 255, 255, 10);
  strokeWeight(0.5 * scaleFactor * pixelDensity);
  for (int i = 0; i <= width; i += 50 * scaleFactor) {
    line(i, 0, i, height);
    line(0, i, width, i);
  }
  
  if (gameOver) {
    fill(0, 255, 255); // Neon cyan
    stroke(255, 0, 255, 200); // Neon pink outline
    strokeWeight(4 * scaleFactor * pixelDensity);
    textAlign(CENTER, CENTER);
    float pulse = 80 * scaleFactor + 8 * scaleFactor * sin(frameCount * 0.08);
    textSize(pulse * pixelDensity);
    text("GAME OVER", width / 2, height / 2 - 50 * scaleFactor);
    textSize(pulse / 2 * pixelDensity);
    text("Score: " + score, width / 2, height / 2);
    text("Press SPACE to restart", width / 2, height / 2 + 50 * scaleFactor);
    noStroke();
    return;
  }

  // Compute player performance
  float survivalTime = (frameCount - gameStartFrame) / 60.0; // Seconds
  float killRate = enemiesDestroyed / max(survivalTime, 1.0) * 60.0; // Kills per minute
  float skillLevel = constrain((score / 1000.0 + killRate / 20.0 + survivalTime / 240.0) / 3.0, 0, 1); // 0 to 1

  // Decision tree for difficulty
  if (score >= 200 && killRate >= 5 && survivalTime >= 60) {
    difficultyStage = 5; // Expert: Custom enemies
  } else if (score < 50 && survivalTime < 30) {
    difficultyStage = 1; // Beginner: Wandering only
  } else if ((score >= 50 || survivalTime >= 30) && killRate < 5) {
    difficultyStage = min(2 + int(survivalTime / 60), 3); // Intermediate: Wandering, Chasing, maybe Splitting
  } else {
    difficultyStage = 4; // Advanced: All standard enemies
  }

  myPlayer.update();
  myPlayer.draw();

  for (int i = bullets.size() - 1; i >= 0; i--) {
    Bullet b = bullets.get(i);
    b.update();
    b.draw();
    if (b.offscreen()) bullets.remove(i);
  }

  for (int i = enemyBullets.size() - 1; i >= 0; i--) {
    EnemyBullet eb = enemyBullets.get(i);
    eb.update();
    eb.draw();
    if (eb.offscreen()) {
      enemyBullets.remove(i);
    } else if (PVector.dist(eb.pos, myPlayer.pos) < 20 * scaleFactor) {
      enemyBullets.remove(i);
      lives--;
      shakeAmount = 12 * scaleFactor;
      if (lives <= 0) {
        gameOver = true;
      }
    }
  }

  for (int i = blackHoles.size() - 1; i >= 0; i--) {
    BlackHole bh = blackHoles.get(i);
    bh.update();
    bh.draw();
    if (bh.isExpired()) blackHoles.remove(i);
  }

  for (int i = enemies.size() - 1; i >= 0; i--) {
    Enemy e = enemies.get(i);
    e.update(myPlayer.pos);
    e.draw();

    for (int j = bullets.size() - 1; j >= 0; j--) {
      float collisionRadius = (e instanceof WanderingEnemy) ? 20 * scaleFactor : 30 * scaleFactor;
      if (e instanceof CustomEnemy || e instanceof MineEnemy) collisionRadius = 25 * scaleFactor;
      if (PVector.dist(bullets.get(j).pos, e.pos) < collisionRadius) {
        bullets.remove(j);
        if (e instanceof SplittingEnemy && !((SplittingEnemy)e).isSmall) {
          SplittingEnemy se = (SplittingEnemy)e;
          PVector vel = se.vel.copy();
          PVector offset = vel.copy().rotate(HALF_PI).normalize().mult(10 * scaleFactor);
          enemies.add(new SplittingEnemy(se.pos.copy().add(offset), vel, true));
          enemies.add(new SplittingEnemy(se.pos.copy().sub(offset), vel, true));
          enemies.remove(i);
        } else if (e instanceof CustomEnemy && ((CustomEnemy)e).isShielded) {
          // Shielded: No damage
        } else if (e instanceof CustomEnemy && ((CustomEnemy)e).health > 1) {
          ((CustomEnemy)e).health--;
        } else {
          // Award points and track kills
          boolean explode = (e instanceof CustomEnemy) && ((CustomEnemy)e).hasAttribute("exploding");
          if (e instanceof ChasingEnemy) score += 10;
          else if (e instanceof ShootingEnemy) score += 50;
          else if (e instanceof SplittingEnemy) score += 15;
          else if (e instanceof WanderingEnemy) score += 2;
          else if (e instanceof CustomEnemy) score += 25;
          else if (e instanceof MineEnemy) score += 5;
          enemiesDestroyed++;
          lastKillTime = survivalTime;
          enemies.remove(i);
          // Handle explosion
          if (explode && PVector.dist(e.pos, myPlayer.pos) < 50 * scaleFactor) {
            lives--;
            shakeAmount = 12 * scaleFactor;
            if (lives <= 0) gameOver = true;
          }
        }
        break;
      }
    }

    // Mine or enemy collision
    float collisionRadius = (e instanceof WanderingEnemy) ? 40 * scaleFactor : 40 * scaleFactor;
    if (e instanceof CustomEnemy || e instanceof MineEnemy) collisionRadius = 35 * scaleFactor;
    if (PVector.dist(myPlayer.pos, e.pos) < collisionRadius) {
      boolean explode = (e instanceof CustomEnemy) && ((CustomEnemy)e).hasAttribute("exploding");
      enemies.remove(i);
      lives--;
      shakeAmount = 12 * scaleFactor;
      if (e instanceof MineEnemy) lives--; // Mines deal 2 damage
      if (explode && PVector.dist(e.pos, myPlayer.pos) < 50 * scaleFactor) lives--;
      if (lives <= 0) gameOver = true;
    }
  }

  // Dynamic enemy spawning
  int spawnInterval = round(60 - survivalTime * 0.1); // 60 frames at 0s, 30 frames at 300s
  spawnInterval = constrain(spawnInterval, 30, 60);
  if (frameCount % spawnInterval == 0) {
    float r = random(1);
    if (difficultyStage == 1) {
      enemies.add(new WanderingEnemy()); // Only Wandering
    } else if (difficultyStage == 2) {
      if (r < 0.7) enemies.add(new WanderingEnemy());
      else enemies.add(new ChasingEnemy());
    } else if (difficultyStage == 3) {
      if (r < 0.5) enemies.add(new WanderingEnemy());
      else if (r < 0.8) enemies.add(new ChasingEnemy());
      else enemies.add(new SplittingEnemy());
    } else if (difficultyStage == 4) {
      if (r < 0.4) enemies.add(new WanderingEnemy());
      else if (r < 0.7) enemies.add(new ChasingEnemy());
      else if (r < 0.9) enemies.add(new SplittingEnemy());
      else enemies.add(new ShootingEnemy());
    } else if (difficultyStage == 5) {
      float customSpawnThreshold = 0.95 - skillLevel * 0.15; // 5% at skillLevel=0, 20% at skillLevel=1
      if (r < 0.3) enemies.add(new WanderingEnemy());
      else if (r < 0.55) enemies.add(new ChasingEnemy());
      else if (r < 0.8) enemies.add(new SplittingEnemy());
      else if (r < customSpawnThreshold) enemies.add(new ShootingEnemy());
      else enemies.add(enemyFactory.generateEnemy(skillLevel));
    }
  }

  // Neon HUD
  fill(0, 255, 255);
  stroke(255, 0, 255, 150);
  strokeWeight(2 * scaleFactor * pixelDensity);
  textSize(40 * scaleFactor * pixelDensity);
  textAlign(LEFT);
  text("Lives: " + lives, 20 * scaleFactor, 60 * scaleFactor);
  text("Bombs: " + myPlayer.bombCount, 20 * scaleFactor, 100 * scaleFactor);
  text("Score: " + score, 20 * scaleFactor, 140 * scaleFactor);
  text("Stage: " + difficultyStage, 20 * scaleFactor, 180 * scaleFactor); // Debug
  noStroke();
}

void mousePressed() {
  if (!gameOver) {
    if (mouseButton == LEFT) {
      bullets.add(new Bullet(myPlayer.pos, myPlayer.angle));
    } else if (mouseButton == RIGHT) {
      myPlayer.deployBlackHole();
    }
  }
}

void keyPressed() {
  if (gameOver && key == ' ') {
    resetGame();
  }
  if (keyCode == UP) myPlayer.upPressed = true;
  if (keyCode == DOWN) myPlayer.downPressed = true;
  if (keyCode == LEFT) myPlayer.leftPressed = true;
  if (keyCode == RIGHT) myPlayer.rightPressed = true;
}

void keyReleased() {
  if (keyCode == UP) myPlayer.upPressed = false;
  if (keyCode == DOWN) myPlayer.downPressed = false;
  if (keyCode == LEFT) myPlayer.leftPressed = false;
  if (keyCode == RIGHT) myPlayer.rightPressed = false;
  myPlayer.stop();
}

void resetGame() {
  bullets = new ArrayList<Bullet>();
  enemyBullets = new ArrayList<EnemyBullet>();
  enemies = new ArrayList<Enemy>();
  blackHoles = new ArrayList<BlackHole>();
  myPlayer = new Player(scaleFactor);
  lives = 3;
  score = 0; // Reset score
  gameOver = false;
  shakeAmount = 0;
  gameStartFrame = frameCount; // Reset survival time
  difficultyStage = 1; // Start with Wandering only
  enemiesDestroyed = 0; // Reset kill counter
  lastKillTime = 0;
}
