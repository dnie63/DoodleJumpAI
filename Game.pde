class Game {
  
  ArrayList<Platform> platforms;
  ArrayList<Villain> villains;
  int maxPlatforms = 20;
  int minPlatforms = 6;
  int maxVillains = 1;
  int ratio = 40;                        // ratio = height/maxPlatforms
  color green = color(144, 238, 144);
  color blue = color(107, 202, 226);
  
  Game () {
    platforms = new ArrayList<Platform>();
    villains = new ArrayList<Villain>();
    int[] loc = {100, 800};
    int[] directions = {0, 0};
    platforms.add(new Platform(loc, 0, green, directions, 0));
  }
  
  // returns true if the game is over
  boolean play (Player player, int gen, int currPlayerGame, int popSize, int prevGensHigh, int currGenHigh, int genOfPrevGensHigh) {
    
    // display the platforms, villains, and the player
    for (Platform plat : platforms)
      plat.display();
    for (Villain vil : villains)
      vil.display();
    player.display();
    
    // display the current generation number and current Player number
    fill(0, 0, 0);
    textSize(20);
    text("Gen: " + str(gen), 10, 50);
    text("Player: " + str(currPlayerGame + 1) + " of " + str(popSize), 10, 80);
    text("Prev Gens' Highest: " + str(prevGensHigh) + " (Gen " + str(genOfPrevGensHigh) + ")", 10, 110);
    text("Curr Gen's Highest: " + str(currGenHigh), 10, 140);
    
    boolean isPlayerAlive = player.update(platforms, villains);
    platformManager(player);
    villainManager(player);
    
    return player.ypos > height + 25 || !isPlayerAlive;
  }
  
  void platformManager (Player player) {
    
    // checks if platforms have fallen off the bottom of the screen and deletes them
    for (int i = platforms.size() - 1; i >= 0; i--)
      if (platforms.get(i).ypos > height)
        platforms.remove(i);
      
    // adds in moving and non moving platforms once score is >= 1000
    if (player.score >= 1000) {
      int decrement = Math.min(maxPlatforms - minPlatforms, player.score/500);
      
      while (platforms.size() < maxPlatforms - decrement) {
        float factor = 1.0 * ratio * maxPlatforms / (maxPlatforms - decrement);
        
        if (Math.random()*100 >= 20) {
          int[] loc = {(int)(Math.random()*(width - Platform.len)), (int)(platforms.get(platforms.size() - 1).ypos - factor)};
          int[] directions = {0, 0};
          platforms.add(new Platform(loc, player.score, green, directions, 0));
        
        } else {
          int lowX = Platform.len/2;
          int highX = (int)(width - Platform.len * 1.5);
          int[] loc = {(int)(Math.random()*(highX - lowX) + lowX), (int)(platforms.get(platforms.size() - 1).ypos - factor)};
          int[] directions = {-1, 1};
          platforms.add(new Platform(loc, player.score, blue, directions, 2));
        }
      }
    }
      
    // only adds in non moving platforms at the beginning
    else {
      while (platforms.size() < maxPlatforms) {
        int[] loc = {(int)(Math.random()*(width - Platform.len)), platforms.get(platforms.size() - 1).ypos - ratio};
        int[] directions = {0, 0};
        platforms.add(new Platform(loc, player.score, green, directions, 0));
      }
    }
  }
  
  void villainManager (Player player) {
    
    // checks if villains have fallen off the bottom of the screen and deletes them
    for (int i = villains.size() - 1; i >= 0; i--)
      if (villains.get(i).ypos > height)
        villains.remove(i);
      
    // adds in villains once score is >= 2000
    if (player.score >= 2000)
      while (villains.size() < maxVillains) {
        int lowX = Villain.len/2;
        int highX = (int)(width - Villain.len * 1.5);
        int[] loc = {(int)(Math.random()*(highX - lowX) + lowX), -1 * Villain.len};
        villains.add(new Villain(loc));
      }
  }
  
}
