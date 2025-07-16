int mainMenu = -1;
int hoverIndex = -1;
String[] opcije = {"Singleplayer", "Multiplayer", "Postavke", "Izlaz"};
String[] singleplayerOpcije = {"Leveli", "Natrag"};
String[] levelOpcije = {"Level 1", "Level 2", "Level 3", "Natrag"};
boolean singleplayerMenu = false;
boolean levelMenu = false;
boolean igraAktivna = false;
boolean prikaziRezultat = false;
boolean pobjeda = false;

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
  hoverIndex = -1;

  if (prikaziRezultat) {
    prikaziRezultatEkran();
  } else if (igraAktivna) {
    prikaziIgru();
  } else if (levelMenu) {
    prikaziOpcije(levelOpcije);
  } else if (singleplayerMenu) {
    prikaziOpcije(singleplayerOpcije);
  } else {
    prikaziOpcije(opcije);
  }
}

void prikaziRezultatEkran() {
  fill(pobjeda ? color(0, 150, 0) : color(255, 0, 0));
  text(pobjeda ? "Pobijedio si!" : "Izgubio si!", width / 2, 60);

  String[] rezultatOpcije = {"Natrag na level menu"};
  prikaziOpcije(rezultatOpcije);
}

void prikaziOpcije(String[] izbornik) {
  for (int i = 0; i < izbornik.length; i++) {
    float x = width / 2;
    float y = 100 + i * 50;
    float w = textWidth(izbornik[i]);
    float h = 32;

    boolean isHovered = mouseX > x - w / 2 && mouseX < x + w / 2 &&
                        mouseY > y - h / 2 && mouseY < y + h / 2;
    if (isHovered) hoverIndex = i;
  }

  if (hoverIndex != -1) {
    mainMenu = hoverIndex;
  }

  for (int i = 0; i < izbornik.length; i++) {
    float x = width / 2;
    float y = 100 + i * 50;

    if (i == mainMenu) {
      fill(255, 100, 100);
    } else {
      fill(0);
    }
    text(izbornik[i], x, y);
  }
}

void prikaziIgru() {
  fill(0);
  text("Pokušaji: " + pokusaji, width / 2, 50);

  String prikazTekst = "";
  boolean svePogodeno = true;
  for (char c : prikazano) {
    prikazTekst += c + " ";
    if (c == '_') svePogodeno = false;
  }
  text(prikazTekst, width / 2, 150);

  text("Unesena slova: " + unesenaSlova.toString(), width / 2, 250);
  text("Level: " + odabraniLevel, width / 2, 320);

  if (pokusaji <= 0) {
    prikaziRezultat = true;
    pobjeda = false;
    igraAktivna = false;
    mainMenu = -1;
  } else if (svePogodeno) {
    prikaziRezultat = true;
    pobjeda = true;
    igraAktivna = false;
    mainMenu = -1;
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
  } else {
    String[] trenutniMeni = prikaziRezultat ? new String[]{"Natrag na level menu"} : levelMenu ? levelOpcije : (singleplayerMenu ? singleplayerOpcije : opcije);
    int duljina = trenutniMeni.length;
    if (keyCode == UP) {
      mainMenu = (mainMenu - 1 + duljina) % duljina;
    } else if (keyCode == DOWN) {
      mainMenu = (mainMenu + 1) % duljina;
    } else if (keyCode == ENTER) {
      odaberiTrenutno();
    }
  }
}

void mousePressed() {
  String[] trenutniMeni = prikaziRezultat ? new String[]{"Natrag na level menu"} : levelMenu ? levelOpcije : (singleplayerMenu ? singleplayerOpcije : opcije);
  for (int i = 0; i < trenutniMeni.length; i++) {
    float x = width / 2;
    float y = 100 + i * 50;
    float w = textWidth(trenutniMeni[i]);
    float h = 32;
    if (mouseX > x - w / 2 && mouseX < x + w / 2 &&
        mouseY > y - h / 2 && mouseY < y + h / 2) {
      mainMenu = i;
      odaberiTrenutno();
    }
  }
}

void odaberiTrenutno() {
  if (igraAktivna) return;

  if (prikaziRezultat) {
    prikaziRezultat = false;
    levelMenu = true;
    mainMenu = -1;
  } else if (levelMenu) {
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
  } else if (singleplayerMenu) {
    String izbor = singleplayerOpcije[mainMenu];
    if (izbor.equals("Natrag")) {
      singleplayerMenu = false;
      mainMenu = 0;
    } else if (izbor.equals("Leveli")) {
      levelMenu = true;
      singleplayerMenu = false;
      mainMenu = 0;
    }
  } else {
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
