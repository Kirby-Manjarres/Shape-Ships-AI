// ==== ShootingEnemy.pde ====
class ShootingEnemy extends Enemy {
  float pulsePhase;
  int shootTimer;
  float scaleFactor = min(width / pixelDensity, height / pixelDensity) / 1200.0;

  ShootingEnemy() {
    super();
    pulsePhase = random(TWO_PI);
    shootTimer = 0;
  }

  void update(PVector target) {
    super.update(target); // Apply black hole check
    if (enemies.contains(this)) { // Only update if not removed
      vel = PVector.sub(target, pos).normalize().mult(2.8 * scaleFactor);
      pos.add(vel);
      
      shootTimer++;
      if (shootTimer >= 120) {
        float angle = atan2(target.y - pos.y, target.x - pos.x);
        enemyBullets.add(new EnemyBullet(pos.copy(), angle));
        shootTimer = 0;
      }
    }
  }

  void draw() {
    pushMatrix();
    translate(pos.x, pos.y);
    float scale = 1 + 0.15 * sin(frameCount * 0.12 + pulsePhase);
    scale(scale * scaleFactor);
    
    // Glow layer
    fill(255, 255, 255, 50);
    noStroke();
    beginShape();
    vertex(0, -25);
    vertex(-25, 25);
    vertex(25, 25);
    endShape(CLOSE);
    
    // Main shape
    fill(255, 0, 255);
    stroke(255, 255, 255, 150);
    strokeWeight(3 * scaleFactor * pixelDensity);
    beginShape();
    vertex(0, -20);
    vertex(-20, 20);
    vertex(20, 20);
    endShape(CLOSE);
    
    // Inner detail
    fill(255, 255, 255, 200);
    noStroke();
    beginShape();
    vertex(0, -12);
    vertex(-12, 12);
    vertex(12, 12);
    endShape(CLOSE);
    
    popMatrix();
  }
}
