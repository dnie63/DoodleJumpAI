class Platform implements Comparable {
  
  int xpos;
  int ypos;
  int speed;                          // moving_platform = 2
  int direction;
  color colour;                       // green color(144, 238, 144)
  int will_disappear = 0;     // blue color(107, 202, 226)
  final static int thiccness = 16;
  final static int len = 75;
    
  Platform (int[] coords, int score, color colour, int[] directions, int speed) {
    xpos = coords[0];
    ypos = coords[1];
    direction = directions[int(random(2))];
    this.speed = speed;
    this.colour = colour;
    
    // adds in disappearing platforms once score is >= 3000 (black is nonmoving, purple is moving)
    /*if (score >= 3000)
      if (random(100) >= 80) {
        will_disappear = 1;
        this.colour = color(255, 255, 255);
      }*/
  }
        
  void display () {
    strokeWeight(thiccness);
    stroke(colour);
    line(xpos, ypos, xpos + len, ypos);
        
    // move for the next frame
    if (xpos < 7 || xpos + len > width - 7)
      direction *= -1;
        
    xpos += speed * direction;
  }
  
  @Override
  public int compareTo(Object o) {
      Platform g = (Platform)o;
      if (ypos == g.ypos)
          return 0;
      else if(ypos < g.ypos)
          return 1;
      else
          return -1;
  }
  
}
