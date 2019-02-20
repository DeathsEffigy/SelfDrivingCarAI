class GenotypeAxon {
  int presynapticNeuron;
  int postsynapticNeuron;
  int genotype;
  ArrayList<Integer> genotypes = new ArrayList<Integer>();
  
  GenotypeAxon(int pre, int post, int geno, ArrayList<Integer> genos) {
    presynapticNeuron = pre;
    postsynapticNeuron = post;
    genotype = geno;
    genotypes = (ArrayList) genos.clone();
  }
  
  boolean matches(Brain brain, Neuron pre, Neuron post) {
    // check if genotype/phenotype matches
    if (brain.phenotypeAxons.size() == genotypes.size()) {
      // if Neuron1s & Neuron2s == equal
      if ((pre.no == presynapticNeuron) && (post.no == postsynapticNeuron)) {
        // check for all the phenotypes
        for (int i = 0; i < brain.phenotypeAxons.size(); i++) {
          // if one phenotype != the other, return false
          if (!genotypes.contains(brain.phenotypeAxons.get(i).genotype)) {
            return false;
          }
        }
        
        // if they all match, return true
        return true;
      }
    }
    
    return false;
  }
}
