// ==== WanderingEnemy.pde ====
class WanderingEnemy extends Enemy {
  float pulsePhase;
  int directionChangeTimer;
  float scaleFactor = min(width / pixelDensity, height / pixelDensity) / 1200.0;

  WanderingEnemy() {
    super();
    pulsePhase = random(TWO_PI);
    directionChangeTimer = 0;
    vel = PVector.fromAngle(random(TWO_PI)).mult(2 * scaleFactor);
  }

  void update(PVector target) {
    super.update(target); // Apply black hole check
    if (enemies.contains(this)) { // Only update if not removed
      directionChangeTimer++;
      if (directionChangeTimer >= 120) {
        vel = PVector.fromAngle(random(TWO_PI)).mult(2 * scaleFactor);
        directionChangeTimer = 0;
      }
      pos.add(vel);
      if (pos.x < 0) pos.x += width;
      if (pos.x > width) pos.x -= width;
      if (pos.y < 0) pos.y += height;
      if (pos.y > height) pos.y -= height;
    }
  }

  void draw() {
    pushMatrix();
    translate(pos.x, pos.y);
    float scale = 1 + 0.15 * sin(frameCount * 0.12 + pulsePhase);
    scale(scale * scaleFactor);
    
    // Glow layer
    fill(0, 255, 255, 50);
    noStroke();
    beginShape();
    vertex(-20, -12);
    vertex(20, -12);
    vertex(12, 12);
    vertex(-12, 12);
    endShape(CLOSE);
    
    // Main shape
    fill(128, 0, 255);
    stroke(255, 255, 255, 150);
    strokeWeight(3 * scaleFactor * pixelDensity);
    beginShape();
    vertex(-15, -9);
    vertex(15, -9);
    vertex(9, 9);
    vertex(-9, 9);
    endShape(CLOSE);
    
    // Inner detail
    fill(0, 255, 255, 200);
    noStroke();
    beginShape();
    vertex(-9, -6);
    vertex(9, -6);
    vertex(6, 6);
    vertex(-6, 6);
    endShape(CLOSE);
    
    popMatrix();
  }
}
