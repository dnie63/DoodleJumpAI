import java.util.ArrayList;
import java.util.Collections;

public class Pool {

    private ArrayList<Species> species = new ArrayList<Species>();
    private float topFitness = 0;
    private int poolStaleness = 0;

    public ArrayList<Species> getSpecies() {
        return species;
    }

    public void initializePool() {
        for (int i = 0; i < NEAT_Config.POPULATION; i++)
            addToSpecies(new Genome());
    }

    public void addToSpecies(Genome g) {
        for (Species s : species) {
            if (s.getGenomes().size() == 0)
                continue;
            Genome g0 = s.getGenomes().get(0);
            if (g.isSameSpecies(g0)) {
                s.getGenomes().add(g);
                return;
            }
        }
        Species childSpecies = new Species();
        childSpecies.getGenomes().add(g);
        species.add(childSpecies);
    }

    public void evaluateFitness(Environment environment){
        environment.evaluateFitness(getAllGenomes());
    }

    public Genome getTopGenome(){
        ArrayList<Genome> allGenome = getAllGenomes();
        Collections.sort(allGenome,Collections.reverseOrder());
        return allGenome.get(0);
    }

    public void removeWeakGenomesFromSpecies(boolean allButOne){
        for(Species s : species)
            s.removeWeakGenomes(allButOne);
    }

    public void removeStaleSpecies(){
        ArrayList<Species> survived = new ArrayList<Species>();

        if(topFitness < getTopFitness())
            poolStaleness = 0;

        // I'm pretty sure this if statement will never run because it is redundant
        // Never mind, all this logic is correct but its just that the implementation of getTopFitness() in the Species class was redundant (I changed it to be correct now though)
        for(Species s : species){
            Genome top = s.getTopGenome();
            
            // if the species' current top fitness is greater than the species' prevoius top fitness...
            if(top.getFitness() > s.getTopFitness()) {
                s.setTopFitness(top.getFitness());
                s.setStaleness(0);
            } else
                s.setStaleness(s.getStaleness()+1);     // increment staleness

            if(s.getStaleness() < NEAT_Config.STALE_SPECIES || s.getTopFitness() >= this.getTopFitness())
                survived.add(s);
        }
        

        Collections.sort(survived,Collections.reverseOrder());

        // if the entire pool is stale (not improving), remove half of all remaining species
        if(poolStaleness >= NEAT_Config.STALE_POOL)
            for(int i = survived.size() - 1; i > (int) survived.size()/2 - 1 ;i--)
                survived.remove(i);

        species = survived;
        poolStaleness++;
    }

    public void calculateGenomeAdjustedFitness(){
        for (Species s: species)
            s.calculateGenomeAdjustedFitness();
    }
    
    // all species must have the totalAdjustedFitness calculated
    public float calculateGlobalAdjustedFitness() {
        float total = 0;
        for (Species s : species) {
            total += s.getTotalAdjustedFitness();
        }
        return total;
    }
    
    public ArrayList<Genome> breedNewGeneration() {
        calculateGenomeAdjustedFitness();
        ArrayList<Species> survived = new ArrayList<Species>();
        removeWeakGenomesFromSpecies(false);
        removeStaleSpecies();
        float globalAdjustedFitness = calculateGlobalAdjustedFitness();
        ArrayList<Genome> children = new ArrayList<Genome>();
        for (Species s : species) {
            float fchild = NEAT_Config.POPULATION * (s.getTotalAdjustedFitness() / globalAdjustedFitness);
            int nchild = (int) fchild;

            if(nchild < 1)
                continue;

            // makes a new species for the top genome in each species
            survived.add(new Species(new Genome(s.getTopGenome())));

            for (int i = 1; i < nchild; i++)
                children.add(s.breedChild());
        }
        
        // adds all the bred and mutated children into the predefined species
        species = survived;
        for (Genome child: children)
            addToSpecies(child);
            
        cleanup();
        
        return children;
    }
    
    // makes sure that all weights are within the bound [-1,1]
    // (I checked all over the code, this shouldn't be an issue in the first place, but I guess it is)
    void cleanup() {      
      for (Genome genome : getAllGenomes())
        for (ConnectionGene conGene : genome.getConnectionGeneList())
          if (conGene.getWeight() > 1)
            conGene.setWeight(1);
          else if (conGene.getWeight() < -1)
            conGene.setWeight(-1);
    }

    public float getTopFitness(){
        float topFitness = 0;
        Genome topGenome =null;
        for(Species s : species) {
            topGenome = s.getTopGenome();
            
            if (topGenome.getFitness() > topFitness)
                topFitness = topGenome.getFitness();
        }
        return topFitness;
    }

    public int getCurrentPopulation() {
        int p = 0;
        for (Species s : species)
            p += s.getGenomes().size();
        return p;
    }
    
    public ArrayList<Genome> getAllGenomes () {
        ArrayList<Genome> allGenomes = new ArrayList<Genome>();
      
        for (Species s : species)
            for (Genome g : s.getGenomes())
                allGenomes.add(g);
                
        return allGenomes;
    }

    public int getPoolStaleness () {
        return poolStaleness;
    }

}
