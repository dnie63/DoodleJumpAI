class Player {
  
  final int xlen = 40;
  final int ylen = 50;
  final int accel_g = 1;
  final color colour = color(153, 90, 233);
  int xpos = width/2 - xlen/2;
  int ypos = height*4/5;
  int yvel = 0;
  boolean alive = true;
  ArrayList<Villain> villainsKilled = new ArrayList<Villain>();
  ArrayList<Platform> disappearedPlatforms = new ArrayList<Platform>();
  
  int totalJumps = 0;
  int beneficialJumps = 0;
  int highestYPos = height*3/4;
  int timeOfLastInc = millis();
  int totalLeftRightMoves = 0;
  
  Genome brain;
  int[] moves = {-1, 0, 1};
  
  float fitness;
  
  Player (Genome brain) {
    this.brain = brain;
  }
  
  int think (ArrayList<Platform> platforms, int step) {
    ArrayList<Platform> nearestPlatforms = getNearestPlatforms(platforms, step);
    float[] inputs = new float[NEAT_Config.INPUTS];
    int index = 0;
    for (Platform plat : nearestPlatforms) {
      inputs[index] = plat.xpos - xpos;
      inputs[index + 1] = ypos - plat.ypos;
      index += 2;
    }
    
    float[] moveProbabilities = brain.evaluateNetwork(inputs);
    int maxIndex = 0;
    float maxProb = moveProbabilities[0];
    for (int i = 1; i < moveProbabilities.length; i++)
      if (moveProbabilities[i] > maxProb) {
        maxProb = moveProbabilities[i];
        maxIndex = i;
      }
    
    return moves[maxIndex];
  }
  
  void update (ArrayList<Platform> platforms, ArrayList<Villain> villains, int step) {
    
    // changes the horizontal velocities based on brain's decision
    int move = think(platforms, step);
    xpos += move * 7;

    if (abs(move) > 0)
      totalLeftRightMoves += 1;
      
    // changes the vertical velocity based on acceleration due to gravity
    yvel += accel_g;
    
    // if the previous jump resulted in an increase in absolute position (ie score)
    if (ypos < highestYPos && yvel == 0) {
      beneficialJumps += 1;
      highestYPos = ypos;
      timeOfLastInc = millis();
    }
    
    // updates the player position and velocity on collision with a platform
    for (Platform plat : platforms)
      if ((ypos + ylen >= plat.ypos - 10) && (ypos + ylen <= plat.ypos + 25) && (yvel >= 0) && (xpos + xlen + 5 >= plat.xpos) && (xpos <= plat.xpos + Platform.len + 5)) {
        int origYvel = yvel;
        yvel = -20;
        if (plat.will_disappear == 1) {
          boolean hasHitBefore = false;
          for (Platform disappeared : disappearedPlatforms)
            if(disappeared.equals(plat))
              hasHitBefore = true;
          if (!hasHitBefore)
            disappearedPlatforms.add(plat);
          else
            yvel = origYvel;
        }
        
        totalJumps += 1;
      }
    
    // checks collison with a villain
    for (Villain vil : villains)
      
      // if on top, kills the villain and jumps up (more so than usual also)
      // self.left <= vil.right, right >= left, bottom >=(below) top bound, bottom <=(above) bottom bound
      if ((xpos <= vil.xpos + Villain.len) && (xpos + xlen >= vil.xpos - 10) && (ypos + ylen >= vil.ypos - 10) && (ypos + ylen <= vil.ypos + Villain.len * 2/5) && (yvel >= 0)) {
        villainsKilled.add(vil);
        yvel = -20 - 5;
      }
      
      // else if, player dies
      // left <= right, right >= left, top <=(above) bottom, bottom >=(below) top
      else if ((xpos <= vil.xpos + Villain.len) && (xpos + xlen >= vil.xpos - 10) && (ypos <= vil.ypos + Villain.len - 10) && (ypos + ylen >= vil.ypos)) {
        alive = false;
        
        // revives the player if this player has killed this villain before
        // this logic is necessary for a given villain to affect every player on the screen
        for (Villain killed : villainsKilled)
          if (killed.equals(vil))
            alive = true;
      }
      
    // updates the player's vertical position each frame based on its y velocity
    // and determines if the player is still alive afterwards
    ypos += yvel;
    if (yvel > 27)
      alive = false;
    
    // wraps left and right
    if (xpos + xlen/2 <= 0)
      xpos = width + xpos;
    if (xpos >= width - xlen/2)
      xpos = xpos - width;
      
    // the player dies if it has been stagnant in the last ten seconds
    if (millis() > timeOfLastInc + 10000)
      alive = false;
  }
  
  // displays the player on the screen
  void display() {
    stroke(0);
    strokeWeight(5);
    fill(colour);
    rect(xpos, ypos, xlen, ylen, 5);
  }
  
  // calculates the fitness of the player
  void calculateFitness (int bar) {
    fitness = highestYPos + beneficialJumps*bar/100;
  }
  
  // returns the platforms closest to the player depending on y height
  ArrayList<Platform> getNearestPlatforms (ArrayList<Platform> platforms, int step) {
    ArrayList<Platform> nearest = new ArrayList<Platform>();
    
    for (Platform plat : platforms) {
      if (abs(plat.ypos - ypos) < (int) (step * 1.5))
        nearest.add(plat);
      if (nearest.size() >= 3)
        return nearest;
    }
        
    return nearest;
  }
  
}
