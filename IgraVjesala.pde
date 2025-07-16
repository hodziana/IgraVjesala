int mainMenu = 0;
String[] opcije = {"Singleplayer", "Multiplayer", "Postavke", "Izlaz"};
String[] singleplayerOpcije = {"Leveli", "Natrag"};
String[] levelOpcije = {"Level 1", "Level 2", "Level 3", "Natrag"};
boolean singleplayerMenu = false;
boolean levelMenu = false;
boolean igraAktivna = false;

int odabraniLevel = 1;
String rijec = "";
char[] prikazano;
int pokusaji = 6;
ArrayList<Character> unesenaSlova = new ArrayList<>();

String[] rijeciLevel1 = {"PARK", "PAS", "JABUKA", "MLIJEKO", "KUĆA", "STOL", "KNJIGA", "VODA"};
String[] rijeciLevel2 = {"RAČUNALO", "TELEFON", "AUTOBUS", "ZRAKOPLOV", "OGRADA"};
String[] rijeciLevel3 = {"PROGRAMIRANJE", "MATEMATIKA", "FUNKCIONALNOST", "KOMPATIBILNOST"};

void setup() {
  size(600, 400);
  textAlign(CENTER, CENTER);
  textSize(32);
}

void draw() {
  background(200, 220, 255);
  if (igraAktivna) {
    prikaziIgru();
  } else if (levelMenu) {
    prikaziLevelOpcije();
  } else if (singleplayerMenu) {
    prikaziSingleplayerMeni();
  } else {
    prikaziGlavniMeni();
  }
}

void prikaziGlavniMeni() {
  for (int i = 0; i < opcije.length; i++) {
    if (i == mainMenu) fill(255, 100, 100);
    else fill(0);
    text(opcije[i], width / 2, 100 + i * 50);
  }
}

void prikaziSingleplayerMeni() {
  for (int i = 0; i < singleplayerOpcije.length; i++) {
    if (i == mainMenu) fill(255, 100, 100);
    else fill(0);
    text(singleplayerOpcije[i], width / 2, 100 + i * 50);
  }
}

void prikaziLevelOpcije() {
  for (int i = 0; i < levelOpcije.length; i++) {
    if (i == mainMenu) fill(255, 100, 100);
    else fill(0);
    text(levelOpcije[i], width / 2, 100 + i * 50);
  }
}

void prikaziIgru() {
  fill(0);
  text("Pokušaji: " + pokusaji, width / 2, 50);

  String prikazTekst = "";
  for (char c : prikazano) {
    prikazTekst += c + " ";
  }
  text(prikazTekst, width / 2, 150);

  text("Unesena slova: " + unesenaSlova.toString(), width / 2, 250);
  text("Level: " + odabraniLevel, width / 2, 320);

  if (pokusaji <= 0) {
    fill(255, 0, 0);
    text("Izgubio si!", width / 2, height - 50);
    delay(1500);
    igraAktivna = false;
    levelMenu = true;
    mainMenu = 0;
  }
}

void keyPressed() {
  if (igraAktivna) {
    if (key >= 'A' && key <= 'Z' || key >= 'a' && key <= 'z') {
      char unos = Character.toUpperCase(key);
      if (!unesenaSlova.contains(unos)) {
        unesenaSlova.add(unos);
        provjeriUnos(unos);
      }
    } else if (keyCode == ESC) {
      igraAktivna = false;
      singleplayerMenu = true;
      mainMenu = 0;
    }
  } else if (levelMenu) {
    if (keyCode == UP) {
      mainMenu = (mainMenu - 1 + levelOpcije.length) % levelOpcije.length;
    } else if (keyCode == DOWN) {
      mainMenu = (mainMenu + 1) % levelOpcije.length;
    } else if (keyCode == ENTER) {
      String izbor = levelOpcije[mainMenu];
      if (izbor.equals("Natrag")) {
        levelMenu = false;
        singleplayerMenu = true;
        mainMenu = 0;
      } else {
        odabraniLevel = mainMenu + 1;
        igraAktivna = true;
        levelMenu = false;
        mainMenu = 0;
        inicijalizirajRijec();
      }
    }
  } else if (singleplayerMenu) {
    if (keyCode == UP) {
      mainMenu = (mainMenu - 1 + singleplayerOpcije.length) % singleplayerOpcije.length;
    } else if (keyCode == DOWN) {
      mainMenu = (mainMenu + 1) % singleplayerOpcije.length;
    } else if (keyCode == ENTER) {
      String izbor = singleplayerOpcije[mainMenu];
      if (izbor.equals("Natrag")) {
        singleplayerMenu = false;
        mainMenu = 0;
      } else if (izbor.equals("Leveli")) {
        levelMenu = true;
        singleplayerMenu = false;
        mainMenu = 0;
      }
    }
  } else {
    if (keyCode == UP) {
      mainMenu = (mainMenu - 1 + opcije.length) % opcije.length;
    } else if (keyCode == DOWN) {
      mainMenu = (mainMenu + 1) % opcije.length;
    } else if (keyCode == ENTER) {
      odabirOpcije();
    }
  }
}

void odabirOpcije() {
  String izbor = opcije[mainMenu];
  if (izbor.equals("Izlaz")) {
    exit();
  } else if (izbor.equals("Singleplayer")) {
    singleplayerMenu = true;
    mainMenu = 0;
  } else {
    println("Odabrana opcija: " + izbor);
  }
}

void inicijalizirajRijec() {
  String[] trenutnaLista;
  if (odabraniLevel == 1) {
    trenutnaLista = rijeciLevel1;
  } else if (odabraniLevel == 2) {
    trenutnaLista = rijeciLevel2;
  } else {
    trenutnaLista = rijeciLevel3;
  }
  rijec = trenutnaLista[(int) random(trenutnaLista.length)];
  prikazano = new char[rijec.length()];
  for (int i = 0; i < prikazano.length; i++) {
    prikazano[i] = '_';
  }
  unesenaSlova.clear();
  pokusaji = 6;
}

void provjeriUnos(char unos) {
  boolean pogodak = false;
  for (int i = 0; i < rijec.length(); i++) {
    if (rijec.charAt(i) == unos) {
      prikazano[i] = unos;
      pogodak = true;
    }
  }
  if (!pogodak && pokusaji > 0) {
    pokusaji--;
  }
}
