import java.util.ArrayList;
AI ai;
boolean disableVillains = true;

void setup () {
  size(400, 640);
  background(255);
  ai = new AI();
}

void draw () {
  background(255);
  ai.update();
}

public class AI implements Environment {
  
    ArrayList<Player> players;
    Game game;
    int gen = 1;
    int prevGensHigh = 0;
    int genOfPrevGensHigh = 0;
    Pool pool;
    
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
        
        // adjust the ypos to make sure there are no negative y pos values
        int leastYPos = Integer.MAX_VALUE;
        for (Genome genome : population)
            if (genome.getPlayer().ypos < leastYPos)
                leastYPos = genome.getPlayer().ypos;
        if (leastYPos < 0)
            for (Genome genome : population)
                genome.getPlayer().ypos += -1*leastYPos + 10;
        
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
