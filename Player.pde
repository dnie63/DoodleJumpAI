class Player implements Comparable {
  
  PImage rightPic = loadImage("right_dj_guy.png");
  PImage leftPic = loadImage("left_dj_guy.png");
  final int xlen = 60;
  final int ylen = 60;
  final int accel_g = 1;
  final color colour = color(153, 90, 233);
  int xpos = width/2 - xlen/2;
  int ypos = height*4/5;
  int yvel = 0;
  boolean alive = true;
  ArrayList<Villain> villainsKilled = new ArrayList<Villain>();
  ArrayList<Platform> disappearedPlatforms = new ArrayList<Platform>();
  ArrayList<Villain> villainsSeen = new ArrayList<Villain>();
  
  int totalJumps = 0;
  int beneficialJumps = 0;
  int highestYPos = height*3/4;
  int timeOfLastInc = millis();
  int totalLeftRightMoves = 0;
  int numPassedWalls = 0;
  int lastMove = 1;
  int sight = 200;
  int lastMoveNeuralDisplay = -1;
  int highestYPosAdjusted;
  
  Genome brain;
  int[] moves = {0, -1, 1};
  ArrayList<Platform> nearestPlatforms;
  
  float fitness;
  
  Player (Genome brain) {
    this.brain = brain;
  }
  
  int think (ArrayList<Platform> platforms, ArrayList<Villain> villains) {
    
    // only gets new platforms to see if the player has finished its previous play
    if (yvel == -20)
      nearestPlatforms = getNearestPlatforms(platforms);
    Villain nearestVillain = getNearestVillain(villains);
    float[] inputs = new float[NEAT_Config.INPUTS];
    int index = 0;
    
    if (nearestPlatforms != null) {
      for (Platform plat : nearestPlatforms) {
        
        // index 0 represents distance to travel moving left and index 1 distance to travel moving right
        if (xpos > plat.xpos) {
          inputs[index] = xpos - plat.xpos - Platform.len;
          inputs[index+1] = width - xpos - xlen - plat.xpos;
        } else {
          inputs[index] = width - xpos - plat.xpos - Platform.len;
          inputs[index+1] = plat.xpos - xpos - xlen;
        }
        inputs[index+2] = ypos - plat.ypos;
        index += 3;
      }
    }
    
    if (nearestVillain != null) {
      if (xpos > nearestVillain.xpos) {
        inputs[index] = xpos - nearestVillain.xpos;
        inputs[index+1] = width - xpos - nearestVillain.xpos;
      } else {
        inputs[index] = width - xpos - nearestVillain.xpos;
        inputs[index+1] = nearestVillain.xpos - xpos;
      }
      inputs[index+2] = ypos - nearestVillain.ypos;
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
  
  void update (ArrayList<Platform> platforms, ArrayList<Villain> villains) {
    
    // changes the horizontal velocities based on brain's decision
    int move = think(platforms, villains);
    xpos += move * 7;

    if (abs(move) > 0)
      totalLeftRightMoves += 1;
      
    if (move > 0)
      lastMove = 1;
    if (move < 0)
      lastMove = -1;
      
    lastMoveNeuralDisplay = move;
      
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
      if ((ypos + ylen >= plat.ypos - 10) && (ypos + ylen <= plat.ypos + 25) && (yvel >= 0) && (xpos + xlen - 5 >= plat.xpos) && (xpos <= plat.xpos + Platform.len - 5)) {
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
      if ((xpos <= vil.xpos + Villain.villWidth) && (xpos + xlen >= vil.xpos - 10) && (ypos + ylen >= vil.ypos - 10) && (ypos + ylen <= vil.ypos + Villain.villHeight * 2/5) && (yvel >= 0)) {
        villainsKilled.add(vil);
        yvel = -20;
      }
      
      // else if, player dies
      // left <= right, right >= left, top <=(above) bottom, bottom >=(below) top
      else if ((xpos <= vil.xpos + Villain.villWidth) && (xpos + xlen >= vil.xpos - 10) && (ypos <= vil.ypos + Villain.villHeight - 10) && (ypos + ylen >= vil.ypos)) {
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
    if (yvel > 24)
      alive = false;
    
    // wraps left and right
    if (xpos + xlen/2 <= 0) {
      xpos = width + xpos;
      numPassedWalls += 1;
    }
    if (xpos >= width - xlen/2) {
      xpos = xpos - width;
      numPassedWalls += 1;
    }
      
    // the player dies if it has been stagnant in the last ten seconds
    if (millis() > timeOfLastInc + 5000)
      alive = false;
  }
  
  // displays the player on the screen
  void display() {
    stroke(0);
    strokeWeight(5);
    fill(colour);
    
    if (lastMove > 0)
      image(rightPic, xpos, ypos);
    else
      image(leftPic, xpos, ypos);
  }
  
  // calculates the fitness of the player
  void calculateFitness (int bar) {
    fitness = highestYPosAdjusted - totalJumps*bar/100;
  }
  
  // returns the platforms closest to the player depending on y height
  ArrayList<Platform> getNearestPlatforms (ArrayList<Platform> platforms) {
    ArrayList<Platform> nearest = new ArrayList<Platform>();
    ArrayList<Platform> sorted = new ArrayList<Platform>(platforms);
    Collections.sort(sorted, Collections.reverseOrder());
    
    for (Platform plat : platforms) {
      if (abs(plat.ypos - ypos) < sight)
        nearest.add(plat);
      
      if (nearest.size() >= 3)
        return nearest;
    }
        
    return nearest;
  }
  
  // returns the closest villain
  Villain getNearestVillain (ArrayList<Villain> villains) {
    for (Villain vil : villains) {
      if (abs(vil.ypos - ypos) < sight) {
        boolean returnVillain = true;
        
        for (Villain killed : villainsKilled)
          if (killed.equals(vil))
            returnVillain = false;
        
        if (returnVillain)
          return vil;
      }
    }
        
    return null;
  }
  
  public int compareTo(Object o) {
      Player g = (Player)o;
      
      if (highestYPos == g.highestYPos)
          return 0;
      else if (highestYPos < g.highestYPos)
          return 1;
      else
          return -1;
  }
  
}
