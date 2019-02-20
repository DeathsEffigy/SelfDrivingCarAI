DNA dna;
Track track;
boolean sketchBrain = true;

void setup() {
  frameRate(60);
  noStroke();
  rectMode(CENTER);
  size(1000, 500);
  
  track = new Track("track1_1.png");
  dna = new DNA(1500);
}

void draw() {
  background(255);
  track.frame();
  dna.frame();
  
  if (dna.generation > 0) {
    drawBrain();
    fill(0,0,0,100.0);
    String s1 = "Generation: " + dna.generation + " (w. " + dna.species.size() + " species)";
    String s2 = "BestScore: " + dna.bestFitness;
    text(s1, 510, 15);
    text(s2, 510, 30);
  }
}

void keyPressed() {
  if (key == 'e') {
    dna.massExtinction();
  } else if (key == 'b') {
    if (dna.generation > 0) {
      sketchBrain = !sketchBrain;
      println("toggled sketchBrain=",sketchBrain);
    }
  }
}

int[] dbFindNeuron(ArrayList<ArrayList<Integer>> neurons, int neuron) {
  int[] out = new int[2];
  for (int i = 0; i < neurons.size(); i++) {
    for (int n = 0; n < neurons.get(i).size(); n++) {
      if (neurons.get(i).get(n) == neuron) {
        out[0] = i;
        out[1] = n;
        return out;
      }
    }
  }
  return out;
}

void drawBrain(){
  if (!sketchBrain) {
    return;
  }
  
  Brain brain = dna.bestBrain;
  
  // setup
  int x = 535;
  int y = 45;
  int offsetX = 30;
  int offsetY = 15;
  int size = 10;
  
  // organise brain
  ArrayList<ArrayList<Integer>> neurons = new ArrayList<ArrayList<Integer>>();
  for (int i = 0; i < brain.layers; i++) {
    neurons.add(new ArrayList<Integer>());
  }
  for (int i = 0; i < brain.neurons.size(); i++) {
    neurons.get(brain.neurons.get(i).type).add(brain.neurons.get(i).no);
  }
  
  // draw axons
  for (int i = 0; i < brain.phenotypeAxons.size(); i++) {
    int[] from = dbFindNeuron(neurons, brain.phenotypeAxons.get(i).presynapticNeuron.no);
    int[] to = dbFindNeuron(neurons, brain.phenotypeAxons.get(i).postsynapticNeuron.no);
    float exc = brain.phenotypeAxons.get(i).excitability;
    boolean exp = brain.phenotypeAxons.get(i).expressed;
    
    if (!exp) {
      stroke(0, 0, 0);
    } else if (exc < 0) {
      stroke(0, 0, 255);
    } else {
      stroke(255, 0, 0);
    }
    
    strokeWeight(int(abs(exc) * 3));
    
    line(x + offsetX * from[0], y + offsetY * from[1], x + offsetX * to[0], y + offsetY * to[1]);
  }
  
  stroke(0, 0,0);
  strokeWeight(1);
  
  // draw neurons
  for (int i = 0; i < brain.layers; i++) {
    for (int n = 0; n < neurons.get(i).size(); n++) {
      fill(255);
      ellipse(x + offsetX * i, y + offsetY * n, size, size);
    }
  }
  
  noStroke();
}
