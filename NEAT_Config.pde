public class NEAT_Config {

    public static final int INPUTS = 12;
    public static final int OUTPUTS = 3;
    public static final int HIDDEN_NODES = 0;
    public static final int POPULATION = 1000;

    public static final float COMPATIBILITY_THRESHOLD = 10;
    public static final float EXCESS_COEFFICENT = 2;
    public static final float DISJOINT_COEFFICENT = 2;
    public static final float WEIGHT_COEFFICENT = 0.4f;

    public static final float STEPS = 0.01f;
    public static final float WEIGHT_MUTATION_CHANCE = 0.7f;
    public static final float NODE_MUTATION_CHANCE = 0.1;
    public static final float CONNECTION_MUTATION_CHANCE = 0.1f;
    public static final float BIAS_CONNECTION_MUTATION_CHANCE = 0.1f;
    public static final float WEIGHT_CHANCE = 0.25f;
    public static final float PERTURB_CHANCE = 0.75f;
    public static final float DISABLE_MUTATION_CHANCE = 0.1f;
    public static final float ENABLE_MUTATION_CHANCE = 0.1f;
    public static final float CROSSOVER_CHANCE = 0.9f;

    public static final int STALE_POOL = 20;
    public static final int STALE_SPECIES = 15;
    
}
