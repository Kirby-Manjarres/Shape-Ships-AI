// ==== BlackHole.pde ====
// Note: destroyRadius removed; enemies destroyed within pullRadius
class BlackHole {
  PVector pos;
  float scaleFactor;
  int timer; // Frames until expiration
  float pullRadius; // Radius for pulling and destroying enemies
  float destroyFlash; // Flash intensity for visual feedback

  BlackHole(PVector p, float scale) {
    pos = p.copy();
    scaleFactor = scale;
    timer = 300; // 5 seconds at 60 FPS
    pullRadius = 100 * scaleFactor;
    destroyFlash = 0; // Flash starts at 0
  }

  void update() {
    timer--;
    if (destroyFlash > 0) destroyFlash *= 0.9; // Fade flash effect
  }

  void draw() {
    pushMatrix();
    translate(pos.x, pos.y);
    float scale = 1 + 0.15 * sin(frameCount * 0.15); // Stronger pulse
    
    // Glow layer
    fill(255, 255, 255, 30);
    noStroke();
    ellipse(0, 0, 60 * scaleFactor * scale, 60 * scaleFactor * scale);
    
    // Core
    fill(80, 0, 200); // Brighter purple
    noStroke();
    ellipse(0, 0, 40 * scaleFactor * scale, 40 * scaleFactor * scale);
    
    // Neon cyan swirls
    stroke(0, 255, 255, 200 + destroyFlash * 55);
    strokeWeight(4 * scaleFactor * pixelDensity);
    for (int i = 0; i < 12; i++) {
      float angle = i * PI / 6 + frameCount * 0.12;
      float r1 = 12 * scaleFactor;
      float r2 = 35 * scaleFactor * scale;
      line(r1 * cos(angle), r1 * sin(angle), r2 * cos(angle + 0.6), r2 * sin(angle + 0.6));
    }
    
    // Outer glow ring
    stroke(255, 255, 255, 150 + destroyFlash * 100);
    strokeWeight(3 * scaleFactor * pixelDensity);
    noFill();
    ellipse(0, 0, pullRadius * 2, pullRadius * 2);
    
    popMatrix();
  }

  boolean isExpired() {
    return timer <= 0;
  }

  // Called when an enemy is destroyed
  void triggerFlash() {
    destroyFlash = 1.0; // Trigger bright flash
  }
}
