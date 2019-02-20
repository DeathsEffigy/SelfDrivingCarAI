int humanCounter = 0;

class DNA {
  ArrayList<Human> humans = new ArrayList<Human>();
  ArrayList<GenotypeAxon> genotypeAxons = new ArrayList<GenotypeAxon>();
  
  int generation;
  ArrayList<Species> species = new ArrayList<Species>();
  float bestFitness = 0;
  Brain bestBrain;
  
  DNA(int populationSize) {
    generation = 0;
    
    for (int i = 0; i < populationSize; i++) {
      humans.add(new Human(i));
      humans.get(i).brain.phenotypegenesis();
      humans.get(i).brain.neuroplasticity(genotypeAxons);
    }
  }
  
  int findHuman(int id) {
    for (int i = 0; i < humans.size(); i++) {
      if (humans.get(i).no == id) {
        return i;
      }
    }
    
    return -1;
  }
  
  void frame() {
    boolean done = true;
    for (int i = 0; i < humans.size(); i++) {
      if (!humans.get(i).car.dead) {
        done = false;
        humans.get(i).frame();
      }
    }
    
    if (done) {
      naturalSelection();
    }
  }
  
  void naturalSelection() {
    // do all the prep
    findSpecies();
    calculateFitness();
    sortSpecies();
    cullSpecies();
    setBestHumanOverall();
    killStaleSpecies();
    killBadSpecies();
    
    // finally breed offspring
    float average = getAvgFitnessSum();
    ArrayList<Human> offspring = new ArrayList<Human>();
    for (int i = 0; i < species.size(); i++) {
      offspring.add(species.get(i).bestHuman.clone());
      int offspringCount = floor(species.get(i).averageFitness / average * humans.size()) - 1;
      for (int n = 0; n < offspringCount; n++) {
        offspring.add(species.get(i).mate(genotypeAxons));
      }
    }
    
    // make sure to fill humans
    while (offspring.size() < humans.size()) {
      offspring.add(species.get(0).mate(genotypeAxons));
    }
    
    humans.clear();
    humans = (ArrayList) offspring.clone();
    generation += 1;
  }
  
  void findSpecies() {
    // clear out humans in species
    for (Species s : species) {
      s.specimen.clear();
    }
    
    // loop through humans and assign species
    for (int i = 0; i < humans.size(); i++) {
      boolean speciesIdentified = false;
      // match each known species
      for (Species s : species) {
        if (s.matchSpeciesAgainst(humans.get(i).brain)) {
          speciesIdentified = true;
          s.addToSpecies(humans.get(i));
        }
      }
      
      if (!speciesIdentified) {
        species.add(new Species(humans.get(i)));
      }
    }
  }
  
  void calculateFitness() {
    for (int i = 0; i < humans.size(); i++) {
      humans.get(i).calculateFitness();
    }
  }
  
  void sortSpecies() {
    for (Species s : species) {
      s.sortSpecies();
    }
    
    ArrayList<Species> ladder = new ArrayList<Species>();
    for (int i = 0; i < species.size(); i++) {
      float maxScore = 0;
      int maxN = 0;
      for (int n = 0; n < species.size(); n++) {
        if (species.get(n).bestFitness > maxScore) {
          maxScore = species.get(n).bestFitness;
          maxN = n;
        }
      }
      ladder.add(species.get(maxN));
      species.remove(maxN);
      i--;
    }
    
    species = (ArrayList) ladder.clone();
  }
  
  void cullSpecies() {
    for (Species s : species) {
      s.cull();
      s.shareFitness();
      s.setAverage();
    }
  }
  
  void setBestHumanOverall() {
    if (species.get(0).specimen.get(0).fitness > bestFitness) {
      bestFitness = species.get(0).specimen.get(0).fitness;
      bestBrain = species.get(0).specimen.get(0).brain.clone();
    }
  }
  
  void killStaleSpecies() {
    for (int i = 2; i < species.size(); i++) {
      if (species.get(i).staleEvolutions > 15) {
        species.remove(i);
        i--;
      }
    }
  }
  
  void killBadSpecies() {
    float average = getAvgFitnessSum();
    
    for (int i = 0; i < species.size(); i++) {
      if (species.get(i).averageFitness / average * humans.size() < 1) {
        species.remove(i);
        i--;
      }
    }
  }
  
  float getAvgFitnessSum() {
    float averageFitness = 0;
    for (Species s : species) {
      averageFitness += s.averageFitness;
    }
    return averageFitness;
  }
  
  void massExtinction() {
    for (int i = 0; i < humans.size(); i++) {
      humans.get(i).car.die();
    }
  }
}
