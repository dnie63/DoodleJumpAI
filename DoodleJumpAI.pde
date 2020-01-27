import java.util.ArrayList;
AI ai;
boolean disableVillains = true;
SecondApplet sa;

void settings() {
  size(420, 640);
}

void setup () {
  background(255);
  ai = new AI();
  
  String[] args = {"Neural Network"};
  sa = new SecondApplet();
  PApplet.runSketch(args, sa);
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
            genome.getPlayer().calculateFitness(bar);
            genome.setFitness(genome.getPlayer().fitness);
        }
    }
    
    public void update () {
        if (game.play(disableVillains, players, gen, prevGensHigh, genOfPrevGensHigh, NEAT_Config.POPULATION, pool.getSpecies().size())) {
            pool.evaluateFitness(this);
            sa.setTopGenome(new Genome(pool.getTopGenome()));
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

public class SecondApplet extends PApplet {
  
  Genome topGenomeFromPrevGen = null;
  int width2 = 420;
  int height2 = 420;
  
  public void settings() {
    size(width2, height2);
  }

  // display the neural network
  public void draw() {
    background(255);
    
    if (topGenomeFromPrevGen != null) {
      topGenomeFromPrevGen.generateNetwork();
      
      // display the input layer plus the bias
      int x = 40;
      int y = 40;
      for (int i = 0; i < NEAT_Config.INPUTS + 1; i++) {
        fill(255,255,255);
        stroke(0,0,0);
        strokeWeight(2);
        ellipse(x,y,40,40);
        
        textAlign(CENTER);
        fill(0, 0, 0);
        textSize(20);
        text(str(i+1), x, y+7);
        
        y += (height2 - 80)/(NEAT_Config.INPUTS);
      }
      
      // display the output layer
      x = width2 - 40;
      y = 80;
      for (int i = NEAT_Config.INPUTS + NEAT_Config.HIDDEN_NODES + 1; i < NEAT_Config.INPUTS + NEAT_Config.HIDDEN_NODES + NEAT_Config.OUTPUTS + 1; i++) {
        fill(255,255,255);
        stroke(0,0,0);
        strokeWeight(2);
        ellipse(x,y,40,40);
        
        textAlign(CENTER);
        fill(0, 0, 0);
        textSize(20);
        text(str(i+1), x, y+7);
        
        y += (height2 - 160)/(NEAT_Config.OUTPUTS - 1);
      }
      
      // display the hidden layer
    }
  }
  
  public void setTopGenome(Genome genome) {
    topGenomeFromPrevGen = genome;
  }
  
}
