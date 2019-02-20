/*
int neuronBiased = 0;
int neuronSensory = 0;
int neuronPerceptoryBase = 0;
int neuronMotor = 1;
*/
int nextAxon = 0;

class Brain {
  ArrayList<Neuron> neurons = new ArrayList<Neuron>();
  ArrayList<Axon> phenotypeAxons = new ArrayList<Axon>();
  int afferent;
  int efferent;
  int layers;
  int biasNeuron;
  
  Brain(int _in, int _out) {
    afferent = _in;
    efferent = _out;
    layers = 2;
    neurogenesis();
  }
  
  float[] perceive(float[] sensations) {
    float[] percepts = new float[efferent];
    
    // setup sensory neurons
    for (int i = 0; i < afferent; i++) {
      neurons.get(i).actionPotential = sensations[i];
    }
    
    // setup bias neuron
    neurons.get(biasNeuron).actionPotential = 1.0;
    
    // excite neurons layer-wise
    for (int i = 0; i < layers; i++) {
      for (int n = 0; n < neurons.size(); n++) {
        if (neurons.get(n).type == i) {
          neurons.get(n).excite();
        }
      }
    }
    
    // get motor neurons
    for (int i = 0; i < efferent; i++) {
      percepts[i] = neurons.get(afferent + 1 + i).signal;
    }
    
    // reset neurons
    for (int i = 0; i < neurons.size(); i++) {
      neurons.get(i).assumeRestingPotential();
    }
    
    return percepts;
  }
  
  void neurogenesis() {
    // genesis of sensory neurons
    for (int i = 0; i < afferent; i++) {
      neurons.add(new Neuron(neurons.size(), 0));
    }
    // genesis of bias neuron
    biasNeuron = neurons.size();
    neurons.add(new Neuron(neurons.size(), 0));
    // genesis of motor neurons
    for (int i = 0; i < efferent; i++) {
      neurons.add(new Neuron(neurons.size(), 1));
    }
  }
  
  void phenotypegenesis() {
    // clear old axons
    for (int i = 0; i < neurons.size(); i++) {
      neurons.get(i).axons.clear();
    }
    
    // add phenotypeAxons
    for (int i = 0; i < phenotypeAxons.size(); i++) {
      phenotypeAxons.get(i).presynapticNeuron.axons.add(phenotypeAxons.get(i));
    }
  }
  
  void neuroplasticity(ArrayList<GenotypeAxon> genotypeAxons) {
    // if there are no axons, grow a new one
    if (phenotypeAxons.size() == 0) {
      growAxon(genotypeAxons);
    }
    
    // mutate excitabilities 80% of the time
    float r = random(1);
    if (r < 0.8) {
      for (int i = 0; i < phenotypeAxons.size(); i++) {
        phenotypeAxons.get(i).mutate();
      }
    }
    
    // grow new axon terminal 50% of the time
    r = random(1);
    if (r < 0.50) {
      growAxon(genotypeAxons);
    }
    
    // grow new neuron .2% of the time
    r = random(10) / 10;
    if (r < 0.002) {
      growNeuron(genotypeAxons);
    }
  }
  
  void growNeuron(ArrayList<GenotypeAxon> genotypeAxons) {
    if (phenotypeAxons.size() == 0) {
      growAxon(genotypeAxons);
      return;
    }
    
    // disable random axon
    int someAxon = 0;
    int killSwitch = 0;
    do {
      if (killSwitch > (phenotypeAxons.size() * 5)) { // we implemented this as a hacky fix for endless loops in cases where there's two phenotypeAxons that are both connected to the bias node;; could be prettier...but...eh... 
        return;
      }
      someAxon = floor(random(phenotypeAxons.size()));
      killSwitch++;
    } while ((phenotypeAxons.get(someAxon).presynapticNeuron == neurons.get(biasNeuron)) && (phenotypeAxons.size() != 1));
    phenotypeAxons.get(someAxon).expressed = false;
    
    // insert new neuron
    int newNeuron = neurons.size();
    neurons.add(new Neuron(newNeuron, -1)); // we'll see the type in a minute
    
    // add new axon from disabled neuron's presynapse to new neuron with excitability=1
    int genotype = getGenotype(genotypeAxons, phenotypeAxons.get(someAxon).presynapticNeuron, neurons.get(findNeuron(newNeuron)));
    phenotypeAxons.add(new Axon(phenotypeAxons.size(), phenotypeAxons.get(someAxon).presynapticNeuron, neurons.get(findNeuron(newNeuron)), genotype, 1.0));
    
    // add new axon from new neuron to disabled neuron's postsynapse w previous excitability
    genotype = getGenotype(genotypeAxons, neurons.get(findNeuron(newNeuron)), phenotypeAxons.get(someAxon).postsynapticNeuron);
    phenotypeAxons.add(new Axon(phenotypeAxons.size(), neurons.get(findNeuron(newNeuron)), phenotypeAxons.get(someAxon).postsynapticNeuron, genotype, phenotypeAxons.get(someAxon).excitability));
    
    // set new neuron's layer = old presynapse layer + 1;
    neurons.get(findNeuron(newNeuron)).type = phenotypeAxons.get(someAxon).presynapticNeuron.type + 1;
    
    // connect to bias neuron w excitability = 0
    genotype = getGenotype(genotypeAxons, neurons.get(biasNeuron), neurons.get(findNeuron(newNeuron)));
    phenotypeAxons.add(new Axon(phenotypeAxons.size(), neurons.get(biasNeuron), neurons.get(findNeuron(newNeuron)), genotype, 0.0));
    
    // adjust types and such
    if (neurons.get(findNeuron(newNeuron)).type == phenotypeAxons.get(someAxon).postsynapticNeuron.type) {
      for (int i = 0; i < (neurons.size() - 1); i++) {
        if (neurons.get(i).type >= neurons.get(findNeuron(newNeuron)).type) {
          neurons.get(i).type++;
        }
      }
      layers++;
    }
    
    // update
    phenotypegenesis();
  }
  
  boolean hasVacantDendrites() {
    int maximumAxonTerminals = 0;
    int[] neuronsInLayer = new int [layers];
    
    for (int i = 0; i < neurons.size(); i++) {
      neuronsInLayer[neurons.get(i).type]++;
    }
    
    // loop for every layer (except motor neurons who don't have axons anyway)
    for (int i = 0; i < (neuronsInLayer.length - 1); i++) {
      int candidateDendrites = 0; // dendrites this neuron's axon could attach to
      // loop through all layers following current layer
      for (int n = i + 1; n < neuronsInLayer.length; n++) {
        // increase dendrite counter
        candidateDendrites += neuronsInLayer[n];
      }
      
      maximumAxonTerminals += neuronsInLayer[i] * candidateDendrites;
    }
    
    if (phenotypeAxons.size() == maximumAxonTerminals) {
      return false;
    }
    return true;
  }
  
  void growAxon(ArrayList<GenotypeAxon> genotypeAxons) {
    if (!hasVacantDendrites()) {
      // fully grown brain
      return;
    }
    
    // randomly pick two neurons that aren't of the same type and don't already share an axonTerminal->Dendrite relation
    int neuronOne = 0;
    int neuronTwo = 0;
    do {
      neuronOne = floor(random(neurons.size()));
      neuronTwo = floor(random(neurons.size()));
    } while ((neurons.get(neuronOne).type == neurons.get(neuronTwo).type) || (neurons.get(neuronOne).hasAxonTerminalTo(neuronTwo)) || (neurons.get(neuronOne).hasDendriteTo(neuronTwo)));
    
    // if neuron one is higher in hierarchy, do swapsies
    if (neurons.get(neuronOne).type > neurons.get(neuronTwo).type) {
      int n = neuronOne;
      neuronOne = neuronTwo;
      neuronTwo = n;
    }
    
    int genotype = getGenotype(genotypeAxons, neurons.get(neuronOne), neurons.get(neuronTwo));
    phenotypeAxons.add(new Axon(phenotypeAxons.size(), neurons.get(neuronOne), neurons.get(neuronTwo), genotype, random(-1, 1)));
    phenotypegenesis();
  }
  
  int getGenotype(ArrayList<GenotypeAxon> genotypeAxons, Neuron presynapticNeuron, Neuron postsynapticNeuron) {
    boolean unknownGenotype = true;
    int genotype = nextAxon;
    
    // loop through genotypes
    for (int i = 0; i < genotypeAxons.size(); i++) {
      // is this a novel genotype?
      if (genotypeAxons.get(i).matches(this, presynapticNeuron, postsynapticNeuron)) {
        unknownGenotype = false;
      }
    }
    
    if (unknownGenotype) {
      // get genotype representation of brain
      ArrayList<Integer> genotypes = new ArrayList<Integer>();
      for (int i = 0; i < phenotypeAxons.size(); i++) {
        genotypes.add(phenotypeAxons.get(i).genotype);
      }
      
      // push mutation into genotype pool
      genotypeAxons.add(new GenotypeAxon(presynapticNeuron.no, postsynapticNeuron.no, genotype, genotypes));
      nextAxon++;
    }
    
    return genotype;
  }
  
  int findNeuron(int id) {
    for (int i = 0; i < neurons.size(); i++) {
      if (neurons.get(i).no == id) {
        return i;
      }
    }
    
    return neurons.size()-1;
  }
  
  // alternative constructor for clone()
  Brain(int _in, int _out, boolean isBeingCloned) {
    afferent = _in;
    efferent = _out;
  }
  
  Brain clone() {
    // make new brain w alternative constructor
    Brain clone = new Brain(afferent, efferent, true);
    
    // clone neurons
    for (int i = 0; i < neurons.size(); i++) {
      clone.neurons.add(neurons.get(i).clone());
    }
    
    // clone axons
    for (int i = 0; i < phenotypeAxons.size(); i++) {
      clone.phenotypeAxons.add(phenotypeAxons.get(i).clone(clone.neurons.get(clone.findNeuron(phenotypeAxons.get(i).presynapticNeuron.no)), clone.neurons.get(clone.findNeuron(phenotypeAxons.get(i).postsynapticNeuron.no))));
    }
    
    clone.layers = layers;
    clone.biasNeuron = biasNeuron;
    clone.phenotypegenesis();
    
    return clone;
  }
  
  Brain crossbreed(Brain P2) {
    Brain brain = new Brain(afferent, efferent, true);
    brain.phenotypeAxons.clear();
    brain.neurons.clear();
    brain.layers = layers;
    brain.biasNeuron = biasNeuron;
    
    ArrayList<Axon> phenoAx = new ArrayList<Axon>();
    ArrayList<Boolean> isExpressed = new ArrayList<Boolean>();
    for (int i = 0; i < phenotypeAxons.size(); i++) {
      boolean express = true;
      int P2pheno = matchingPhenotype(P2, phenotypeAxons.get(i).genotype);
      
      if (P2pheno > -1) {
        if ((!phenotypeAxons.get(i).expressed) || (!P2.phenotypeAxons.get(P2pheno).expressed)) {
          if (random(1) > 0.25) {
            express = false;
          }
        }
        
        float r = random(1);
        if (r > 0.5) {
          phenoAx.add(phenotypeAxons.get(i));
        } else {
          phenoAx.add(P2.phenotypeAxons.get(P2pheno));
        }
      } else {
        phenoAx.add(phenotypeAxons.get(i));
        express = phenotypeAxons.get(i).expressed;
      }
      isExpressed.add(express);
    }
    
    for (int i = 0; i < neurons.size(); i++) {
      brain.neurons.add(neurons.get(i).clone());
    }
    
    for (int i = 0; i < phenoAx.size(); i++) {
      brain.phenotypeAxons.add(phenoAx.get(i).clone(brain.neurons.get(brain.findNeuron(phenoAx.get(i).presynapticNeuron.no)), brain.neurons.get(brain.findNeuron(phenoAx.get(i).postsynapticNeuron.no))));
      brain.phenotypeAxons.get(i).expressed = isExpressed.get(i);
    }
    
    brain.phenotypegenesis();
    return brain;
  }
  
  int matchingPhenotype(Brain brain2, int geno) {
    for (int i = 0; i < brain2.phenotypeAxons.size(); i++) {
      if (brain2.phenotypeAxons.get(i).genotype == geno) {
        return i;
      }
    }
    return -1;
  }
}
