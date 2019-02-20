class Axon {
  int no;
  Neuron presynapticNeuron;
  Neuron postsynapticNeuron;
  int genotype;
  float excitability;
  boolean expressed = true;
  
  Axon(int id, Neuron pre, Neuron post, int geno, float e) {
    no = id;
    presynapticNeuron = pre;
    postsynapticNeuron = post;
    genotype = geno;
    excitability = e;
  }
  
  void mutate() {
    float r = random(1);
    if (r < 0.1) {
      excitability = random(-1, 1);
    } else {
      excitability += (randomGaussian() / 50);
      
      if (excitability > 1) {
        excitability = 1;
      } else if (excitability < -1) {
        excitability = -1;
      }
    }
  }
  
  Axon clone(Neuron pre, Neuron post) {
    Axon clone = new Axon(no, pre, post, genotype, excitability);
    clone.expressed = expressed;
    return clone;
  }
}
