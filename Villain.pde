class Villain {
  
  int xpos;
  int ypos;
  int direction;
  int speed = 2;
  final color colour = color(126, 25, 27);
  final static int len = 50;
    
  Villain (int[] coords) {
    xpos = coords[0];
    ypos = coords[1];
    int[] directions = {-1,1};
    direction = directions[int(random(2))];
  }

  void display () {
    noStroke();
    fill(colour);
    rect(xpos, ypos, len, len, 5);
    
    // move for the next frame
    if (xpos < 0 || xpos + len > width)
        direction *= -1;
    
    xpos += speed * direction;
  }
        
  void disappear () {
    xpos = 600;
    speed = 0;
  }
  
}
