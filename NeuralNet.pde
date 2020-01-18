class NeuralNet {
  
  // crossover function (the two parents are this.neuralnet and the passed in neural net)
  // mutate function (randomly adjust the weights and biases)
  //     mutation rate (probability that a given weight/bias is mutated)
  
  // hardcoded in the structure of the model with three layers (input, hidden, output)
  int iNodes;
  int hNodes;
  int oNodes;
  
  float[][] ihw;
  float[][] how;
  
  float[] ihb;
  float[] hob;
  
  final static int absMaxWeight = 1;
  final static int absMaxBias = 1;
  
  // initializes the network with random values for the weights and biases
  NeuralNet (int iNodes, int hNodes, int oNodes) {
    this.iNodes = iNodes;
    this.hNodes = hNodes;
    this.oNodes = oNodes;
    
    // creates the weight matrices with random values between the layers
    ihw = Matrix.random(hNodes, iNodes, -1 * absMaxWeight, absMaxWeight);
    how = Matrix.random(oNodes, hNodes, -1 * absMaxWeight, absMaxWeight);
    
    // creates the bias vectors with random values between the layers
    ihb = Matrix.random(hNodes, -1 * absMaxBias, absMaxBias);
    hob = Matrix.random(oNodes, -1 * absMaxBias, absMaxBias);
  }
  
  // feeds the inputs layer through the network and returns the output layer
  float[] output(float[] inputs) {
    if (inputs.length != iNodes) throw new RuntimeException("Illegal input dimensions.");
    
    float[] hiddens = Matrix.activate(Matrix.add(Matrix.multiply(ihw, inputs), ihb));
    float[] outputs = Matrix.activate(Matrix.add(Matrix.multiply(how, hiddens), hob));
    
    return outputs;
  }
  
  // returns a new neural net that is the clone (copy) of this neural net
  NeuralNet clone () {
    NeuralNet clone = new NeuralNet(iNodes, hNodes, oNodes);
    clone.ihw = Matrix.copy(ihw);
    clone.how = Matrix.copy(how);
    clone.ihb = Matrix.copy(ihb);
    clone.hob = Matrix.copy(hob);
    return clone;
  }
  
  // returns a new neural net that is the crossover of this neural net and the passed in neural net
  NeuralNet crossover (NeuralNet partner) {
    NeuralNet childNeuralNet = new NeuralNet(iNodes, hNodes, oNodes);
    childNeuralNet.ihw = Matrix.crossover(this.ihw, partner.ihw);
    childNeuralNet.how = Matrix.crossover(this.how, partner.how);
    childNeuralNet.ihb = Matrix.crossover(this.ihb, partner.ihb);
    childNeuralNet.hob = Matrix.crossover(this.hob, partner.hob);
    return childNeuralNet;
  }
  
  // mutates the neural net with given mutationRate
  void mutate (float mutationRate) {
    Matrix.mutate(ihw, mutationRate);
    Matrix.mutate(how, mutationRate);
    Matrix.mutate(ihb, mutationRate);
    Matrix.mutate(hob, mutationRate);
  }
  
}
