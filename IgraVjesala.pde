import processing.net.*;
import java.util.*;

//-----GLOBALNE VARIJABLE-----

int mainMenu = -1;
int hoverIndex = -1;

String[] opcije = {"Singleplayer", "Multiplayer", "Postavke", "Izlaz"};
String[] singleplayerOpcije = {"Leveli", "Natrag"};
String[] multiplayerOpcije = {"Postavi riječ", "Pogađaj", "Natrag"};
String[] levelOpcije = {"Level 1", "Level 2", "Level 3", "Natrag"};

boolean singleplayerMenu = false;
boolean multiplayerMenu = false; 
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

Server srv;
Client cli;
final int PORT = 50007;
final String LOCAL_IP= "127.0.0.1";

boolean netHost = false;
boolean netJoin = false;
boolean netConnected = false;
boolean netIpInput = false;
boolean netEnterWord = false;

String ipBuffer = "";
String wordBuffer = "";

boolean setterIsHost = true;

int scoreHost = 0;
int scoreClient = 0;
final int WIN_SCORE = 5;


//-----OSNOVNE FUNKCIJE-----

void setup() {
  size(600, 400);
  textAlign(CENTER, CENTER);
  textSize(32);
}

void draw() {
  background(200, 220, 255);
  hoverIndex = -1;

  netUpdate();

  if (prikaziRezultat) {
    prikaziRezultatEkran();
  } else if (igraAktivna) {
    prikaziIgru();
  } else if (netEnterWord) {
  prikaziNetUnosRijeci(); 
  } else if (multiplayerMenu) {
    prikaziOpcije(multiplayerOpcije);
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

  String[] rezultatOpcije = (netHost || netJoin) ? new String[]{"Natrag na multiplayer menu"} : new String[]{"Natrag na level menu"};
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

  //crtanje vješala
  int promasaji = 6 - pokusaji;
  crtajVjesala(promasaji);

  //pogođena slova i _
  String prikazTekst = "";
  boolean svePogodeno = true;
  for (char c : prikazano) {
    prikazTekst += c + " ";
    if (c == '_') svePogodeno = false;
  }
  
  float margin = 40;
  pushStyle();
  textAlign(RIGHT, TOP);
  text(prikazTekst, width - margin, 150);
  popStyle();

  pushStyle();
  textAlign(RIGHT, TOP);
  float yLabel = 230;
  float boxW = min(420, width - 2*margin);
  float xBox = width - margin - boxW;
  fill(0);
  text("Unesena slova:", width - margin, yLabel);
  float lh = textAscent() + textDescent() + 6;
  textLeading(lh);
  String slovaStr = unesenaSlovaTekst();
  text(slovaStr, xBox, yLabel + lh, boxW, height - (yLabel + lh) - margin);
  popStyle();

  if(netHost || netJoin){
    //multiplayer
    pushStyle();
    textAlign(RIGHT, TOP);
    textSize(20);
    String uloge = "Postavlja: " + (setterIsHost ? "HOST" : "CLIENT") + " | Pogađa: " + (setterIsHost ? "CLIENT" : "HOST");
    text("Bodovi HOST " + scoreHost + " - " + scoreClient + " CLIENT | " + uloge, width - margin, 20);
    text(uloge, width - margin, 50);
    popStyle();
  } else {
    //singleplayer
    pushStyle();
    textAlign(RIGHT, TOP);
    text("Level: " + odabraniLevel, width - margin, 320);
    popStyle();
  }

  if(!(netHost || netJoin)) {
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
  
}

//-----POMOĆNE FUNKCIJE-----

//funkcija za multiplayer unos rijeci
void prikaziNetUnosRijeci(){
  background(200, 220, 255);
  pushStyle();
  textAlign(CENTER, CENTER);
  fill(0);
  textSize(24);
  text((setterIsHost ? "HOST" : "CLIENT") + "  Upiši tajnu riječ (ENTER za start)", width/2, 80);

  textSize(36);
  String mask = "";
  for (int i = 0; i < wordBuffer.length(); i++) {
    char ch = wordBuffer.charAt(i);
    mask += (ch == ' ') ? "   " : "_ "; 
  }
  text(mask, width/2, 150);

  popStyle();
}

//funkcija za prikaz unesenih slova
String unesenaSlovaTekst() {
  if (unesenaSlova.isEmpty()) return "";
  StringBuilder sb = new StringBuilder();
  for (int i = 0; i < unesenaSlova.size(); i++) {
    sb.append(unesenaSlova.get(i));
    if (i < unesenaSlova.size() - 1) sb.append(' ');
  }
  return sb.toString();
}

//postavljanje nove rijeci u odnosu na level
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

//postavljanje nove rijeci u multiplayer modu
void inicijalizirajRijecZadana(String zadana) {
  rijec = zadana.toUpperCase();
  prikazano = new char[rijec.length()];
  for (int i = 0; i < prikazano.length; i++) {
    char ch = rijec.charAt(i);
    prikazano[i] = (ch == ' ') ? ' ' : '_';
  }
  unesenaSlova.clear();
  pokusaji = 6;
}

//provjer unosa slova
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

//funkcija za crtanje vjesala
void crtajVjesala(int promasaji) {
  int x0 = 80;         
  int y0 = 340;        
  int visina = 250;    
  int ruka = 80;       
  int uze = 40;        

  stroke(0);
  strokeWeight(4);

  line(x0, y0, x0 + 100, y0);         
  line(x0 + 20, y0, x0 + 20, y0 - visina);  
  line(x0 + 20, y0 - visina, x0 + 20 + ruka, y0 - visina); 
  line(x0 + 20 + ruka, y0 - visina, x0 + 20 + ruka, y0 - visina + uze); 

  int cx = x0 + 20 + ruka;          
  int cy = y0 - visina + uze + 20; 

  if (promasaji >= 1) {
    noFill();
    ellipse(cx, cy, 40, 40); 
  }
  if (promasaji >= 2) {
    line(cx, cy + 20, cx, cy + 20 + 60); 
  }
  if (promasaji >= 3) {
    line(cx, cy + 30, cx - 35, cy + 55); 
  }
  if (promasaji >= 4) {
    line(cx, cy + 30, cx + 35, cy + 55); 
  }
  if (promasaji >= 5) {
    line(cx, cy + 80, cx - 30, cy + 120); 
  }
  if (promasaji >= 6) {
    line(cx, cy + 80, cx + 30, cy + 120); 
  }
}

//-----MREŽNE FUNKCIJE-----

//igrač odabere opciju za postavljanje riječi i pokreće se server
void startHost() {
  closeNetwork();
  try {
    srv = new Server(this, PORT);
    println("Server pokrenut na portu " + PORT);
  } catch (Exception e) {
    println("Ne mogu pokrenuti server: " + e.getMessage());
  }
  netHost = true;
  netJoin = false;
  netConnected = false;

  scoreHost = scoreClient = 0;
  setterIsHost = true;

  wordBuffer = "";
  netEnterWord = true;  
}

//igrač odabere opciju za pogađanje i spaja se na lokalni server
void startJoinLocal() {
  closeNetwork();
  netJoin = true;
  netHost = false;
  netConnected = false;

  try {
    cli = new Client(this, LOCAL_IP, PORT);
    netConnected = true;
    println("JOIN (lokalno): spojeno na " + LOCAL_IP + ":" + PORT);
    cli.write("HELLO\n");
  } catch (Exception e) {
    println("JOIN (lokalno) neuspjelo: " + e.getMessage());
    netConnected = false;
  }

  multiplayerMenu = false; 
  mainMenu = -1;    
  igraAktivna = false;
}

void closeNetwork() {
  try { if (srv != null) srv.stop(); } catch(Exception e) {}
  try { if (cli != null) cli.stop(); } catch(Exception e) {}
  srv = null; cli = null;
  netHost = netJoin = netConnected = false;
  netEnterWord = false;
}

void netUpdate() {
  // Host: prihvati spajanje
  if (netHost && srv != null) {
    Client c = srv.available();
    if (c != null) {
      cli = c;
      netConnected = true;
      println("Klijent spojen.");
      // ako host već ima pripremljenu riječ, pošalji početno stanje
      if (igraAktivna) netSendState();
    }
  }
  // Host: čitaj klijenta
  if (netHost && netConnected && cli != null && cli.available() > 0) {
    String s = cli.readStringUntil('\n');
    if (s != null) handleClientMsg(s.trim());
  }
  // Client: čitaj server
  if (netJoin && netConnected && cli != null && cli.available() > 0) {
    String s = cli.readStringUntil('\n');
    if (s != null) handleServerMsg(s.trim());
  }
  // detektiraj prekid veze
  if ((netHost || netJoin) && cli != null && !cli.active()) {
    println("Veza prekinuta.");
    netConnected = false;
    cli = null;
    // vrati se u MP meni
    igraAktivna = false;
    netEnterWord = false;
    multiplayerMenu = true;
    mainMenu = 0;
  }
}

//šalje se poruka klijentu
void netSendState() {
  if (cli == null) return;
  String mask = new String(prikazano);
  StringBuilder sb = new StringBuilder();
  for (Character ch : unesenaSlova) sb.append(ch.charValue());
  String letters = sb.toString();
  cli.write("STATE|" + mask + "|" + pokusaji + "|" + letters + "|" +
            scoreHost + "|" + scoreClient + "|" + (setterIsHost ? 1 : 0) + "\n");
}

// zaprimi poruke od klijenta
void handleClientMsg(String msg) {
  String[] p = split(msg, '|');
  if (p.length == 0) return;

  if (p[0].equals("GUESS") && p.length >= 2 && p[1].length() > 0) {
    char unos = Character.toUpperCase(p[1].charAt(0));
    serverGuess(unos); // klijent pogađa -> host primjenjuje
  } else if (p[0].equals("SET") && p.length >= 2) {
    // klijent zadaje riječ
    setterIsHost = false;
    serverNewRoundSetWord(p[1].toUpperCase());
  }
}

//  zaprimi poruke od servera
void handleServerMsg(String msg) {
  String[] p = split(msg, '|');
  if (p.length == 0) return;

  if (p[0].equals("STATE") && p.length >= 7) {
    String mask = p[1];
    int pok = int(p[2]);
    String letters = p[3];
    scoreHost = int(p[4]);
    scoreClient = int(p[5]);
    setterIsHost = int(p[6]) == 1;

    prikazano = mask.toCharArray();
    pokusaji = pok;

    unesenaSlova.clear();
    for (int i = 0; i < letters.length(); i++) unesenaSlova.add(letters.charAt(i));

    igraAktivna = true;
    prikaziRezultat = false;
  } else if (p[0].equals("RESULT") && p.length >= 7) {
    boolean guesserWin = int(p[1]) == 1;
    String finalWord = p[2];
    scoreHost = int(p[3]);
    scoreClient = int(p[4]);
    boolean nextSetterHost = int(p[5]) == 1;
    boolean matchOver = int(p[6]) == 1;

    rijec = finalWord;
    setterIsHost = nextSetterHost;

    if (matchOver) {
      igraAktivna = false;
      prikaziRezultat = true;
      pobjeda = (scoreClient >= WIN_SCORE);
      mainMenu = 0;
    } else {
      igraAktivna = false;
      unesenaSlova.clear();
      pokusaji = 6;
      if (!nextSetterHost) {
        wordBuffer = "";
        netEnterWord = true; 
      }
    }
  }
}


//pokreni novu rundu sa zadanom rijeci (setter moze biti host ili client)
void serverNewRoundSetWord(String zadana) {
  inicijalizirajRijecZadana(zadana);
  igraAktivna = true;
  netEnterWord = false;
  netSendState();
}

//pogađanje
void serverGuess(char unos) {
  if (unesenaSlova.contains(unos)) return;
  unesenaSlova.add(unos);
  provjeriUnos(unos);

  boolean svePogodeno = true;
  for (char c : prikazano) if (c == '_') { svePogodeno = false; break; }

  if (pokusaji <= 0 || svePogodeno) {
    boolean guesserWon = svePogodeno; 
    serverEndRound(guesserWon);
  } else {
    netSendState();
  }
}

//završetak runde + bodovi + odluka o sljedećem setteru
void serverEndRound(boolean guesserWon) {
  boolean guesserIsHost = !setterIsHost;

  if (guesserWon) {
    if (guesserIsHost) scoreHost++;
    else scoreClient++;
    // setter ostaje isti
  } else {
    // pogađač izgubio -> bod postavljaču, uloge se zamijene
    if (setterIsHost) scoreHost++;
    else scoreClient++;
    setterIsHost = !setterIsHost; // zamjena uloga postavljača
  }

  boolean matchOver = (scoreHost >= WIN_SCORE) || (scoreClient >= WIN_SCORE);

  // pošalji rezultat klijentu
  if (cli != null) {
    cli.write("RESULT|" + (guesserWon ? 1 : 0) + "|" + rijec + "|" +
              scoreHost + "|" + scoreClient + "|" + (setterIsHost ? 1 : 0) + "|" +
              (matchOver ? 1 : 0) + "\n");
  }

  if (matchOver) {
    // prikaži rezultat lokalno
    igraAktivna = false;
    prikaziRezultat = true;
    pobjeda = (scoreHost >= WIN_SCORE);
    return;
  }

  // inače – priprema za sljedeću rundu: tko postavlja neka upiše novu riječ
  igraAktivna = false;
  unesenaSlova.clear();
  pokusaji = 6;

  if (setterIsHost) {
    // host postavlja -> lokalni ekran za unos
    wordBuffer = "";
    netEnterWord = true;
  } else {
    // klijent postavlja -> on će otvoriti svoj ekran po zaprimanju RESULT-a
  }
}


//-----FUNKCIJE OBRADE UNOSA-----

void keyPressed() {

  if (netEnterWord) {
    if (keyCode == ENTER) {
      if (wordBuffer.length() > 0) {
        if (netHost && setterIsHost) {
          // host postavlja
          serverNewRoundSetWord(wordBuffer.toUpperCase());
        } else if (netJoin && !setterIsHost) {
          // klijent postavlja -> šalje serveru
          if (cli != null) cli.write("SET|" + wordBuffer.toUpperCase() + "\n");
          netEnterWord = false; // čekaj STATE od servera
        }
      }
    } else if (keyCode == BACKSPACE) {
      if (wordBuffer.length() > 0) wordBuffer = wordBuffer.substring(0, wordBuffer.length()-1);
    } else if (keyCode == ESC) {
      // prekid mreže i povrat
      closeNetwork();
      multiplayerMenu = true; mainMenu = 0;
    } else {
      if (Character.isLetter(key) || key == ' ') wordBuffer += Character.toUpperCase(key);
    }
    return;
  }

  if (igraAktivna) {
    if (netHost || netJoin) {
      boolean guesserIsHost = !setterIsHost;

      if (Character.isLetter(key) || (key >= 'A' && key <= 'Z') || (key >= 'a' && key <= 'z')) {
        char unos = Character.toUpperCase(key);
        if (netHost && guesserIsHost) {
          // host pogađa
          serverGuess(unos);
        } else if (netJoin && !guesserIsHost) {
          // klijent pogađa (setter je host)
          if (cli != null) cli.write("GUESS|" + unos + "\n");
        }
      } else if (keyCode == ESC) {
        closeNetwork();
        multiplayerMenu = true; mainMenu = 0;
      }
      return;
    }

    // singleplayer 
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
      return;
    }
  
  String[] trenutniMeni = prikaziRezultat
    ? new String[]{ (netHost || netJoin) ? "Natrag na multiplayer menu" : "Natrag na level menu" }
    : (multiplayerMenu ? multiplayerOpcije
      : (levelMenu ? levelOpcije : (singleplayerMenu ? singleplayerOpcije : opcije)));

  int duljina = trenutniMeni.length;
  if (keyCode == UP) {
    mainMenu = (mainMenu - 1 + duljina) % duljina;
  } else if (keyCode == DOWN) {
    mainMenu = (mainMenu + 1) % duljina;
  } else if (keyCode == ENTER) {
    odaberiTrenutno();
  }
}

void mousePressed() {
  String[] trenutniMeni = prikaziRezultat
    ? new String[]{ (netHost || netJoin) ? "Natrag na multiplayer menu" : "Natrag na level menu" }
    : (multiplayerMenu ? multiplayerOpcije
      : (levelMenu ? levelOpcije : (singleplayerMenu ? singleplayerOpcije : opcije)));
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
    if (netHost || netJoin) {
      closeNetwork();
      multiplayerMenu = true; mainMenu = 0;
    } else {
      levelMenu = true;
      mainMenu = -1;
    }
    return;
  }
  if (levelMenu) {
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
  } else if (multiplayerMenu) {
    String izbor = multiplayerOpcije[mainMenu];
    if (izbor.equals("Natrag")) {
      multiplayerMenu = false;
      mainMenu = 0;
    } else if (izbor.equals("Postavi riječ")) {
      startHost();
    } else if (izbor.equals("Pogađaj")) {  
      startJoinLocal();
    } 
  } else {
    String izbor = opcije[mainMenu];
    if (izbor.equals("Izlaz")) {
      exit();
    } else if (izbor.equals("Singleplayer")) {
      singleplayerMenu = true;
      mainMenu = 0;
    } else if (izbor.equals("Multiplayer")) {
      multiplayerMenu = true;
      mainMenu = 0;
    } else {
      println("Odabrana opcija: " + izbor);
    }
  }
}


