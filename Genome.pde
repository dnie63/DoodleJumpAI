class Genome {
  
  ArrayList<ArrayList<NodeGene>> layersOfNodeGenes = new ArrayList<ArrayList<NodeGene>>();
  ArrayList<ConnectionGene> connectionGenes = new ArrayList<ConnectionGene>();
  int inputSize;
  int outputSize;
  
  Genome (int inputSize, int outputSize) {
    this.inputSize = inputSize;
    this.outputSize = outputSize;
    
    // create and add the input layer
    // create and add nodes to the input layer
    layersOfNodeGenes.add(new ArrayList<NodeGene>());
    for (int i = 0; i < inputSize; i++)
      layersOfNodeGenes.get(0).add(new NodeGene(0));
    
    // create and add the output layer
    // create and add nodes to the output layer
    for (int i = 0; i < outputSize; i++)
      layersOfNodeGenes.get(1).add(new NodeGene(1));
    
    // create and add the bias node to the input layer
    layersOfNodeGenes.get(0).add(new NodeGene(0));
  }
  
}
