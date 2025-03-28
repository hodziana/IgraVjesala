int mainMenu = 0;
String[] opcije = {"Singleplayer", "Multiplayer", "Leveli", "Postavke", "Izlaz"};

void setup() {
  size(600, 400);
  textAlign(CENTER, CENTER);
  textSize(32);
}

void draw() {
  background(200, 220, 255);
  
  for (int i = 0; i < opcije.length; i++) {
    if ( i == mainMenu ) {
      fill(255, 100, 100);
    } else {
      fill(0);
    }
    text(opcije[i], width / 2, 100 + i * 50);
  }
}

void keyPressed() {
  if (keyCode == UP) {
    mainMenu = (mainMenu - 1 + opcije.length) % opcije.length;
  } else if (keyCode == DOWN) {
    mainMenu = (mainMenu + 1) % opcije.length;
  } else if (keyCode == ENTER) {
    odabirOpcije();
  }
}

void odabirOpcije() {
  if (opcije[mainMenu].equals("Izlaz")) {
    exit();
  } else {
    println("Odabrana opcija: " + opcije[mainMenu]);
  }
}
