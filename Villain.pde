class Villain {
  
  PImage pic;
  int xpos;
  int ypos;
  int direction;
  int speed;
  final color colour = color(126, 25, 27);
  final static int villWidth = 90;
  final static int villHeight = 60;
    
  Villain (int[] coords, PImage pic, int speed) {
    xpos = coords[0];
    ypos = coords[1];
    int[] directions = {-1,1};
    direction = directions[int(random(2))];
    this.pic = pic;
    this.speed = speed;
  }

  void display () {
    image(pic, xpos, ypos);
    
    // move for the next frame
    if (xpos < 0 || xpos + villWidth > width)
        direction *= -1;
    
    xpos += speed * direction;
  }
  
}
