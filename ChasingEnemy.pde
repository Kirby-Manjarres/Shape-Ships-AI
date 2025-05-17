// ==== ChasingEnemy.pde ====
class ChasingEnemy extends Enemy {
  float pulsePhase;
  float scaleFactor = min(width / pixelDensity, height / pixelDensity) / 1200.0;

  ChasingEnemy() {
    super();
    pulsePhase = random(TWO_PI);
  }

  void update(PVector target) {
    super.update(target); // Apply black hole check
    if (enemies.contains(this)) { // Only update if not removed
      vel = PVector.sub(target, pos).normalize().mult(4 * scaleFactor); // Faster chase speed
      pos.add(vel);
    }
  }

  void draw() {
    pushMatrix();
    translate(pos.x, pos.y);
    float scale = 1 + 0.15 * sin(frameCount * 0.12 + pulsePhase); // Stronger pulse
    scale(scale * scaleFactor);
    
    // Glow layer
    fill(255, 255, 0, 50);
    noStroke();
    beginShape();
    for (int i = 0; i < 6; i++) {
      float angle = i * PI / 3;
      vertex(25 * cos(angle), 25 * sin(angle));
    }
    endShape(CLOSE);
    
    // Main shape
    fill(255, 0, 0);
    stroke(255, 255, 255, 150);
    strokeWeight(3 * scaleFactor * pixelDensity);
    beginShape();
    for (int i = 0; i < 6; i++) {
      float angle = i * PI / 3;
      vertex(20 * cos(angle), 20 * sin(angle));
    }
    endShape(CLOSE);
    
    // Inner detail
    fill(255, 255, 0, 200);
    noStroke();
    beginShape();
    for (int i = 0; i < 10; i++) {
      float r = (i % 2 == 0) ? 10 : 5;
      float angle = i * PI / 5;
      vertex(r * cos(angle), r * sin(angle));
    }
    endShape(CLOSE);
    
    popMatrix();
  }
}
