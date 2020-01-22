class NodeGene {
  
  int layer;  // the 0th layer is the input layer
  float inputSum = 0;
  ArrayList<ConnectionGene> outputConnections = new ArrayList<ConnectionGene>();
  
  NodeGene (int layer) {
    this.layer = layer;
  }
  
  // this node sends its output value to every node that it's connected to
  void fire () {
    float outputValue = inputSum;
    if (layer > 0)
      outputValue = sigmoid(inputSum);
    
    for (ConnectionGene connection : outputConnections)
      if (connection.enabled)
        connection.outputNode.inputSum += connection.weight * outputValue;
  }
  
  // the activation function
  float sigmoid (float a) {
    return (float) 1 / (1 + pow((float) Math.E, -1 * a));
  }
  
}
