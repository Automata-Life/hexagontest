import processing.opengl.*; // the OpenGL library
import java.util.*;

float hexagonRadius = 10; // the radius of the individual hexagon cell
float hexagonStroke = 3; // stroke weight around hexagons (simulated! much faster than using the stroke() method)
int strokeColor = color(0); // stroke color around hexagons (simulated! much faster than using the stroke() method)
float neighbourDistance = hexagonRadius*2; // the default distance to include up to 6 neighbours

boolean play = false;
boolean step = false;
Hexagon initial = null;
PVector box = new PVector(1000,1000);
int offsetX = 50;
int offsetY = 50;
int iteration;
boolean[] SurvivalRules = {false,false,false,true,false,false,false};
boolean[] BirthRules = {false,false,true,false,false,false,false};


ArrayList <Hexagon> grid = new ArrayList <Hexagon> (); // the arrayList to store the whole grid of cells
PVector[] v = new PVector[6]; // an array to store the 6 pre-calculated vertex positions of a hexagon

void setup() {
  size(700, 700, P3D); // rendering with the OpenGL renderer is significantly faster when there is a lot of on-screen geometry
  noStroke(); // turn off stroke (for the rest of the sketch) since we use a much faster simulated stroke method
  smooth(); // turn on smooth(). Note that OpenGL smoothness usually depends on local graphics cards (aka anti-aliasing) settings
  initGrid(); // initialize the CA grid of hexagons (including neighbour search and creation of hexagon vertex positions)
  frameRate(10);
}

void draw() {
  background(strokeColor); // background aka simulated stroke color
  if (play)
    iterate();
  if (step) {
    iterate();
    step = false;
  }
  display();
}

void iterate() {
  iteration++;
  for (Hexagon h : grid){
    int count = 0;
    for (Hexagon n : h.neighbours)
      if (n.state) count++;
      
    h.setNext(h.state);
    if (h.state && ! SurvivalRules[count])  // death rule
      h.setNext(false);
    if (BirthRules[count] && ! h.state) // birth rule
      h.setNext(true);
  }
  for (Hexagon h : grid) h.step();
}

public void display() {
  for (Hexagon h : grid)
    h.display();
  displayGUI();
}

Hexagon getHex(float x, float y) {
  int i, j;
  j = round((y-offsetY)/(0.866f*hexagonRadius));
  if (j%2==0)
    i = round((x-offsetX)/(3*hexagonRadius));
  else
    i = round((x - (3*hexagonRadius*(0.5f)+offsetX))/(3*hexagonRadius));
  int hY = int(box.y/hexagonRadius/0.866f)+3;
  return grid.get(max(0, 
    min((i*hY+j), grid.size()-1)));
}

// do everything needed to start up the grid ONCE
void initGrid() {
  grid.clear(); // clear the grid

  // calculate horizontal grid size based on sketch width, hexagonRadius and a 'safety margin'
  int hX = int(box.x/hexagonRadius/3)+2;
  // calculate vertical grid size based on sketch height, hexagonRadius and a 'safety margin'
  int hY = int(box.y/hexagonRadius/0.866f)+3;

  // create the grid of hexagons
  for (int i=0; i<hX; i++) {
    for (int j=0; j<hY; j++) {
      // each hexagon contains it's xy position within the grid (also see the Hexagon class)
      grid.add( new Hexagon(i, j) );
    }
  }

  // let each hexagon in the grid find it's neighbours
  for (Hexagon h : grid) {
    h.getNeighbours(neighbourDistance,grid);
  }

  // create the vertex positions for the hexagon
  for (int i=0; i<6; i++) {
    float r = hexagonRadius - hexagonStroke * 0.5; // adapt radius to facilitate the 'simulated stroke'
    float theta = i*PI/3;
    v[i] = new PVector(r*cos(theta), r*sin(theta));
  }
}