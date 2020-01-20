class Player {
    
  int xpos = 135;
  int ypos = 475;
  int yvel = 0;
  boolean alive = true;
  final int xlen = 40;
  final int ylen = 50;
  final int accel_g = 1;
  final color colour = color(153, 90, 233);
  
  NeuralNet brain = new NeuralNet(115, 32, 3);
  int[] moves = {-1, 0, 1};
  
  float fitness;
  
  int think (ArrayList<Platform> platforms, ArrayList<Villain> villains) {
    float[] inputs = new float[brain.iNodes];
    
    // inputs from the player
    inputs[0] = xpos;
    inputs[1] = ypos;
    inputs[2] = xlen;
    inputs[3] = ylen;
    inputs[4] = accel_g;
    inputs[5] = yvel;
    
    // inputs from the villains
    inputs[6] = villains.size();
    inputs[7] = Villain.len;
    if (villains.size() > 0) {
      inputs[8] = villains.get(0).speed;
      inputs[9] = villains.get(0).direction;
      inputs[10] = villains.get(0).xpos;
      inputs[11] = villains.get(0).ypos;
    }
    
    // inputs from the platforms
    inputs[12] = platforms.size();
    inputs[13] = Platform.thiccness;
    inputs[14] = Platform.len;
    int index = 15;
    for (Platform plat : platforms) {
      inputs[index] = plat.will_disappear;
      inputs[index + 1] = plat.xpos;
      inputs[index + 2] = plat.ypos;
      inputs[index + 3] = plat.speed;
      inputs[index + 4] = plat.direction;
      index += 5;
    }
    
    float[] moveProbabilities = brain.output(inputs);
    int maxIndex = 0;
    float maxProb = moveProbabilities[0];
    for (int i = 1; i < moveProbabilities.length; i++)
      if (moveProbabilities[i] > maxProb) {
        maxProb = moveProbabilities[i];
        maxIndex = i;
      }
    
    return moves[maxIndex];
  }
  
  void update (ArrayList<Platform> platforms, ArrayList<Villain> villains) {
    
    // changes the horizontal velocities based on brain's decision
    xpos += think(platforms, villains) * 7;
      
    // changes the vertical velocity based on acceleration due to gravity
    yvel += accel_g;
    
    // updates the player position and velocity on collision with a platform
    for (Platform plat : platforms)
      if ((ypos + ylen >= plat.ypos - 10) && (ypos + ylen <= plat.ypos + 25) && (yvel >= 0) && (xpos + xlen + 5 >= plat.xpos) && (xpos <= plat.xpos + Platform.len + 5)) {
        yvel = -20;
        if (plat.will_disappear == 1)
          plat.disappear();
      }
    
    // checks collison with a villain
    for (Villain vil : villains)
      
      // if on top, kills the villain and jumps up (more so than usual also)
      // self.left <= vil.right, right >= left, bottom >=(below) top bound, bottom <=(above) bottom bound
      if ((xpos <= vil.xpos + Villain.len) && (xpos + xlen >= vil.xpos - 10) && (ypos + ylen >= vil.ypos - 10) && (ypos + ylen <= vil.ypos + Villain.len * 2/5) && (yvel >= 0)) {
        vil.disappear();
        yvel = -20 - 5;
      }
      
      // else if, player dies
      // left <= right, right >= left, top <=(above) bottom, bottom >=(below) top
      else if ((xpos <= vil.xpos + Villain.len) && (xpos + xlen >= vil.xpos - 10) && (ypos <= vil.ypos + Villain.len - 10) && (ypos + ylen >= vil.ypos))
        alive = false;
    
    // updates the player's vertical position each frame based on its y velocity
    // and determines if the player is still alive afterwards
    ypos += yvel;
    if (ypos > height)
      alive = false;
    
    // wraps left and right
    if (xpos + xlen/2 <= 0)
      xpos = width + xpos;
    if (xpos >= width - xlen/2)
      xpos = xpos - width;
  }
  
  // displays the player on the screen
  void display() {
    stroke(0);
    strokeWeight(5);
    fill(colour);
    rect(xpos, ypos, xlen, ylen, 5);
  }
  
  // calculates the fitness of the player
  void calculateFitness () {
    fitness = 1.0/ypos;
  }
  
  // returns a completely new Player with the same neural network configuration
  Player clone() {
    Player clone = new Player();
    clone.brain = brain.clone();
    return clone;
  }
  
}
