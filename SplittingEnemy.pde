// ==== SplittingEnemy.pde ====
class SplittingEnemy extends Enemy {
  float pulsePhase;
  float scaleFactor = min(width / pixelDensity, height / pixelDensity) / 1200.0;
  boolean isSmall;
  float size;

  SplittingEnemy() {
    super();
    pulsePhase = random(TWO_PI);
    isSmall = false;
    size = 40;
  }

  SplittingEnemy(PVector pos, PVector vel, boolean isSmall) {
    this.pos = pos;
    this.vel = vel;
    pulsePhase = random(TWO_PI);
    this.isSmall = isSmall;
    size = isSmall ? 20 : 40;
  }

  void update(PVector target) {
    super.update(target); // Apply black hole check
    if (enemies.contains(this)) { // Only update if not removed
      vel = PVector.sub(target, pos).normalize().mult(2.5 * scaleFactor); // Chase player
      pos.add(vel);
    }
  }

  void draw() {
    pushMatrix();
    translate(pos.x, pos.y);
    float scale = 1 + 0.15 * sin(frameCount * 0.12 + pulsePhase);
    scale(scale * scaleFactor);
    
    // Glow layer
    fill(0, 255, 0, 50);
    noStroke();
    rectMode(CENTER);
    rect(0, 0, size * 1.2, size * 0.6);
    
    // Main shape
    fill(0, 128, 255);
    stroke(255, 255, 255, 150);
    strokeWeight(3 * scaleFactor * pixelDensity);
    rect(0, 0, size, size * 0.5);
    
    // Inner detail
    fill(0, 255, 0, 200);
    noStroke();
    rect(0, 0, size * 0.6, size * 0.3);
    
    popMatrix();
  }
}
