class Population {
    
  int popSize;
  ArrayList<Player> players;
  Game game;
  int gen = 1;
  int prevGensHigh = 0;
  int genOfPrevGensHigh = 0;
  float mutationRate = 0.1;
  
  // initializes a population of players and the game to play in
  Population (int size) {
    popSize = size;
    players = new ArrayList<Player>();
    for (int i = 0; i < popSize; i++)
      players.add(new Player());
      
    game = new Game();
  }
  
  // updates the state of the population of players
  void update () {
    
    // plays one step of all players in the current generation
    // and goes to the next generation if all players are dead
    if (game.play(players, gen, prevGensHigh, genOfPrevGensHigh, popSize)) {
      calculateFitness();
      players = breed();
      if (game.highestScore > prevGensHigh) {
        prevGensHigh = game.highestScore;
        genOfPrevGensHigh = gen;
      }
      gen += 1;
      game = new Game();
    }
  }
  
  // calculates the fitness of every player
  void calculateFitness () {
    for (Player player : players)
      player.calculateFitness();
  }
  
  // combines natural selection, crossover, and mutation
  // and returns the next generation of players
  ArrayList<Player> breed () {
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
    
    return newPlayers;
  }
  
  // returns the index of the best performing player of the current generation
  int getBestPlayerIndex () {
    int bestIndex = 0;
    float bestFitness = players.get(0).fitness;
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
    float totalFitness = 0;
    for (Player player : players)
      totalFitness += player.fitness;
    float randomVal = (float) (Math.random() * totalFitness);
    float runningSum = 0;
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
