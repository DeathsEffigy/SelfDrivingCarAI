class Human {
  int id;
  int no;
  
  Vehicle car;
  int[] colour = new int[3];
  float colourAlpha = 70.0;
  
  Brain brain;
  float[] sensations;
  float[] percepts = new float[4];
  int framesBetweenSenses;
  int framesCount;
  
  // suicide switch for stuck players
  int framesBetweenLastDist = 0;
  int framesBetweenLastDistMax = 35;
  
  float fitness;
  
  Human(int _id) {
    humanCounter++;
    no = humanCounter;
    framesBetweenSenses = 2;
    framesCount = 0;
    id = _id;
    colour[0] = int(random(10, 245));
    colour[1] = int(random(10, 245));
    colour[2] = int(random(10, 245));
    car = new Vehicle(track.offX, track.offY, track.offRotation, colour, colourAlpha);
    sensations = new float[(car.headlightsByAngle.length * 2) + 1];
    brain = new Brain(sensations.length, percepts.length);
    fitness = 0;
  }
  
  void frame() {
    if (!car.dead) {
      if (framesCount >= framesBetweenSenses) {
        sense();
        framesCount = 0;
      }
      framesCount++;
      car.frame();
    }
  }
  
  void sense() {
    sensations[0] = 0;
    
    for (int i = 0; i < car.headlightsByAngle.length; i++) {
      sensations[(i*2)] = car.headlightReflections[i].x / width;
      sensations[(i*2)+1] = car.headlightReflections[i].y / height;
    }
    sensations[sensations.length - 1] = car.acceleration / car.accelerationMax;
    
    think();
  }
  
  void think() {
    /*
    percepts.struct{
      1 -> arrowLeft()
      2 -> arrowRight()
      3 -> arrowUp()
      4 -> arrowDown()
    }
    */
    percepts = brain.perceive(sensations);
    
    // evaluate
    float maxP = -2;
    int maxI = -1;
    
    for (int i = 0; i < percepts.length; i++) {
      if (percepts[i] > maxP) {
        maxP = percepts[i];
        maxI = i + 1;
      }
    }
    
    car.action(maxI);
    
    if (maxI != 3) {
      framesBetweenLastDist++;
      if (framesBetweenLastDist >= framesBetweenLastDistMax) {
        car.die();
      }
    } else {
      framesBetweenLastDist = 0;
    }
  }
  
  void calculateFitness() {
    // fitness = (pow(car.distance, 2) / 10) / (car.wheelUses + 1) * car.gasUses; // pretty ok
    fitness = (pow(car.distance * car.gasUses, 2) / 10) / (car.wheelUses + 1);
  }
  
  Human clone() {
    Human clone = new Human(no);
    clone.colour = colour;
    clone.brain = brain.clone();
    clone.fitness = fitness;
    return clone;
  }
  
  Human crossbreed(Human P2) {
    Human offspring = new Human(dna.humans.size());
    offspring.brain = brain.crossbreed(P2.brain);
    return offspring;
  }
}
