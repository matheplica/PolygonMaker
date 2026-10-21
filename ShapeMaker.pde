import micycle.pgs.*;
import java.util.List;
import processing.svg.*;
PShape base, sh;
ArrayList<PShape> group = new ArrayList<PShape>();
int reso = 4, marge = 20, first, second, del, mode, seed = int(random(100));
int[] adapt = new int[2], select = new int[2];
boolean type = true;
//large 17cm*37.65 =>640
void setup() {
  pixelDensity(1);
  size(640, 480);
  hint(ENABLE_KEY_REPEAT);
  newShapes();
}
void draw() {
  background(240, 183, 8);
  stroke(0);
  strokeWeight(1);
  for (int i=0; i<group.size(); i++) {
    fill(154, 207, 220);
    if (PGS_ShapePredicates.containsPoint(group.get(i), new PVector(mouseX-marge, mouseY-marge))) {
      if (mode==0) {
        fill(228, 67, 166);
        select[0] = i;
      } else if (mode==1) {
        fill(20, 180, 244);
        select[1] = i;
      } else if (mode==2) {
        fill(0, 30, 30);
        del = i;
      }
    } else if (i==select[0] && mode<2) fill(20, 180, 244);
    shape(group.get(i), marge, marge);
  }
}
void mousePressed() {
  if (mouseButton == LEFT) {
    if (mode==0) mode = 1;
    else if (mode==1) {
      if (PGS_ShapePredicates.touch(group.get(select[0]), group.get(select[1]))) {
        if (PGS_Processing.shapeIntersection(group.get(select[0]), group.get(select[1])).size()>1) {
          sh = PGS_ShapeBoolean.union(group.get(select[0]), group.get(select[1]));
          sh.disableStyle();
          if (sh.getChildCount()>1) mode = 2;
          else addToGroup(sh);
        }
      }
    }else if (mode==2) delete(del);
  }
}
void addToGroup(PShape shape) {
  select = reverse(sort(select));
  group.remove(select[0]);
  group.remove(select[1]);
  group.add(shape);
  mode = 0;
}
void delete(int d) {
  if (d<group.size()) group.remove(d);
  mode = 0;
}
void keyPressed() {
  if (key=='a' && reso>1) {
    println("reso "+(--reso));
    newShapes();
  } else if (key=='z') {
    println("reso "+(++reso));
    newShapes();
  } else if (key=='e') {
    println("seed "+(--seed));
    newShapes();
  } else if (key=='r') {
    println("seed "+(++seed));
    newShapes();
  } else if (keyCode==TAB) {
    type =! type;
    newShapes();
  } else if (key=='s') recSvg();
  else if (key=='d') mode = (mode==2) ? 0 : 2;
  else if (key==' ') mode = 0;
}
void newShapes() {
  if (type) base = PGS_Tiling.sliceDivision(width-(marge*2), height-(marge*2), reso, true, seed);
  else base = PGS_Tiling.arcDivision(width-(marge*2), height-(marge*2), reso, seed);
  base.disableStyle();
  group.clear();
  for (int i=0; i<base.getChildCount(); i++) {
    group.add(base.getChild(i));
  }
  mode = 0;
}
void recSvg() {
  beginRecord(SVG, "frame-####.svg");
  noFill();
  PShape output = PGS_Processing.dissolve(base);
  output.disableStyle();
  shape(output, marge, marge);
  endRecord();
  println("svg saved");
}
