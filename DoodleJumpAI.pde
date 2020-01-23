DJ dj;

void setup () {
  size(500, 800);
  background(255);
  dj = new DJ();
}

void draw () {
  background(255);
  dj.update();
}

import java.util.ArrayList;

public class DJ implements Environment {
  
    ArrayList<Player> players;
    Game game;
    int gen = 1;
    int prevGensHigh = 0;
    int genOfPrevGensHigh = 0;
    Pool pool;
    int popSize;
    
    public DJ () {
        game = new Game();
        pool = new Pool();
        pool.initializePool();
        players = new ArrayList<Player>();
        for (Genome genome : pool.getAllGenomes()) {
            Player toAdd = new Player(genome);
            players.add(toAdd);
            genome.setPlayer(toAdd);
        }
        popSize = players.size();
    }

    public void evaluateFitness (ArrayList<Genome> population) {
        for (Genome genome : population) {
            genome.getPlayer().calculateFitness();
            genome.setFitness(genome.getPlayer().fitness);
        }
    }
    
    public void update () {
        if (game.play(players, gen, prevGensHigh, genOfPrevGensHigh, popSize)) {
            pool.evaluateFitness(dj);
            pool.breedNewGeneration();
            
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
