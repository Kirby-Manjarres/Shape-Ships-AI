// ==== Bullet.pde ====
class Bullet {
  PVector pos, vel;
  PVector[] trail = new PVector[8]; // Longer trail
  float angle;

  Bullet(PVector p, float a) {
    pos = p.copy();
    vel = PVector.fromAngle(a).mult(15);
    angle = a;
    for (int i = 0; i < trail.length; i++) {
      trail[i] = pos.copy();
    }
  }

  void update() {
    pos.add(vel);
    for (int i = trail.length - 1; i > 0; i--) {
      trail[i] = trail[i-1].copy();
    }
    trail[0] = pos.copy();
  }

  void draw() {
    // Glowing trail
    for (int i = 0; i < trail.length; i++) {
      fill(0, 255, 0, 200 - i * 25);
      noStroke();
      ellipse(trail[i].x, trail[i].y, (5 - i * 0.5) * scaleFactor * pixelDensity, (5 - i * 0.5) * scaleFactor * pixelDensity);
    }
    
    // Main bullet
    fill(0, 255, 0);
    noStroke();
    ellipse(pos.x, pos.y, 6 * scaleFactor * pixelDensity, 6 * scaleFactor * pixelDensity);
    fill(0, 255, 0, 50);
    ellipse(pos.x, pos.y, 10 * scaleFactor * pixelDensity, 10 * scaleFactor * pixelDensity);
  }

  boolean offscreen() {
    return pos.x < 0 || pos.x > width || pos.y < 0 || pos.y > height;
  }
}
