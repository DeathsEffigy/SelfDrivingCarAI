class Species {
  ArrayList<Human> specimen = new ArrayList<Human>();
  float averageFitness = 0;
  int staleEvolutions = 0;
  
  float bestFitness;
  Human bestHuman;
  Brain bestBrain;
  
  float excessCoefficient = 1;
  float excitabilityDiffCoefficient = 0.5;
  float compatibilityThreshold = 3;
  
  Species(Human speciman) {
    specimen.add(speciman);
    bestFitness = speciman.fitness;
    bestHuman = speciman.clone();
    bestBrain = speciman.brain.clone();
  }
  
  boolean matchSpeciesAgainst(Brain contender) {
    float compatibility;
    float excessAndDisjoint = getExcessDisjoint(contender, bestBrain);
    float averageExcitabilityDiff = getAverageExcitabilityDiff(contender, bestBrain);
    
    float largeBrainNormaliser = contender.phenotypeAxons.size() / 20;
    if (largeBrainNormaliser < 1) {
      largeBrainNormaliser = 1;
    }
    
    compatibility = (excessCoefficient * excessAndDisjoint / largeBrainNormaliser) + (excitabilityDiffCoefficient * averageExcitabilityDiff);
    return (compatibility < compatibilityThreshold);
  }
  
  float getExcessDisjoint(Brain brain1, Brain brain2) {
    float matching = 0.0;
    
    for (int i = 0; i < brain1.phenotypeAxons.size(); i++) {
      for (int n = 0; n < brain2.phenotypeAxons.size(); n++) {
        if (brain1.phenotypeAxons.get(i).genotype == brain2.phenotypeAxons.get(n).genotype) {
          matching++;
          break;
        }
      }
    }
    
    return (float) (brain1.phenotypeAxons.size() + brain2.phenotypeAxons.size() - 2 * matching);
  }
  
  float getAverageExcitabilityDiff(Brain brain1, Brain brain2) {
    if ((brain1.phenotypeAxons.size() == 0) || (brain2.phenotypeAxons.size() == 0)) {
      return 0;
    }
    
    float matching = 0;
    float totalDiff = 0;
    for (int i = 0; i < brain1.phenotypeAxons.size(); i++) {
      for (int n = 0; n < brain2.phenotypeAxons.size(); n++) {
        if (brain1.phenotypeAxons.get(i).genotype == brain2.phenotypeAxons.get(n).genotype) {
          matching++;
          totalDiff += abs(brain1.phenotypeAxons.get(i).excitability - brain2.phenotypeAxons.get(n).excitability);
          break;
        }
      }
    }
    
    if (matching == 0) {
      return 100;
    }
    
    return totalDiff / matching;
  }
  
  void addToSpecies(Human human) {
    specimen.add(human);
  }
  
  void sortSpecies() {
    ArrayList<Human> ladder = new ArrayList<Human>();
    
    for (int i = 0; i < specimen.size(); i++) {
      float maxScore = 0;
      int maxN = 0;
      for (int n = 0; n < specimen.size(); n++) {
        if (specimen.get(n).fitness > maxScore) {
          maxScore = specimen.get(n).fitness;
          maxN = n;
        }
      }
      ladder.add(specimen.get(maxN));
      specimen.remove(maxN);
      i--;
    }
    
    specimen = (ArrayList) ladder.clone();
    if (specimen.size() == 0) {
      staleEvolutions = 500;
      return;
    }
    
    if (specimen.get(0).fitness > bestFitness) {
      staleEvolutions = 0;
      bestFitness = specimen.get(0).fitness;
      bestHuman = specimen.get(0).clone();
      bestBrain = specimen.get(0).brain.clone();
    } else {
      staleEvolutions++;
    }
  }
  
  void cull() {
    if (specimen.size() > 2) {
      for (int i = floor(specimen.size() / 2); i < specimen.size(); i++) {
        specimen.remove(i);
        i--;
      }
    }
  }
  
  void shareFitness() {
    for (int i = 0; i < specimen.size(); i++) {
      specimen.get(i).fitness /= specimen.size();
    }
  }
  
  void setAverage() {
    float sum = 0;
    
    for (int i = 0; i < specimen.size(); i++) {
      sum += specimen.get(i).fitness;
    }
    
    averageFitness = sum / specimen.size();
  }
  
  Human mate(ArrayList<GenotypeAxon> genotypeAxons) {
    Human offspring;
    if ((random(1) < 0.25)) {
      offspring = selectParent().clone();
    } else {
      Human P1 = selectParent();
      Human P2 = selectParent();
      if (P2.fitness < P1.fitness) {
        offspring = P1.crossbreed(P2);
      } else {
        offspring = P2.crossbreed(P1);
      }
    }
    offspring.brain.neuroplasticity(genotypeAxons);
    return offspring;
  }
  
  Human selectParent() {
    float fitness = 0;
    for (int i = 0; i < specimen.size(); i++) {
      fitness += specimen.get(i).fitness;
    }
    
    float r = random(fitness);
    float sum = 0;
    for (int i = 0; i < specimen.size(); i++) {
      sum += specimen.get(i).fitness;
      if (sum > r) {
        return specimen.get(i);
      }
    }
    return specimen.get(0);
  }
}
