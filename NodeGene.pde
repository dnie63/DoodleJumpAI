class NodeGene {
  
  int number;
  float inputSum = 0;
  ArrayList<ConnectionGene> outputConnections = new ArrayList<ConnectionGene>();
  int layer;                                                                       // the 0th layer is the input layer
  
  NodeGene (int number, int layer) {
    this.number = number;
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
  
  // returns true if this node is connected to the parameter node
  // used when adding new connection genes
  boolean isConnectedTo (NodeGene node) {
    
    // can't have nodes in the same layer connected to each other
    if (layer == node.layer)
      return false;
    
    // checks the outputconnections depending on which node is earlier in terms of their layers
    if (layer < node.layer) {
      for (ConnectionGene connection : outputConnections)
        if (connection.outputNode.equals(node))
          return true;
    } else {
      for (ConnectionGene connection : node.outputConnections)
        if (connection.outputNode.equals(this))
          return true;
    }
    
    return false;
  }
  
  NodeGene clone () {
    return new NodeGene(number, layer);
  }
  
}
