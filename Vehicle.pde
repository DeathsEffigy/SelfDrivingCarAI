class Vehicle {
  // visuals
  int[] colour = new int[3];
  float colourAlpha;
  int vX = 20;
  int vY = 10;
  
  // location on map
  float x;
  float y;
  float rotation;
  
  // movement
  float acceleration;
  float accelerationMax = 5;
  float accelerationLoss = 0.35;
  float rotationSensitivity = 15;
  float ratioY;
  float ratioX;
  
  // AI controls
  boolean dead;
  int distance;
  int wheelUses;
  int gasUses;
  float[] headlightsByAngle = {0, -45, 45, -90, 90};
  PVector[] headlightReflections;
  
  Vehicle(float offX, float offY, float offRot, int[] c, float alpha) {
    dead = false;
    acceleration = 0;
    x = offX;
    y = offY;
    rotation = offRot;
    colour = c;
    colourAlpha = alpha;
    distance = 0;
    wheelUses = 0;
    gasUses = 0;
    ratioY = 0;
    ratioX = 0;
    headlightReflections = new PVector[headlightsByAngle.length];
  }
  
  void frame() {
    if (!dead) {
      move();
      collisionCheck();
      headlights();
      pushMatrix();
      fill(colour[0], colour[1], colour[2]);
      translate(x, y);
      rotate(radians(rotation));
      rect(0, 0, vX, vY);
      popMatrix();
    }
  }
  
  void headlights() {
    for (int i = 0; i < headlightsByAngle.length; i++) {
      setupHeadlight(i, headlightsByAngle[i]);
    }
  }
  
  void setupHeadlight(int id, float angle) {
    float[] XY = getXYRatiosFromRotation(rotation + angle);
    
    boolean isReflected = false;
    int reflectionX = 0;
    int reflectionY = 0;
    int dist = 1;
    
    do {
      float aX = x + (dist * XY[0]);
      float aY = y + (dist * XY[1]);
      if (!track.checkWhitePixel(int(aX), int(aY))) {
        isReflected = true;
        reflectionX = int(aX);
        reflectionY = int(aY);
      } else {
        dist += 1;
      }
    } while (!isReflected);
    
    stroke(colour[0], colour[1], colour[2]);
    line(x, y, reflectionX, reflectionY);
    noStroke();
    
    headlightReflections[id] = new PVector((dist * XY[0]), (dist * XY[1]));
  }
  
  float[] getXYRatiosFromRotation(float r) {
    float rX = 0;
    float rY = 0;
    float[] ret = new float[2];
    
    // y downwards
    if ((r <= 0 && r >= -180) || (r >= 180 && r <= 360)) {
      if (r >= -90 && r <= 0) {
        rY = r / 90;
      } else if (r <= -90 && r >= -180) {
        rY = (abs(r + 180) * -1) / 90;
      } else if (r >= 270 && r <= 360) {
        rY = (r - 360) / 90;
      } else if (r <= 270 && r >= 180) {
        rY = (r - 180) / 90;
      }
      rY = abs(rY);
    } else if ((r >= 0 && r <= 180) || (r <= -180 && r >= -360)) {
    // y upwards
      if (r >= 0 && r <= 90) {
        rY = r / 90;
      } else if (r <= -270 && r >= -360) {
        rY = (r + 360) / 90;
      } else if (r >= 90 && r <= 180) {
        rY = (r - 180) / 90;
      } else if (r >= -270 && r <= -180) {
        rY = (r + 180) / 90;
      }
      rY = abs(rY) * -1;
    }
    
    // x direction
    if ((r <= -90 && r >= -270) || (r <= 270 && r >= 90)) {
      rX = 1 - abs(rY);
    } else {
      rX = (1 - abs(rY)) * -1;
    }
    
    ret[0] = rX;
    ret[1] = rY;
    return ret;
  }
  
  void move() {
    float[] temp = getXYRatiosFromRotation(rotation);
    ratioX = temp[0];
    ratioY = temp[1];
    
    setAcceleration();
    float movY = acceleration * ratioY;
    float movX = acceleration * ratioX;
    
    x += movX;
    y += movY;
    
    distance += acceleration;
  }
  
  void setAcceleration() {
    acceleration -= accelerationLoss;
    if (acceleration < 0) {
      acceleration = 0;
    }
  }
  
  void collisionCheck() {
    float fX = x - (vX / 2);
    float fY = y - (vY / 2);
    
    for (int i = 0; i < vX; i++) {
      for (int n = 0; n < vY; n++) {
        if (!track.checkWhitePixel(int(fX + i), int(fY + n))) {
          die();
        }
      }
    }
  }
  
  void die() {
    dead = true;
  }
  
  float logisticSigmoid(float x) {
    return (exp(x) / (exp(x) + 1));
  }
  
  void gas() {
    acceleration = logisticSigmoid(pow(acceleration, 2)) * accelerationMax;
  }
  
  void brakes() {
    acceleration = round(sqrt(acceleration));
  }
  
  /* input
    => 1: left key
    => 2: right key
    => 3: up key
    => 4: down key
  */
  void action(int input) {
    if (input == 1 || input == 2) {
      // we can only stir the wheel if we're moving
      if (acceleration == 0) {
        gas();
      }
      if (input == 1) { // left key
        rotation -= rotationSensitivity;
        checkRotation();
        wheelUses++;
      } else if (input == 2) { // right key
        rotation += rotationSensitivity;
        checkRotation();
        wheelUses++;
      }
    } else if (input == 3) { // up arrow
      gas();
      gasUses++;
    } else if (input == 4) { // down arrow
      brakes();
    }
  }
  
  void checkRotation() {
    if (rotation <= -360) {
      rotation += 360;
    } else if (rotation >= 360) {
      rotation -= 360;
    }
  }
}
