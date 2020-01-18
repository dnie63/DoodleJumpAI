Population pop;

void setup () {
  size(500, 800);
  background(255);
  frameRate(120);
  pop = new Population(1000);
}

void draw () {
  background(255);
  pop.update();
}
