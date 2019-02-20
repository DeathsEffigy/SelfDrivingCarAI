class Neuron {
  int no;
  int type;
  ArrayList<Axon> axons = new ArrayList<Axon>();
  float actionPotential;
  float signal;
  
  Neuron(int id, int ntype) {
    no = id;
    type = ntype;
    actionPotential = 0;
    signal = 0;
  }
  
  float sigmoid(float x) {
    float y = 1 / (1 + pow((float)Math.E, -4.9*x));
    return y;
  }
  
  void excite() {
    // don't sigmoid() for bias/sensory
    if (type > 0) {
      signal = sigmoid(actionPotential);
    } else {
      signal = actionPotential;
    }
    
    // add to AP for all postsyn neurons
    for (int i = 0; i < axons.size(); i++) {
      if (axons.get(i).expressed) {
        axons.get(i).postsynapticNeuron.actionPotential += signal * axons.get(i).excitability;
      }
    }
  }
  
  void assumeRestingPotential() {
    actionPotential = 0;
    signal = 0;
  }
  
  boolean hasAxonTerminalTo(int id) {
    boolean hasTerminal = false;
    for (int i = 0; i < axons.size(); i++) {
      if (axons.get(i).postsynapticNeuron.no == id) {
        hasTerminal = true;
      }
    }
    return hasTerminal;
  }
  
  boolean hasDendriteTo(int id) {
    boolean hasTerminal = false;
    for (int i = 0; i < axons.size(); i++) {
      if (axons.get(i).postsynapticNeuron.no == id) {
        hasTerminal = true;
      }
    }
    return hasTerminal;
  }
  
  int findAxon(int id) {
    for (int i = 0; i < axons.size(); i++) {
      if (axons.get(i).no == id) {
        return i;
      }
    }
    
    return -1;
  }
  
  Neuron clone() {
    Neuron clone = new Neuron(no, type);
    return clone;
  }
}
