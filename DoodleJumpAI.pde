import java.util.ArrayList;
AI ai;
boolean disableVillains = true;

void setup () {
  size(420, 640);
  background(255);
  ai = new AI();
}

void draw () {
  background(255);
  ai.update();
}

public class AI implements Environment {
    
    Game game;
    Pool pool;
    ArrayList<Player> players;
    int gen = 1;
    int prevGensHigh = 0;
    int genOfPrevGensHigh = 0;
    
    public AI () {
        game = new Game();
        pool = new Pool();
        pool.initializePool();
        players = new ArrayList<Player>();
        for (Genome genome : pool.getAllGenomes()) {
            Player toAdd = new Player(genome);
            players.add(toAdd);
            genome.setPlayer(toAdd);
        }
    }

    public void evaluateFitness (ArrayList<Genome> population) {
        
        // clean up the data first
        // adjust the ypos to make sure there are no negative y pos values
        int highestYPos = Integer.MAX_VALUE;
        int lowestYPos = Integer.MIN_VALUE;
        for (Genome genome : population) {
            if (genome.getPlayer().highestYPos < highestYPos)
                highestYPos = genome.getPlayer().highestYPos;
            if (genome.getPlayer().highestYPos > lowestYPos)
                lowestYPos = genome.getPlayer().highestYPos;
        }
        if (highestYPos < 0) {
            lowestYPos += -1.1*highestYPos;
            for (Genome genome : population)
                genome.getPlayer().highestYPos += -1.1*highestYPos;
        }
        int bar = 1;
        while (lowestYPos > 0) {
            lowestYPos /= 10;
            bar *= 10;
        }
        
        // adjust the player's highestYPos for the fitness calculation in the next block
        for (Genome genome : population)
            genome.getPlayer().highestYPos = bar - genome.getPlayer().highestYPos;
                    
        for (Genome genome : population) {
            genome.getPlayer().calculateFitness();
            genome.setFitness(genome.getPlayer().fitness);
        }
    }
    
    public void update () {
        if (game.play(disableVillains, players, gen, prevGensHigh, genOfPrevGensHigh, NEAT_Config.POPULATION, pool.getSpecies().size())) {
            pool.evaluateFitness(this);
            println(game.getFitnessStats(players));
            pool.breedNewGeneration();
            
            if (pool.getPoolStaleness() > 100) {
                background(0);
                fill(255, 255, 255);
                textAlign(CENTER, CENTER);
                textSize(80);
                text("AI IS NOT LEARNING", width/2.5, 2*height/10);
                text("Exit: [ESC]", width/2, 8*height/10);
                noLoop();
            }
            
            if (game.highestScore > prevGensHigh) {
                prevGensHigh = game.highestScore;
                genOfPrevGensHigh = gen;
            }
            
            gen += 1;
            game = new Game();
            players = new ArrayList<Player>();
            for (Genome genome : pool.getAllGenomes()) {
                Player toAdd = new Player(genome);
                players.add(toAdd);
                genome.setPlayer(toAdd);
            }
        }
    }
    
}
