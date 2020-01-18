class Population {
    
  int popSize;
  ArrayList<Player> players;
  ArrayList<Game> games;
  int currPlayerGame = 0;
  int gen = 1;
  int prevGensHigh = 0;
  int genOfPrevGensHigh = 0;
  int currGenHigh = 0;
  float mutationRate = 0.1;
  
  // initializes a population of players and corresponding games to play in
  Population (int size) {
    popSize = size;
    players = new ArrayList<Player>();
    for (int i = 0; i < popSize; i++)
      players.add(new Player());
      
    games = new ArrayList<Game>();
    for (int i = 0; i < popSize; i++)
      games.add(new Game());
  }
  
  // updates the state of the population of players
  void update () {
    Player currPlayer = players.get(currPlayerGame);
    Game currGame = games.get(currPlayerGame);
    
    // plays one step of one player/game in the current generation
    // goes to the next game/player if the current game/player is over
    if (currGame.play(currPlayer, gen, currPlayerGame, popSize, prevGensHigh, currGenHigh, genOfPrevGensHigh)) {
      currPlayerGame += 1;
      
      if(currPlayer.score > currGenHigh)
        currGenHigh = currPlayer.score;
      
      // goes to the next generation if that was the last player of the current generation
      if (currPlayerGame == popSize) {
        calculateFitness();
        breed();
        
        if (currGenHigh > prevGensHigh) {
          prevGensHigh = currGenHigh;
          genOfPrevGensHigh = gen;
        }
        gen += 1;
        currPlayerGame = 0;
        currGenHigh = 0;
      }
    }
  }
  
  // calculates the fitness of every single player
  void calculateFitness () {
    for (Player player : players)
      player.calculateFitness();
  }
  
  // combines natural selection, crossover, and mutation
  void breed () {
    ArrayList<Player> newPlayers= new ArrayList<Player>();
    
    // directly add a clone of the best player into the next generation without crossover/mutation
    newPlayers.add(players.get(getBestPlayerIndex()).clone());
    
    // crossover and mutate the rest of the players
    for (int i = 0; i < popSize - 1; i++) {
      Player parent1 = naturalSelection();
      Player parent2 = naturalSelection();
      Player child = crossover(parent1, parent2);
      mutation(child);
      newPlayers.add(child);
    }
    
    // next generation of players and their corresponding games
    players = newPlayers;
    games = new ArrayList<Game>();
    for (int i = 0; i < popSize; i++)
      games.add(new Game());
  }
  
  // returns the index of the best performing player of the current generation
  int getBestPlayerIndex () {
    int bestIndex = 0;
    int bestFitness = players.get(0).fitness;
    for (int i = 1; i < popSize; i++)
      if (players.get(i).fitness > bestFitness) {
        bestIndex = i;
        bestFitness = players.get(i).fitness;
      }
    return bestIndex;
  }
  
  // naturally selects a Player with probability according to fitness from the current generation
  Player naturalSelection () {
    
    // uses the running sum model
    int totalFitness = 0;
    for (Player player : players)
      totalFitness += player.fitness;
    int randomVal = (int) (Math.random() * totalFitness);
    int runningSum = 0;
    for (Player player : players) {
      runningSum += player.fitness;
      if (runningSum > randomVal)
        return player;
    }
    
    // unreachable code to make the parser happy :)
    return players.get((int) (Math.random() * popSize));
  }
  
  // returns a new Player that is the crossover between two parent Players
  Player crossover (Player player1, Player player2) {
    Player child = new Player();
    child.brain = player1.brain.crossover(player2.brain);
    return child;
  }
  
  // mutates the passed in Player
  void mutation (Player playerToMutate) {
    playerToMutate.brain.mutate(mutationRate);
  }
  
}
