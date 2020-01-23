import java.util.ArrayList;
AI ai;
boolean disableVillains = true;

void setup () {
  size(500, 800);
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
        for (Genome genome : population) {
            genome.getPlayer().calculateFitness();
            genome.setFitness(pow(genome.getPlayer().fitness, 2));
        }
    }
    
    public void update () {
        if (game.play(disableVillains, players, gen, prevGensHigh, genOfPrevGensHigh, NEAT_Config.POPULATION, pool.getSpecies().size())) {
            pool.evaluateFitness(this);
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
