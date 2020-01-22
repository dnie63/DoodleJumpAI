class ConnectionGene {
  
  NodeGene inputNode;
  NodeGene outputNode;
  float weight;
  boolean enabled = true;
  int innovationNo;
  
  ConnectionGene (NodeGene inputNode, NodeGene outputNode, float weight, int innovationNo) {
    this.inputNode = inputNode;
    this.outputNode = outputNode;
    this.weight = weight;
    this.innovationNo = innovationNo;
  }
  
  void mutateWeight () {
    
    // completely changes the weight randomly 10% of the time
    if (random(1) < 0.1)
      weight = random(-1, 1);
    
    // changes the weight slightly the other 90% of the time
    else {
      weight += randomGaussian()/50;
      
      // keep the weight between -1 and 1 inclusive
      if (weight > 1)
        weight = 1;
      else if (weight < -1)
        weight = -1;
    }
  }
  
}
