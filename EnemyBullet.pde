// ==== EnemyBullet.pde ====
class EnemyBullet {
  PVector pos, vel;
  PVector[] trail = new PVector[5]; // Trail for glow
  float scaleFactor = min(width / pixelDensity, height / pixelDensity) / 1200.0;
  boolean isHoming;

  // Constructor for non-homing bullets (used by ShootingEnemy)
  EnemyBullet(PVector p, float angle) {
    this(p, angle, false); // Delegate to main constructor
  }

  // Constructor for homing/non-homing bullets (used by CustomEnemy)
  EnemyBullet(PVector p, float angle, boolean isHoming) {
    pos = p.copy();
    vel = PVector.fromAngle(angle).mult(10 * scaleFactor);
    this.isHoming = isHoming;
    for (int i = 0; i < trail.length; i++) {
      trail[i] = pos.copy();
    }
  }

  void update() {
    if (isHoming) {
      PVector target = myPlayer.pos;
      PVector desired = PVector.sub(target, pos).normalize().mult(10 * scaleFactor);
      vel.lerp(desired, 0.05); // Smoothly adjust toward player
      vel.limit(10 * scaleFactor);
    }
    pos.add(vel);
    for (int i = trail.length - 1; i > 0; i--) {
      trail[i] = trail[i-1].copy();
    }
    trail[0] = pos.copy();
  }

  void draw() {
    // Glowing trail
    for (int i = 0; i < trail.length; i++) {
      fill(isHoming ? color(255, 105, 180) : color(255, 0, 128), 100 - i * 20);
      noStroke();
      ellipse(trail[i].x, trail[i].y, (8 - i * 1) * scaleFactor, (8 - i * 1) * scaleFactor);
    }
    
    // Main bullet
    fill(isHoming ? color(255, 105, 180) : color(255, 0, 255));
    noStroke();
    ellipse(pos.x, pos.y, 10 * scaleFactor, 10 * scaleFactor);
    fill(isHoming ? color(255, 105, 180, 50) : color(255, 0, 255, 50));
    ellipse(pos.x, pos.y, 15 * scaleFactor, 15 * scaleFactor);
  }

  boolean offscreen() {
    return pos.x < 0 || pos.x > width || pos.y < 0 || pos.y > height;
  }
}
