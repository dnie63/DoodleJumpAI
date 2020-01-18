static class Matrix {
  
  // return a m-by-n matrix with all values being zero
  static float[][] zeros(int m, int n) {
    float[][] a = new float[m][n];
      for (int i = 0; i < m; i++)
        for (int j = 0; j < n; j++)
          a[i][j] = 0;
      return a;
  }
  
  // return a new matrix equal to a
  static float[][] copy(float[][] a) {
    int m = a.length;
    int n = a[0].length;
    float[][] copy = new float[m][n];
      for (int i = 0; i < m; i++)
        for (int j = 0; j < n; j++)
          copy[i][j] = a[i][j];
      return copy;
  }
  
  // return a new vector equal to a
  static float[] copy(float[] a) {
    int m = a.length;
    float[] copy = new float[m];
      for (int i = 0; i < m; i++)
        copy[i] = a[i];
      return copy;
  }

  // return a random m-by-n matrix with values between low and high
  static float[][] random(int m, int n, int low, int high) {
    float[][] a = new float[m][n];
    for (int i = 0; i < m; i++)
      for (int j = 0; j < n; j++)
        a[i][j] = (float) Math.random()*(high - low) + low;
    return a;
  }
  
  // return a random m-length vector with values between low and high
  static float[] random(int m, int low, int high) {
    float[] a = new float[m];
    for (int i = 0; i < m; i++)
      a[i] = (float) Math.random()*(high - low) + low;
    return a;
  }

  // return n-by-n identity matrix I
  static float[][] identity(int n) {
    float[][] a = new float[n][n];
    for (int i = 0; i < n; i++)
      a[i][i] = 1;
    return a;
  }

  // return x^T y
  static float dot(float[] x, float[] y) {
    if (x.length != y.length) throw new RuntimeException("Illegal vector dimensions.");
    float sum = 0.0;
    for (int i = 0; i < x.length; i++)
      sum += x[i] * y[i];
    return sum;
  }

  // return B = A^T
  static float[][] transpose(float[][] a) {
    int m = a.length;
    int n = a[0].length;
    float[][] b = new float[n][m];
    for (int i = 0; i < m; i++)
      for (int j = 0; j < n; j++)
        b[j][i] = a[i][j];
    return b;
  }

  // return c = a + b
  static float[][] add(float[][] a, float[][] b) {
    int m = a.length;
    int n = a[0].length;
    float[][] c = new float[m][n];
    for (int i = 0; i < m; i++)
      for (int j = 0; j < n; j++)
        c[i][j] = a[i][j] + b[i][j];
    return c;
  }
  
  static float[] add(float[] a, float[] b) {
    if (a.length != b.length) throw new RuntimeException("Illegal vector dimensions.");
    int m = a.length;
    float[] c = new float[m];
    for (int i = 0; i < m; i++)
      c[i] = a[i] + b[i];
    return c;
  }
    
  // return a new matrix with a scalar b added to it
  static float[][] add(float[][]a, float b) {
    int m = a.length;
    int n = a[0].length;
    float[][] c = new float[m][n];
    for (int i = 0; i < m; i++)
      for (int j = 0; j < n; j++)
        c[i][j] = a[i][j] + b;
    return c;
  }

  // return c = a - b
  static float[][] subtract(float[][] a, float[][] b) {
    int m = a.length;
    int n = a[0].length;
    float[][] c = new float[m][n];
    for (int i = 0; i < m; i++)
      for (int j = 0; j < n; j++)
        c[i][j] = a[i][j] - b[i][j];
    return c;
  }

  // return c = a * b
  static float[][] multiply(float[][] a, float[][] b) {
    int m1 = a.length;
    int n1 = a[0].length;
    int m2 = b.length;
    int n2 = b[0].length;
    if (n1 != m2) throw new RuntimeException("Illegal matrix dimensions.");
    float[][] c = new float[m1][n2];
    for (int i = 0; i < m1; i++)
      for (int j = 0; j < n2; j++)
        for (int k = 0; k < n1; k++)
          c[i][j] += a[i][k] * b[k][j];
    return c;
  }

  // matrix-vector multiplication (y = A * x)
  static float[] multiply(float[][] a, float[] x) {
    int m = a.length;
    int n = a[0].length;
    if (x.length != n) throw new RuntimeException("Illegal matrix dimensions.");
    float[] y = new float[m];
    for (int i = 0; i < m; i++)
      for (int j = 0; j < n; j++)
        y[i] += a[i][j] * x[j];
    return y;
  }


  // vector-matrix multiplication (y = x^T A)
  static float[] multiply(float[] x, float[][] a) {
    int m = a.length;
    int n = a[0].length;
    if (x.length != m) throw new RuntimeException("Illegal matrix dimensions.");
    float[] y = new float[n];
    for (int j = 0; j < n; j++)
      for (int i = 0; i < m; i++)
        y[j] += a[i][j] * x[i];
    return y;
  }
    
  // return a new matrix scalar multiplied by b
  static float[][] multiply(float[][] a, float b) {
    int m = a.length;
    int n = a[0].length;
    float[][] c = new float[m][n];
    for (int i = 0; i < m; i++)
      for (int j = 0; j < n; j++)
        c[i][j] = a[i][j]*b;
    return c;
  }
  
  // returns a vector whose input values have been activated (through the sigmoid function below)
  static float[] activate(float[] a) {
    int m = a.length;
    float[] b = new float[m];
    for (int i = 0; i < m; i++)
      b[i] = sigmoid(a[i]);
    return b;
  }
  
  // activation function
  static float sigmoid(float x) {
    return 1 / (1 + pow((float) Math.E, -1 * x));
  }
  
  // returns a new matrix that is the crossover between two matrices of the same size
  static float[][] crossover(float[][] a, float[][] b) {
    if (a.length != b.length || a[0].length != b[0].length) throw new RuntimeException("Illegal matrix dimensions.");
    int m = a.length;
    int n = a[0].length;
    float[][] childMatrix = new float[m][n];
    int randRow = (int) (Math.random() * m);
    int randCol = (int) (Math.random() * n);
    for (int i = 0; i < m; i++)
      for (int j = 0; j < n; j++)
        if ((i < randRow) || (i == randRow && j <= randCol))
          childMatrix[i][j] = a[i][j];
        else
          childMatrix[i][j] = b[i][j];
    return childMatrix;
  }
  
  // returns a new vector the crossover between two vectors of the same size
  static float[] crossover(float[] a, float[] b) {
    if (a.length != b.length) throw new RuntimeException("Illegal vector dimensions.");
    int m = a.length;
    float[] childVector = new float[m];
    int randInd = (int) (Math.random() * m);
    for (int i = 0; i < m; i++)
      if (i < randInd)
        childVector[i] = a[i];
      else
        childVector[i] = b[i];
    return childVector;
  }
  
  // mutates the passed in matrix with probability mutationRate
  static void mutate(float[][] a, float mutationRate) {
    if (mutationRate < 0 || mutationRate > 1) throw new RuntimeException("Illegal mutation rate.");
    int m = a.length;
    int n = a[0].length;
    for (int i = 0; i < m; i++) {
      for (int j = 0; j < n; j++) {
        float rand = (float) Math.random();
        
        // adds a random value to the specified gene if selected to be mutated
        if (rand < mutationRate) {
          a[i][j] += Math.random() * (NeuralNet.absMaxWeight * 2) - NeuralNet.absMaxWeight;
          
          //set the boundaries to NeuralNet.absMaxWeight
          if (a[i][j] > NeuralNet.absMaxWeight)
            a[i][j] = NeuralNet.absMaxWeight;
          if (a[i][j] < -1 * NeuralNet.absMaxWeight)
            a[i][j] = -1 * NeuralNet.absMaxWeight;
        }
      }
    }
  }
  
  // mutates the passed in vector with probability mutationRate
  static void mutate(float[] a, float mutationRate) {
    if (mutationRate < 0 || mutationRate > 1) throw new RuntimeException("Illegal mutation rate.");
    int m = a.length;
    for (int i = 0; i < m; i++) {
      float rand = (float) Math.random();
      
      // adds a random value to the specified gene if selected to be mutated
      if (rand < mutationRate) {
        a[i] += Math.random() * (NeuralNet.absMaxBias * 2) - NeuralNet.absMaxBias;
        
        //set the boundaries to NeuralNet.absMaxBias
        if (a[i] > NeuralNet.absMaxBias)
          a[i] = NeuralNet.absMaxBias;
        if (a[i] < -1 * NeuralNet.absMaxBias)
          a[i] = -1 * NeuralNet.absMaxBias;
      }
    }
  }
    
  // print matrix
  static void output(float[][] a) {
    int m = a.length;
    int n = a[0].length;
    for (int i = 0; i < m; i++) {
      for (int j = 0; j < n; j++)
        print(a[i][j] + " ");
      println();
    }
  }

}
