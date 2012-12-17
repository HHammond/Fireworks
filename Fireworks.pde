/*
This sketch generates 3d fireworks.
Pressing spacebar hides the interface to create a screensaver mode.

The program uses some 3d math and physics and uses a particle system
for rendering the fireworks.

Note: in the latest Processing update antialiasing has changed,
as a result the fireworks are not as intense as they previously were

Created by Henry Hammond 2012
*/


import processing.opengl.*;

//initial parameters
float ParticleLife = 1.5;
float GRAV = 5;
int maxFireworks = 12;
int PS = 25;
int PathLength = 6;
int sparks = 10;

//application's global variables and initial settings
Emitter e;
boolean rotation = true;
boolean mouseRotate = false;

boolean controlLock = false;

float resistance = 1;
float rotationSpeed = 0.2;
float zrotationSpeed = 0.2;
float zoom = 0;
HScrollbar lifebar, gravbar, pathbar, psbar, fbar, rbar, rotbar, rotzbar, zbar, sbar;

ArrayList <Firework> fireworks;

boolean hidden = false;

//this vector defines the 3d coordinates of the screen
PVector dimension;
PVector dimensionOffset;

void setup() {
  //render to OpenGL context for better 3d performance
  size(displayWidth, displayHeight, OPENGL);
  noStroke();
  smooth();
  fill(150);

  //initialize display and 3d variables
  int depth = min(height, width);
  //int depth = 500;
  dimension = new PVector(depth, depth, depth);
  dimensionOffset = new PVector((width-depth)/2, (height-depth)/2, -depth);
  
  //init arraylist containing particles
  fireworks = new ArrayList();
  
  //create display interface elements
  int spacing = 20;
  int j = 20;
  lifebar = new HScrollbar(20, j+=spacing, 200, 10, 1);
  gravbar = new HScrollbar(20, j+=spacing, 200, 10, 1);
  pathbar = new HScrollbar(20, j+=spacing, 200, 10, 1);
  psbar   = new HScrollbar(20, j+=spacing, 200, 10, 1);
  sbar    = new HScrollbar(20, j+=spacing, 200, 10, 1);
  fbar    = new HScrollbar(20, j+=spacing, 200, 10, 1);
  rbar    = new HScrollbar(20, j+=spacing, 200, 10, 1);
  rotbar  = new HScrollbar(20, j+=spacing, 200, 10, 1);
  rotzbar = new HScrollbar(20, j+=spacing, 200, 10, 1);
  zbar    = new HScrollbar(20, j+=spacing, 200, 10, 1);

  //set initial scrollbar settings
  lifebar.setPos(0.25);
  gravbar.setPos(0.4);
  pathbar.setPos(0.1);
  psbar.setPos(0.70);
  fbar.setPos(0.2);
  rbar.setPos(0.9);
  rotbar.setPos(0.49);
  zbar.setPos(0.5);
  sbar.setPos(0.1);
  rotzbar.setPos(0.49);


  //gravbar,pathbar,psbar;
}

//these variables store current 3d location information
float r = 0;
float rz = 0;
void draw() {

  //increment the rotation
  r+=rotationSpeed/frameRate;
  rz+=zrotationSpeed/frameRate;
  background(0);
  
  //update gui elements if not hidden
  if (!hidden) {
    lifebar.update();
    lifebar.display();
    gravbar.update();
    gravbar.display();
    pathbar.update();
    pathbar.display();
    psbar.update();
    psbar.display();
    fbar.update();
    fbar.display();
    rbar.update();
    rbar.display();
    rotbar.update();
    rotbar.display();
    rotzbar.update();
    rotzbar.display();
    zbar.update();
    zbar.display();
    sbar.update();
    sbar.display();

    //update text from scrollbar values and set variables to values
    stroke(255);
    fill(255);
    textMode(LEFT);
    int textOffset = 10;
    ParticleLife = lifebar.getPcnt()*10;
    text("Life: "+ParticleLife, lifebar.xpos+lifebar.swidth+10, lifebar.ypos+textOffset);
    GRAV = gravbar.getPcnt()*10;
    text("Grav: "+GRAV, gravbar.xpos+gravbar.swidth+10, gravbar.ypos+textOffset);
    PathLength = (int)(pathbar.getPcnt()*100);
    text("Path: "+PathLength, pathbar.xpos+pathbar.swidth+10, pathbar.ypos+textOffset);
    PS = (int)((1-psbar.getPcnt())*100)+10;
    text("Degree/Particle: "+PS, psbar.xpos+psbar.swidth+10, psbar.ypos+textOffset);
    maxFireworks = (int)(fbar.getPcnt()*50);
    text("Fireworks: "+maxFireworks, fbar.xpos+fbar.swidth+10, fbar.ypos+textOffset);
    resistance = rbar.getPcnt()/2+0.5;
    text("Resistance: "+resistance, rbar.xpos+rbar.swidth+10, rbar.ypos+textOffset);
    
    if( 0.49 <= rotbar.getPcnt() && 0.51 >= rotbar.getPcnt()){
      rotationSpeed = 0;
    } else {
      rotationSpeed = (0.5-rotbar.getPcnt())*PI;
    }
    text("Rotation speed", rotbar.xpos+rotbar.swidth+10, rotbar.ypos+textOffset);
    
    if( 0.49 <= rotzbar.getPcnt() && 0.51 >= rotzbar.getPcnt()){
      zrotationSpeed = 0;
    } else {
      zrotationSpeed = (0.5-rotzbar.getPcnt())*PI;
    }
    text("Elevation Speed", rotzbar.xpos+rotzbar.swidth+10, rotzbar.ypos+textOffset);
    zoom = 2000*(1-zbar.getPcnt())-dimension.z;
    text("Zoom", zbar.xpos+zbar.swidth+10, zbar.ypos+textOffset);
    sparks = (int)(100*sbar.getPcnt());
    text("Sparks"+sparks, sbar.xpos+sbar.swidth+10, sbar.ypos+textOffset);


    cursor();
  }
  else {
    noCursor();
  }

  //apply translation to screen
  translate(dimensionOffset.x, dimensionOffset.y, dimensionOffset.z-zoom);
  if (rotation) {

    PVector t = new PVector(0, 0, 0);
    t.x = dimension.x/2;
    t.y = 0;
    t.z = dimension.z/2;
    translate(t.x, t.y, t.z);
  
    //if mouse is on, use mouse for rotation location
    if (mouseRotate) {
      rotateY(mouseX*1.0/width*TWO_PI);
    }
    //else use standard rotation
    else {
      rotateX(rz);
      rotateY(r);
    }
    //translate(0,0,0);
    translate(-t.x, -t.y, -t.z);
  }

  if (!hidden) {
    //draw square around firework area
    pushMatrix();
    translate(0, 0, 0);
    strokeWeight(1);
    stroke(255, 100);
    PVector d = dimension.get();
    line( 0, d.y, 0, d.x, d.y, 0);
    line( d.x, d.y, 0, d.x, d.y, d.z);
    line( d.x, d.y, d.z, 0, d.y, d.z);
    line( 0, d.y, d.z, 0, d.y, 0);
    popMatrix();
  }
  for (int i=0;i<fireworks.size();i++) {
  
    //draw and update fireworks, removing old ones
    Firework f = fireworks.get(i);
    f.draw();
    if (f.dead) {
      fireworks.remove(i);
    }
  }
  
  //launch new fireworks if space is available
  if (fireworks.size() < maxFireworks && random(0, 7) > 5) {
    PVector l = new PVector(random(0, 1)*dimension.x, dimension.y, random(0, 1)*dimension.z);
    PVector v = new PVector(random(-3, 3), -1*random(6, 14), random(-3, 3));
    fireworks.add(new Firework(l, v, random(0.5, 2)));
  }
  fill(255);
}

//for testing, emit fireworks on click
void mousePressed() {
  //e.emit();
}

//hide interface elements on space
void keyPressed() {
  if (key == ' ') {
    hidden = !hidden;
  }
}

//particle class
public class Particle {
  PVector pos;
  PVector vel;
  float age;
  float maxAge;
  float mass;

  public Particle(PVector pos, PVector vel, float maxAge) {
    this.pos = pos;
    this.vel = vel;
    this.maxAge = maxAge;
  }

  public void draw() {
    stroke(255);
    strokeWeight(1);
    noStroke();
    fill(255);

    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    ellipse(0, 0, 2, 2);
    popMatrix();
  }

  public void act() {
    pos.add(vel);
  }
  
  //check if has existed long enough and kill
  public boolean exist() {
    if ( age < maxAge ) {
      act();
      draw();

      age+=1/frameRate;

      return true;
    }
    else {
      return false;
    }
  }
}

//This is the stage of firework before exploding
//Firework persists until all sparks have died
public class Firework extends Emitter {
  boolean exploded = false;
  boolean dead = false;
  PVector prev;
  
  //rotation angle for corkscrew effect
  float rotationAngle = 0;

  public Firework(PVector pos, PVector vel, float maxAge) {
    super(pos, vel, maxAge);
    prev = pos.get();
  }

  //rotate firework in corkscrew
  public PVector rot(PVector p, float azimuth, float altitude) {

    PVector r = new PVector();
    //basic 3d rotation (derived from Felix Klein's Advanced Geometry)
    r.x = p.x*cos(azimuth)*cos(altitude);
    r.z = p.z*sin(azimuth)*cos(altitude);
    r.y = p.y*sin(altitude);

    return r;
  }
  
  //apply offset
  public PVector spiralOffset(float angle, float period) {
    return new PVector(cos(angle), 0, sin(angle));
  }

  public void draw() {
    vel.add(new PVector(0, GRAV/frameRate, 0));
    prev = pos.get();
    pos.add(vel);

    PVector sp = spiralOffset(rotationAngle, (maxAge)/5);
    sp.mult( vel.mag()/4 );

    float altitude = PVector.angleBetween( vel, new PVector(0, vel.y, 0) );
    float azimuth  = PVector.angleBetween( new PVector(vel.x, 0, vel.z), new PVector(1, 0, 0));

    sp = rot(sp, azimuth, altitude);
    pos.add(sp);
    rotationAngle += random(0, 1)/HALF_PI;
    age+=1/frameRate;

    if (age < maxAge) {
      pushMatrix();
      translate(0, 0, 0);
      stroke(255, 100);
      strokeWeight(2);
      line(pos.x, pos.y, pos.z, prev.x, prev.y, prev.z);
      popMatrix();
    }
    else {
      if (!exploded) {

        emit();
        exploded = true;
      }
    }

    super.draw();

    if (exploded && particles.size() == 0) {
      dead = true;
    }
  }
}

//basic emitter class
public class Emitter extends Particle {

  ArrayList <Particle> particles;

  public Emitter(PVector pos, PVector vel, float maxAge) {
    super(pos, vel, maxAge);
    particles = new ArrayList();
  }

  public void emit() {
    int ps = (int)(PS*random(.8, 1.2));

    color c = color(random(150, 255), random(150, 255), random(150, 255));

    for (int i=0;i<=180-ps;i+=ps) {
      for (int j=0;j<=360-ps;j+=ps) {

        float theta = radians(i);
        float azim  = radians(j);

        float s = random(2, 4);
        s*=3;
        PVector v = new PVector(s*sin(theta)*cos(azim), s*sin(azim), s*cos(theta)*cos(azim));
        v.add(new PVector(random(-1, 1), random(-1, 1), random(-1, 1)));
        v.add(vel);

        //PVector l = new PVector(mouseX, mouseY, -200);
        particles.add(new Flare(pos.get(), v, ParticleLife, c));
        //particles.add(new Spark(pos.get(), v, ParticleLife, c));
        //particles.add(new Firework(pos.get(),v,ParticleLife));
        //particles.add(new Particle(pos.get(), v, ParticleLife));
      }
    }
  }

  public void draw() {
    for (int i = 0; i<particles.size(); i++) {
      Particle p = (Particle)particles.get(i);
      if (!p.exist()) {
        particles.remove(i);
      }
    }
  }
}

//this class is the sparks falling from a firework
public class Flare extends Spark {

  ArrayList <Particle> children;
  int maxChildren;

  public Flare(PVector pos, PVector vel, float maxAge, color c) {
    super(pos, vel, maxAge, c);
    children = new ArrayList();
    //maxChildren = maxHist;
    maxChildren = sparks;
  }

  @Override
    public void act() {
    super.act();
    if (children.size() < maxChildren && random(1) > 0.8) {

      Spark s = new Spark(pos.get(), vel.get(), (maxAge-age)*random(0.3, 0.8), c);

      //float a = 1;
      //PVector jitter = new PVector(random(-a, a), random(-a, a), random(-a, a));

      //s.vel.mult(random(0.5,1));
      //s.vel.add(jitter);
      //s.vel.mult(resistance);
      s.vel.mult(0);
      s.maxHist = maxHist/3;
      s.opacity = 0.7;
      children.add(s);
    }
  }

  @Override
    public void draw() {
    super.draw();
    for (int i = 0; i<children.size(); i++) {
      Particle p = children.get(i);
      if (!p.exist()) {
        children.remove(i);
      }
    }
  }
}

//this class forms the lines extending from the firework and dropping flares
public class Spark extends Particle {

  ArrayList <PVector> hist;
  int maxHist = (int)(PathLength+PathLength*random(0.9, 1.1));
  float opacity = 1;
  color c;

  public Spark(PVector pos, PVector vel, float maxAge, color c) {
    super(pos, vel, maxAge*(random(0.5, 1.3)));
    hist = new ArrayList();
    this.c = c;
    //c = color(random(180,255),random(180,255),random(180,255));
  }

  @Override
    public void act() {
    //vel.mult(0.95);
    vel.mult(resistance);
    vel.add(new PVector(0, GRAV/frameRate, 0));
    super.act();

    while (hist.size () > maxHist) {
      hist.remove(0);
    }
    float a = 1;
    PVector jitter = new PVector(random(-a, a), random(-a, a), random(-a, a));
    PVector h = pos.get();
    //h.add(jitter);
    hist.add(h);
  }

  @Override
    public void draw() {

    pushMatrix();
    translate(0, 0, 0);

    strokeWeight(1);
    float light = (maxAge-age)*1.0/maxAge*opacity;

    int di = 1;
    for (int i=0;i<hist.size()-di;i++) {

      stroke(red(c), green(c), blue(c), (255-(maxHist-i)*1.0/maxHist*255)*light );

      line( hist.get(i).x, 
      hist.get(i).y, 
      hist.get(i).z, 
      hist.get(i+di).x, 
      hist.get(i+di).y, 
      hist.get(i+di).z
        );
    }

    stroke(red(c), green(c), blue(c), opacity );
    if (hist.size() >0) {
      //line(pos.x, pos.y, pos.z, hist.get(hist.size()-1).x, hist.get(hist.size()-1).y, hist.get(hist.size()-1).z);
    }
    translate(pos.x, pos.y, pos.z);
    noStroke();
    fill(red(c), green(c), blue(c), opacity );
    ellipse(0, 0, 2, 2);

    popMatrix();
  }
}

//scrollbar class, borrowed from Processing interface example code
//and modified by me for better access to data
class HScrollbar
{
  int swidth, sheight;    // width and height of bar
  int xpos, ypos;         // x and y position of bar
  float spos, newspos;    // x position of slider
  int sposMin, sposMax;   // max and min values of slider
  int loose;              // how loose/heavy
  boolean over;           // is the mouse over the slider?
  boolean locked;
  float ratio;

  HScrollbar (int xp, int yp, int sw, int sh, int l) {
    swidth = sw;
    sheight = sh;
    int widthtoheight = sw - sh;
    ratio = (float)sw / (float)widthtoheight;
    xpos = xp;
    ypos = yp-sheight/2;
    spos = xpos + swidth/2 - sheight/2;
    newspos = spos;
    sposMin = xpos;
    sposMax = xpos + swidth - sheight;
    loose = l;
  }

  void update() {
    boolean prelocked = locked;
    if (over()) {
      over = true;
    } 
    else {
      over = false;
    }
    if (mousePressed && over && !controlLock) {
      locked = true;
    }
    if (!mousePressed) {
      locked = false;
    }
    if (locked) {
      newspos = constrain(mouseX-sheight/2, sposMin, sposMax);
    }
    if (abs(newspos - spos) > 1) {
      spos = spos + (newspos-spos)/loose;
    }

    if (locked) {
      controlLock = true;
    }
    if (!locked && prelocked) {
      controlLock = false;
    }
  }

  int constrain(int val, int minv, int maxv) {
    return min(max(val, minv), maxv);
  }

  boolean over() {
    if (mouseX > xpos && mouseX < xpos+swidth &&
      mouseY > ypos && mouseY < ypos+sheight) {
      return true;
    } 
    else {
      return false;
    }
  }

  void display() {
    stroke(150);
    strokeWeight(1);
    fill(255);
    rect(xpos, ypos, swidth, sheight);
    if ((over && !controlLock) || locked ) {
      fill(0, 153, 170);
      //fill(153, 102, 0);
    } 
    else {
      fill(102, 102, 102);
    }
    noStroke();
    rect(spos-1, ypos-1, sheight+2, sheight+2);
  }

  void setPos(float pcnt) {
    newspos = xpos+swidth*pcnt;
  }

  //get location
  float getPos() {
    // Convert spos to be values between
    // 0 and the total width of the scrollbar
    return spos * ratio;
  }
  
  //get percentage
  float getPcnt() {
    return (spos-xpos)*1.0/(sposMax-sposMin);
  }
}

