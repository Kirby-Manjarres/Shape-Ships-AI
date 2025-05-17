// ==== CustomEnemyFactory.pde ====
class CustomEnemy extends Enemy {
  String shape;
  color bodyColor, glowColor;
  float speed;
  String[] attributes;
  float scaleFactor = min(width / pixelDensity, height / pixelDensity) / 1200.0;
  float pulsePhase;
  float teleportTimer, shootTimer, mineTimer, shieldTimer, erraticTimer;
  int health;
  boolean isShielded;
  PVector spawnPos; // For boomerang
  float boomerangPhase; // 0 to 1 (approach to return)

  CustomEnemy(String shape, color bodyColor, color glowColor, float speed, String[] attributes) {
    super();
    this.shape = shape;
    this.bodyColor = bodyColor;
    this.glowColor = glowColor;
    this.speed = speed;
    this.attributes = attributes;
    pulsePhase = random(TWO_PI);
    teleportTimer = 0;
    shootTimer = 0;
    mineTimer = 0;
    shieldTimer = 0;
    erraticTimer = 0;
    health = 2; // Takes 2 hits
    isShielded = false;
    spawnPos = pos.copy(); // Store initial position
    boomerangPhase = 0;
  }

  void update(PVector target) {
    super.update(target); // Apply black hole check
    if (enemies.contains(this)) { // Only update if not removed
      // Handle timers
      teleportTimer += 1.0 / 60.0;
      shootTimer += 1.0 / 60.0;
      mineTimer += 1.0 / 60.0;
      shieldTimer += 1.0 / 60.0;
      erraticTimer += 1.0 / 60.0;
      boomerangPhase += 0.005; // Complete cycle in ~3.3s
      if (boomerangPhase > 1) boomerangPhase -= 1;

      // Shielding
      if (hasAttribute("shielding")) {
        if (shieldTimer < 3.0) {
          isShielded = true; // Shielded for 3s
        } else if (shieldTimer >= 10.0) {
          isShielded = false;
          shieldTimer = 0; // Reset cycle
        }
      }

      // Movement
      boolean hasMovement = false;
      for (String attr : attributes) {
        if (attr.equals("chasing")) {
          vel = PVector.sub(target, pos).normalize().mult(speed);
          hasMovement = true;
        } else if (attr.equals("fleeing")) {
          vel = PVector.sub(pos, target).normalize().mult(speed);
          hasMovement = true;
        } else if (attr.equals("orbiting")) {
          PVector toTarget = PVector.sub(target, pos);
          float dist = toTarget.mag();
          float targetDist = 150 * scaleFactor; // Orbit radius
          PVector tangent = toTarget.copy().rotate(HALF_PI).normalize().mult(speed);
          if (dist > targetDist) {
            vel = toTarget.normalize().mult(speed * 0.5).add(tangent);
          } else {
            vel = tangent;
          }
          hasMovement = true;
        } else if (attr.equals("erratic") && erraticTimer >= 0.5) {
          vel = PVector.random2D().mult(speed);
          erraticTimer = 0;
          hasMovement = true;
        } else if (attr.equals("boomerang")) {
          float t = boomerangPhase < 0.5 ? boomerangPhase * 2 : (1 - (boomerangPhase - 0.5) * 2);
          PVector targetPos = PVector.lerp(spawnPos, target, t);
          vel = PVector.sub(targetPos, pos).normalize().mult(speed);
          hasMovement = true;
        }
      }
      if (!hasMovement) vel = PVector.random2D().mult(speed); // Wander
      pos.add(vel);

      // Teleporting
      if (hasAttribute("teleporting") && teleportTimer >= 2.0) {
        PVector newPos;
        int attempts = 0;
        do {
          newPos = PVector.random2D().mult(random(100, 200) * scaleFactor).add(pos);
          newPos.x = constrain(newPos.x, 0, width);
          newPos.y = constrain(newPos.y, 0, height);
          attempts++;
        } while (PVector.dist(newPos, target) < 100 * scaleFactor && attempts < 10);
        pos.set(newPos);
        teleportTimer = 0;
      }

      // Shooting
      if (hasAttribute("shooting") && shootTimer >= 2.0) {
        float angle = atan2(target.y - pos.y, target.x - pos.x);
        enemyBullets.add(new EnemyBullet(pos.copy(), angle, hasAttribute("homing")));
        shootTimer = 0;
      }

      // Mine-Dropping
      if (hasAttribute("mine-dropping") && mineTimer >= 3.0) {
        enemies.add(new MineEnemy(pos.copy()));
        mineTimer = 0;
      }
    }
  }

  void draw() {
    pushMatrix();
    translate(pos.x, pos.y);
    float scale = 1 + 0.15 * sin(frameCount * 0.12 + pulsePhase);
    scale(scale * scaleFactor);
    
    // Shield glow
    if (isShielded) {
      fill(255, 255, 255, 100);
      noStroke();
      drawShape(shape, 40);
    }
    
    // Glow layer
    fill(glowColor, 50);
    noStroke();
    drawShape(shape, 35);
    
    // Main shape
    fill(isShielded ? color(255, 255, 255) : bodyColor);
    stroke(255, 255, 255, 150);
    strokeWeight(3 * scaleFactor * pixelDensity);
    drawShape(shape, 30);
    
    // Inner detail
    fill(glowColor, 200);
    noStroke();
    drawShape(shape, 15);
    
    popMatrix();
  }

  boolean hasAttribute(String attr) {
    for (String a : attributes) {
      if (a.equals(attr)) return true;
    }
    return false;
  }

  void drawShape(String shapeType, float radius) {
    beginShape();
    if (shapeType.equals("pentagon")) {
      for (int i = 0; i < 5; i++) {
        float angle = i * TWO_PI / 5 - HALF_PI;
        vertex(radius * cos(angle), radius * sin(angle));
      }
    } else if (shapeType.equals("octagon")) {
      for (int i = 0; i < 8; i++) {
        float angle = i * TWO_PI / 8 - HALF_PI;
        vertex(radius * cos(angle), radius * sin(angle));
      }
    } else if (shapeType.equals("star")) {
      for (int i = 0; i < 10; i++) {
        float r = (i % 2 == 0) ? radius : radius * 0.5;
        float angle = i * TWO_PI / 10 - HALF_PI;
        vertex(r * cos(angle), r * sin(angle));
      }
    } else if (shapeType.equals("heptagon")) {
      for (int i = 0; i < 7; i++) {
        float angle = i * TWO_PI / 7 - HALF_PI;
        vertex(radius * cos(angle), radius * sin(angle));
      }
    } else if (shapeType.equals("cross")) {
      float r = radius * 0.7;
      vertex(0, -radius); vertex(r, -r); vertex(radius, 0);
      vertex(r, r); vertex(0, radius); vertex(-r, r);
      vertex(-radius, 0); vertex(-r, -r);
    } else if (shapeType.equals("triangle")) {
      for (int i = 0; i < 3; i++) {
        float angle = i * TWO_PI / 3 - HALF_PI;
        vertex(radius * cos(angle), radius * sin(angle));
      }
    }
    endShape(CLOSE);
  }
}

class MineEnemy extends Enemy {
  float scaleFactor = min(width / pixelDensity, height / pixelDensity) / 1200.0;

  MineEnemy(PVector pos) {
    super();
    this.pos = pos;
    vel = new PVector(0, 0); // Stationary
  }

  void update(PVector target) {
    super.update(target); // Apply black hole check
  }

  void draw() {
    pushMatrix();
    translate(pos.x, pos.y);
    float scale = 1 + 0.1 * sin(frameCount * 0.15);
    scale(scale * scaleFactor);
    
    // Glow
    fill(255, 0, 0, 50);
    noStroke();
    ellipse(0, 0, 20, 20);
    
    // Main
    fill(255, 0, 0);
    stroke(255, 255, 255, 150);
    strokeWeight(2 * scaleFactor * pixelDensity);
    ellipse(0, 0, 15, 15);
    
    popMatrix();
  }
}

class CustomEnemyFactory {
  String[] shapes = {"pentagon", "octagon", "star", "heptagon", "cross", "triangle"};
  color[] bodyColors = {color(255, 0, 255), color(0, 255, 0), color(255, 165, 0), color(0, 191, 255), color(148, 0, 211)}; // Magenta, lime, orange, blue, purple
  color[] glowColors = {color(0, 255, 255), color(255, 255, 0), color(255, 255, 255), color(50, 205, 50), color(255, 20, 147)}; // Cyan, yellow, white, green, pink
  float[] speeds = {2.0, 3.0, 4.0}; // Slow, medium, fast
  String[] attributes = {"chasing", "shooting", "teleporting", "mine-dropping", "fleeing", "exploding", "homing", "shielding", "orbiting", "erratic", "boomerang"};

  CustomEnemy generateEnemy(float skillLevel) { // skillLevel: 0.0 (beginner) to 1.0 (expert)
    String shape = shapes[int(random(shapes.length))];
    color bodyColor = bodyColors[int(random(bodyColors.length))];
    color glowColor = glowColors[int(random(glowColors.length))];
    float speed = speeds[int(map(skillLevel, 0, 1, 0, speeds.length - 1))]; // Faster for skilled players
    
    // Select 1-2 attributes based on skill
    int numAttributes = skillLevel > 0.75 ? 2 : 1;
    String[] selectedAttributes = new String[numAttributes];
    for (int i = 0; i < numAttributes; i++) {
      String attr;
      do {
        attr = attributes[int(random(attributes.length))];
        // Limit powerful combos
        if (i == 1 && (attr.equals("homing") || attr.equals("shielding")) && 
            (selectedAttributes[0].equals("homing") || selectedAttributes[0].equals("shielding"))) {
          continue;
        }
      } while (contains(selectedAttributes, attr));
      selectedAttributes[i] = attr;
    }
    
    return new CustomEnemy(shape, bodyColor, glowColor, speed * min(width / pixelDensity, height / pixelDensity) / 1200.0, selectedAttributes);
  }

  boolean contains(String[] array, String value) {
    if (array == null) return false;
    for (String s : array) {
      if (s != null && s.equals(value)) return true;
    }
    return false;
  }
}
