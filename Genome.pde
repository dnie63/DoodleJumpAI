import javax.management.RuntimeErrorException;
import java.io.*;
import java.util.*;

public class Genome implements Comparable {
    
    private Player player;
    private Random rand = new Random();
    private float fitness;                                                                            // Global Percentile Rank (higher the better)
    private ArrayList<ConnectionGene> connectionGeneList = new ArrayList<ConnectionGene>();           // DNA- MAin archive of gene information
    private TreeMap<Integer, NodeGene> nodes = new TreeMap<Integer, NodeGene>();                      // Generated while performing network operation
    private float adjustedFitness;                                                                    // For number of child to breed in species
    private HashMap<MutationKeys, Float> mutationRates = new HashMap<MutationKeys, Float>();

    public Genome(){
        this.mutationRates.put(MutationKeys.STEPS, NEAT_Config.STEPS);
        this.mutationRates.put(MutationKeys.PERTURB_CHANCE, NEAT_Config.PERTURB_CHANCE);
        this.mutationRates.put(MutationKeys.WEIGHT_CHANCE,NEAT_Config.WEIGHT_CHANCE);
        this.mutationRates.put(MutationKeys.WEIGHT_MUTATION_CHANCE, NEAT_Config.WEIGHT_MUTATION_CHANCE);
        this.mutationRates.put(MutationKeys.NODE_MUTATION_CHANCE , NEAT_Config.NODE_MUTATION_CHANCE);
        this.mutationRates.put(MutationKeys.CONNECTION_MUTATION_CHANCE , NEAT_Config.CONNECTION_MUTATION_CHANCE);
        this.mutationRates.put(MutationKeys.BIAS_CONNECTION_MUTATION_CHANCE , NEAT_Config.BIAS_CONNECTION_MUTATION_CHANCE);
        this.mutationRates.put(MutationKeys.DISABLE_MUTATION_CHANCE , NEAT_Config.DISABLE_MUTATION_CHANCE);
        this.mutationRates.put(MutationKeys.ENABLE_MUTATION_CHANCE , NEAT_Config.ENABLE_MUTATION_CHANCE);
    }

    public Genome(Genome child) {
        for (ConnectionGene c:child.connectionGeneList)
            this.connectionGeneList.add(new ConnectionGene(c));

        this.fitness = child.fitness;
        this.adjustedFitness = child.adjustedFitness;

        this.mutationRates = (HashMap<MutationKeys, Float>) child.mutationRates.clone();
    }
    
    public TreeMap<Integer, NodeGene> getNodes() {
      return nodes;
    }

    public void setPlayer (Player player) {
        this.player = player;
    }
    
    public Player getPlayer () {
        return player;
    }

    public float getFitness() {
        return fitness;
    }

    public void setFitness(float fitness) {
        this.fitness = fitness;
    }

    public void setConnectionGeneList(ArrayList<ConnectionGene> connectionGeneList) {
        this.connectionGeneList = connectionGeneList;
    }
    
    public ArrayList<ConnectionGene> getConnectionGeneList() {
        return connectionGeneList;
    }

    public Genome crossOver(Genome parent2){
        Genome parent1 = this;
        
        if(parent1.fitness < parent2.fitness){
            Genome temp = parent1;
            parent1 = parent2;
            parent2 = temp;
        }

        Genome child = new Genome();
        TreeMap<Integer, ConnectionGene> geneMap1 = new TreeMap<Integer, ConnectionGene>();
        TreeMap<Integer, ConnectionGene> geneMap2 = new TreeMap<Integer, ConnectionGene>();

        for(ConnectionGene con: parent1.connectionGeneList){
            //assert  !geneMap1.containsKey(con.getInnovation());             //TODO Remove for better performance
            geneMap1.put(con.getInnovation(), con);
        }

        for(ConnectionGene con: parent2.connectionGeneList){
            //assert  !geneMap2.containsKey(con.getInnovation());             //TODO Remove for better performance
            geneMap2.put(con.getInnovation(), con);
        }

        Set<Integer> innovationP1 = geneMap1.keySet();
        Set<Integer> innovationP2 = geneMap2.keySet();

        Set<Integer> allInnovations = new HashSet<Integer>(innovationP1);
        allInnovations.addAll(innovationP2);

        for(int key : allInnovations){
            ConnectionGene trait;

            if(geneMap1.containsKey(key) && geneMap2.containsKey(key)) {
                if(rand.nextBoolean()){
                    trait = new ConnectionGene(geneMap1.get(key));
                } else {
                    trait = new ConnectionGene(geneMap2.get(key));
                }

                if((geneMap1.get(key).isEnabled()!=geneMap2.get(key).isEnabled())) {
                    if( (rand.nextFloat()<0.75f ))
                        trait.setEnabled(false);
                    else
                        trait.setEnabled(true);
                }

            } else if(parent1.getFitness()==parent2.getFitness()) {               // disjoint or excess and equal fitness
                if(geneMap1.containsKey(key))
                    trait = geneMap1.get(key);
                else
                    trait = geneMap2.get(key);

                if(rand.nextBoolean()){
                    continue;
                }

            } else
                trait = geneMap1.get(key);

            child.connectionGeneList.add(trait);
        }

        return child;
    }

    public boolean isSameSpecies(Genome g2){
        Genome g1 = this;
        TreeMap<Integer, ConnectionGene> geneMap1 = new TreeMap<Integer, ConnectionGene>();
        TreeMap<Integer, ConnectionGene> geneMap2 = new TreeMap<Integer, ConnectionGene>();

        int matching = 0;
        int disjoint = 0;
        int excess = 0;
        float weight = 0;
        int lowMaxInnovation;
        float delta = 0;

        for(ConnectionGene con: g1.connectionGeneList) {
            //assert  !geneMap1.containsKey(con.getInnovation());             //TODO Remove for better performance
            geneMap1.put(con.getInnovation(), con);
        }

        for(ConnectionGene con: g2.connectionGeneList) {
            //assert  !geneMap2.containsKey(con.getInnovation());             //TODO Remove for better performance
            geneMap2.put(con.getInnovation(), con);
        }
        if(geneMap1.isEmpty() || geneMap2.isEmpty())
            lowMaxInnovation = 0;
        else
            lowMaxInnovation = Math.min(geneMap1.lastKey(),geneMap2.lastKey());

        Set<Integer> innovationP1 = geneMap1.keySet();
        Set<Integer> innovationP2 = geneMap2.keySet();

        Set<Integer> allInnovations = new HashSet<Integer>(innovationP1);
        allInnovations.addAll(innovationP2);

        for(int key : allInnovations){

            if(geneMap1.containsKey(key) && geneMap2.containsKey(key)){
                matching ++;
                weight += Math.abs(geneMap1.get(key).getWeight() - geneMap2.get(key).getWeight());
            }else {
                if(key < lowMaxInnovation){
                    disjoint++;
                }else{
                    excess++;
                }
            }
        }

        int N = matching+disjoint+excess ;
        if (N > 0)
            delta = (NEAT_Config.EXCESS_COEFFICENT * excess + NEAT_Config.DISJOINT_COEFFICENT * disjoint) / N + (NEAT_Config.WEIGHT_COEFFICENT * weight) / matching;

        return delta < NEAT_Config.COMPATIBILITY_THRESHOLD;
    }

    private void generateNetwork() {
        nodes.clear();
        
        //  Input layer
        for (int i = 0; i < NEAT_Config.INPUTS; i++) {
            nodes.put(i, new NodeGene(0));                    //Inputs
        }
        nodes.put(NEAT_Config.INPUTS, new NodeGene(1));        // Bias

        //output layer
        for (int i = NEAT_Config.INPUTS + NEAT_Config.HIDDEN_NODES + 1; i < NEAT_Config.INPUTS + NEAT_Config.HIDDEN_NODES + NEAT_Config.OUTPUTS + 1; i++) {
            nodes.put(i, new NodeGene(0));
        }

        // hidden layer
        for (ConnectionGene con : connectionGeneList) {
            if (!nodes.containsKey(con.getInto()))
                nodes.put(con.getInto(), new NodeGene(0));
            if (!nodes.containsKey(con.getOut()))
                nodes.put(con.getOut(), new NodeGene(0));
            nodes.get(con.getOut()).getIncomingCon().add(con);
        }
    }

    public float[] evaluateNetwork(float[] inputs) {
        float output[] = new float[NEAT_Config.OUTPUTS];
        generateNetwork();

        for (int i = 0; i < NEAT_Config.INPUTS; i++) {
            nodes.get(i).setValue(inputs[i]);
        }

        for (Map.Entry<Integer, NodeGene> mapEntry : nodes.entrySet()) {
            float sum = 0;
            int key = mapEntry.getKey();
            NodeGene node = mapEntry.getValue();

            if (key > NEAT_Config.INPUTS) {
                for (ConnectionGene conn : node.getIncomingCon()) {
                    if (conn.isEnabled()) {
                        sum += nodes.get(conn.getInto()).getValue() * conn.getWeight();
                    }
                }
                node.setValue(sigmoid(sum));
            }
        }

        for (int i = 0; i < NEAT_Config.OUTPUTS; i++)
            output[i] = nodes.get(NEAT_Config.INPUTS + NEAT_Config.HIDDEN_NODES + i + 1).getValue();
        
        return output;
    }

    private float sigmoid(float x) {
        return (float) (1 / (1 + Math.exp(-4.9 * x)));
    }

    // Mutations --------------------------------------------------------------------------------------------

    public void Mutate() {
        generateNetwork();
        /*
        for (Map.Entry<MutationKeys, Float> entry : mutationRates.entrySet())
            if(rand.nextBoolean())
                mutationRates.put(entry.getKey(), 0.95f * entry.getValue() );
            else
                mutationRates.put(entry.getKey(), 1.05263f * entry.getValue() );*/

        if (rand.nextFloat() <= mutationRates.get(MutationKeys.WEIGHT_MUTATION_CHANCE))
            mutateWeight();
        if (rand.nextFloat() <= mutationRates.get(MutationKeys.CONNECTION_MUTATION_CHANCE))
            mutateAddConnection(false);
        if (rand.nextFloat() <= mutationRates.get(MutationKeys.BIAS_CONNECTION_MUTATION_CHANCE))
            mutateAddConnection(true);
        if (rand.nextFloat() <= mutationRates.get(MutationKeys.NODE_MUTATION_CHANCE) && nodes.size() - NEAT_Config.INPUTS - NEAT_Config.OUTPUTS - 1 < NEAT_Config.HIDDEN_NODES)
            mutateAddNode();
        if (rand.nextFloat() <= mutationRates.get(MutationKeys.DISABLE_MUTATION_CHANCE))
            disableMutate();
        if (rand.nextFloat() <= mutationRates.get(MutationKeys.ENABLE_MUTATION_CHANCE))
            enableMutate();
    }

    void mutateWeight() {
        for (ConnectionGene c : connectionGeneList) {
            if (rand.nextFloat() < NEAT_Config.WEIGHT_CHANCE) {
                if (rand.nextFloat() < NEAT_Config.PERTURB_CHANCE) {
                    c.setWeight(c.getWeight() + (2 * rand.nextFloat() - 1) * NEAT_Config.STEPS);
                    if (c.getWeight() > 1)
                      c.setWeight(1);
                    else if (c.getWeight() < -1)
                      c.setWeight(-1);
                } else {
                  c.setWeight(2 * rand.nextFloat() - 1);
                }
            }
        }
    }

    void mutateAddConnection(boolean forceBias) {
        
        // original code
        /*int i = 0;
        int j = 0;
        int random2 = rand.nextInt(nodes.size() - NEAT_Config.INPUTS - 1) + NEAT_Config.INPUTS + 1;
        int random1 = rand.nextInt(nodes.size());
        if(forceBias)
            random1 = NEAT_Config.INPUTS;
        int node1 = -1;
        int node2 = -1;

        for (int k : nodes.keySet()) {
            if (random1 == i) {
                node1 = k;
                break;
            }
            i++;
        }

        for (int k : nodes.keySet()) {
            if (random2 == j) {
                node2 = k;
                break;
            }
            j++;
        }

        if (node1 >= node2)
            return;

        for (ConnectionGene con : nodes.get(node2).getIncomingCon()) {
            if (con.getInto() == node1)
                return;
        }

        if (node1 < 0 || node2 < 0)
            throw new RuntimeErrorException(null);          // TODO Pool.newInnovation(node1, node2)*/
        
        // my own code
        int numNodes = nodes.size();
        int node1 = rand.nextInt(numNodes - NEAT_Config.OUTPUTS);
        int node2 = rand.nextInt(numNodes - NEAT_Config.INPUTS - 1) + NEAT_Config.INPUTS + NEAT_Config.HIDDEN_NODES + 1 - (numNodes - 1 - NEAT_Config.INPUTS - NEAT_Config.OUTPUTS);
        if (forceBias)
            node1 = NEAT_Config.INPUTS;
        NodeGene actualNode2 = nodes.get(node2);
        if (!(actualNode2 == null)) {
            for (ConnectionGene connection : actualNode2.getIncomingCon())
                if (connection.getInto() == node1)
                    return;
            connectionGeneList.add(new ConnectionGene(node1, node2, InnovationCounter.newInnovation(), 4 * rand.nextFloat() - 2, true));                // Add innovation and weight
        }
    }

    void mutateAddNode() {
        if (connectionGeneList.size() > 0 && nodes.size() < NEAT_Config.INPUTS + NEAT_Config.HIDDEN_NODES + NEAT_Config.OUTPUTS + 1) {
            int timeoutCount = 0;
            ConnectionGene randomCon = connectionGeneList.get(rand.nextInt(connectionGeneList.size()));
            while (!randomCon.isEnabled()) {
                randomCon = connectionGeneList.get(rand.nextInt(connectionGeneList.size()));
                timeoutCount++;
                if (timeoutCount > NEAT_Config.HIDDEN_NODES)
                    return;
            }
            // counts down from the node number that is one below the first output node
            int nextNode = NEAT_Config.INPUTS + NEAT_Config.HIDDEN_NODES - (nodes.size() - 1 - NEAT_Config.INPUTS - NEAT_Config.OUTPUTS);
            randomCon.setEnabled(false);
            connectionGeneList.add(new ConnectionGene(randomCon.getInto(), nextNode, InnovationCounter.newInnovation(), 1, true));        // Add innovation and weight
            connectionGeneList.add(new ConnectionGene(nextNode, randomCon.getOut(), InnovationCounter.newInnovation(), randomCon.getWeight(), true));
        }
    }
    void disableMutate() {
         if (connectionGeneList.size() > 0) {
            ConnectionGene randomCon = connectionGeneList.get(rand.nextInt(connectionGeneList.size()));
            randomCon.setEnabled(false);
        }
    }

    void enableMutate() {
        if (connectionGeneList.size() > 0) {
            ConnectionGene randomCon = connectionGeneList.get(rand.nextInt(connectionGeneList.size()));
            randomCon.setEnabled(true);
        }
    }

    @Override
    public int compareTo(Object o) {
        Genome g = (Genome)o;
        if (fitness==g.fitness)
            return 0;
        else if(fitness >g.fitness)
            return 1;
        else
            return -1;
    }

    @Override
    public String toString() {
        return "Genome{" +
                "fitness=" + fitness +
                ", connectionGeneList=" + connectionGeneList +
                ", nodeGenes=" + nodes +
                '}';
    }

    public void setAdjustedFitness(float adjustedFitness) {
        this.adjustedFitness = adjustedFitness;
    }

    public float getAdjustedFitness() {
        return adjustedFitness;
    }

}
