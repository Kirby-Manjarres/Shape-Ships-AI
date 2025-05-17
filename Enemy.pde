// ==== Enemy.pde ====
// Note: Destroys enemies within black hole's pullRadius, no destroyRadius
abstract class Enemy {
  PVector pos, vel;

  Enemy() {
    float edge = random(4);
    if (edge < 1) pos = new PVector(0, random(height));
    else if (edge < 2) pos = new PVector(width, random(height));
    else if (edge < 3) pos = new PVector(random(width), 0);
    else pos = new PVector(random(width), height);
    vel = new PVector();
  }

  void update(PVector target) {
    // Check for black hole contact
    for (BlackHole bh : blackHoles) {
      float dist = PVector.dist(pos, bh.pos);
      if (dist < bh.pullRadius) {
        // Destroy enemy on contact
        println("Destroying enemy: " + this.getClass().getSimpleName() + " at distance: " + dist); // Debug
        if (this instanceof ChasingEnemy) score += 10;
        else if (this instanceof ShootingEnemy) score += 50;
        else if (this instanceof SplittingEnemy) score += 15;
        else if (this instanceof WanderingEnemy) score += 2;
        enemies.remove(this);
        bh.triggerFlash(); // Trigger visual flash
        return; // Exit to avoid further updates
      }
    }
    // Normal movement (handled by subclasses)
  }

  abstract void draw();
}
