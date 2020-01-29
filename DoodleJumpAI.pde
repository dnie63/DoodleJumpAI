import java.util.ArrayList;
AI ai;
boolean disableVillains = false;
SecondApplet sa;
PImage notebook;

void settings() {
  size(420, 640);
}

void setup () {
  notebook = loadImage("dj_background.png");
  ai = new AI();
  
  String[] args = {"Neural Network"};
  sa = new SecondApplet();
  PApplet.runSketch(args, sa);
}

void draw () {
  background(notebook);
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
        boolean gameOver = game.play(disableVillains, players, gen, prevGensHigh, genOfPrevGensHigh, NEAT_Config.POPULATION, pool.getSpecies().size());
        sa.setHighestPlayer(game.getHighestPlayer());
        if (gameOver) {
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

public class SecondApplet extends PApplet {
  
  Player highestPlayer;
  int width2 = 500;
  int height2 = 500;
  
  public void settings() {
    size(width2, height2);
  }

  // display the neural network
  public void draw() {
    background(255);
    
    if (highestPlayer != null) {
      if (highestPlayer.brain != null) {
        Genome genomeToDisplay = new Genome(highestPlayer.brain);
        int lastMoveToDisplay = highestPlayer.lastMoveNeuralDisplay;
        genomeToDisplay.generateNetwork();
        TreeMap<Integer, NodeGene> nodes = genomeToDisplay.getNodes();
        ArrayList<ConnectionGene> connectionGeneList = genomeToDisplay.getConnectionGeneList();
        TreeMap<Integer, int[]> nodesAndPos = new TreeMap<Integer, int[]>();
        
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
          text(i, x, y+7);
          
          int[] loc = {x,y};
          nodesAndPos.put(i, loc);
          y += (height2 - 80)/(NEAT_Config.INPUTS);
        }
        
        // display the output layer
        x = width2 - 40;
        y = 80;
        for (int i = NEAT_Config.INPUTS + NEAT_Config.HIDDEN_NODES + 1; i < NEAT_Config.INPUTS + NEAT_Config.HIDDEN_NODES + NEAT_Config.OUTPUTS + 1; i++) {
          if (lastMoveToDisplay == -1)
            fill(255,40,0);
          else
            fill(255,255,255);
          stroke(0,0,0);
          strokeWeight(2);
          ellipse(x,y,40,40);
          
          textAlign(CENTER);
          fill(0, 0, 0);
          textSize(20);
          text(i, x, y+7);
          
          int[] loc = {x,y};
          nodesAndPos.put(i, loc);
          y += (height2 - 160)/(NEAT_Config.OUTPUTS - 1);
          lastMoveToDisplay -= 1;
        }
        
        // display the hidden layer
        int index = 0;
        int[] xvals = {width2 - 140, width2 - 280};
        y = 40;
        for (int i = NEAT_Config.INPUTS + 1; i < NEAT_Config.INPUTS + NEAT_Config.HIDDEN_NODES + 1; i++) {
          if (nodes.containsKey(i)) {
            x = xvals[index];
            
            fill(255,255,255);
            stroke(0,0,0);
            strokeWeight(2);
            ellipse(x,y,40,40);
            
            textAlign(CENTER);
            fill(0, 0, 0);
            textSize(20);
            text(i, x, y+7);
            
            int[] loc = {x,y};
            nodesAndPos.put(i, loc);
            index = (index+1)%2;
            if (nodes.size() - (NEAT_Config.INPUTS + NEAT_Config.OUTPUTS + 1) - 1 > 0)
              y += (height2 - 80)/(nodes.size() - (NEAT_Config.INPUTS + NEAT_Config.OUTPUTS + 1) - 1);
          }
        }
        
        // display the connections
        for (ConnectionGene conGene : connectionGeneList) {
          int[] intoLoc = nodesAndPos.get(conGene.getInto());
          int[] outLoc = nodesAndPos.get(conGene.getOut());
          
          // fixes this really random bug that only happens like once every 20 generations where nodes is randomly empty and so outLoc becomes null
          // and results in a NullPointerException (unless there is a legitimate bug somewhere in the code that I can't find after hours of looking)
          if (!(intoLoc == null || outLoc == null)) {
            int x1 = intoLoc[0];
            int y1 = intoLoc[1];
            int x2 = outLoc[0];
            int y2 = outLoc[1];
            stroke(0,0,0);
            strokeWeight(2);
            line(x1 + 20, y1, x2 - 20, y2);
            textSize(20);
            textAlign(CENTER);
            text(conGene.getWeight(), (x1 + x2)/2, (y1 + y2)/2);
          }
        }
      }
    }
  }
  
  public void setHighestPlayer(Player player) {
    highestPlayer = player;
  }
  
}
