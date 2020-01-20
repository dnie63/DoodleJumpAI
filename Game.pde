class Game {
  
  ArrayList<Platform> platforms;
  ArrayList<Villain> villains;
  int maxPlatforms = 20;
  int minPlatforms = 6;
  int maxVillains = 1;
  int ratio = 40;                        // ratio = height/maxPlatforms
  int highestScore = 0;
  color green = color(144, 238, 144);
  color blue = color(107, 202, 226);
  
  Game () {
    platforms = new ArrayList<Platform>();
    villains = new ArrayList<Villain>();
    int[] loc = {100, 800};
    int[] directions = {0, 0};
    platforms.add(new Platform(loc, 0, green, directions, 0));
  }
  
  // returns true if all players are dead
  boolean play (ArrayList<Player> players, int gen, int prevGensHigh, int genOfPrevGensHigh, int popSize) {
    int numPlayersAlive = 0;
    
    // display the platforms, villains, and players who are still alive
    for (Platform plat : platforms)
      plat.display();
    for (Villain vil : villains)
      vil.display();
    for (Player player : players)
      if (player.alive) {
        player.display();
        numPlayersAlive += 1;
      }
    
    // checks to see if all players are dead and what the current highest ypos is after playing a step of each player
    boolean gameOver = true;
    int highestYPos = height;
    for (Player player : players) {
      if (player.alive) {
        gameOver = false;
        player.update(platforms, villains);
        if (player.ypos < highestYPos)
          highestYPos = player.ypos;
      }
    }
    
    adjustView(highestYPos, players);
    platformManager(highestScore);
    villainManager(highestScore);
    
    // display the highest score, the current generation number, and the previous generations' highest score
    fill(0, 0, 0);
    textSize(20);
    text("Highest Score: " + str(highestScore), 10, 20);
    text("Players Alive (out of " + str(popSize) + "): " + str(numPlayersAlive), 10, 50);
    text("Gen: " + str(gen), 10, 80);
    text("Prev Gens' Highest: " + str(prevGensHigh) + " (Gen " + str(genOfPrevGensHigh) + ")", 10, 110);
    
    return gameOver;
  }
  
  void platformManager (int highestScore) {
    
    // checks if platforms have fallen off the bottom of the screen and deletes them
    for (int i = platforms.size() - 1; i >= 0; i--)
      if (platforms.get(i).ypos > height)
        platforms.remove(i);
      
    // adds in moving and non moving platforms once score is >= 1000
    if (highestScore >= 1000) {
      int decrement = Math.min(maxPlatforms - minPlatforms, highestScore/500);
      
      while (platforms.size() < maxPlatforms - decrement) {
        float factor = 1.0 * ratio * maxPlatforms / (maxPlatforms - decrement);
        
        if (Math.random()*100 >= 20) {
          int[] loc = {(int)(Math.random()*(width - Platform.len)), (int)(platforms.get(platforms.size() - 1).ypos - factor)};
          int[] directions = {0, 0};
          platforms.add(new Platform(loc, highestScore, green, directions, 0));
        
        } else {
          int lowX = Platform.len/2;
          int highX = (int)(width - Platform.len * 1.5);
          int[] loc = {(int)(Math.random()*(highX - lowX) + lowX), (int)(platforms.get(platforms.size() - 1).ypos - factor)};
          int[] directions = {-1, 1};
          platforms.add(new Platform(loc, highestScore, blue, directions, 2));
        }
      }
    }
      
    // only adds in non moving platforms at the beginning
    else {
      while (platforms.size() < maxPlatforms) {
        int[] loc = {(int)(Math.random()*(width - Platform.len)), platforms.get(platforms.size() - 1).ypos - ratio};
        int[] directions = {0, 0};
        platforms.add(new Platform(loc, highestScore, green, directions, 0));
      }
    }
  }
  
  void villainManager (int highestScore) {
    
    // checks if villains have fallen off the bottom of the screen and deletes them
    for (int i = villains.size() - 1; i >= 0; i--)
      if (villains.get(i).ypos > height)
        villains.remove(i);
      
    // adds in villains once score is >= 2000
    if (highestScore >= 2000)
      while (villains.size() < maxVillains) {
        int lowX = Villain.len/2;
        int highX = (int)(width - Villain.len * 1.5);
        int[] loc = {(int)(Math.random()*(highX - lowX) + lowX), -1 * Villain.len};
        villains.add(new Villain(loc));
      }
  }
  
  //adjusts the view according to the highestYPos
  void adjustView (int highestYPos, ArrayList<Player> players) {
    
    // "moves" the view frame if highest player moves too far up and increases the highest score accordingly
    if (highestYPos < 300) {
      int climb = 300 - highestYPos;
      highestScore += climb;
      
      for (Platform plat : platforms)
        plat.ypos += climb;
      for (Villain vil : villains)
        vil.ypos += climb;
      for (Player player : players)
        player.ypos += climb;
    }
  }
  
}
