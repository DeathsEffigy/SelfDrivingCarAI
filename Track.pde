class Track {
  PImage map;
  int mapBlack = -16777216;
  int mapWhite = -1;
  float offX = 70;
  float offY = 38;
  float offRotation = -15;
  
  Track(String name) {
    loadMap(name);
  }
  
  void loadMap(String file) {
    map = loadImage("./tracks/" + file);
    map.loadPixels();
  }
  
  boolean checkWhitePixel(int x, int y) {
    int offset = int(x) + (int(y) * int(map.width));
    return map.pixels[offset] == mapWhite;
  }
  
  void frame() {
    image(map, 0, 0);
  }
}
