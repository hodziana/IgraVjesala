# Uvod

U ovom dokumentu opisan je kod napravljen za igru Vješala kao završni
projekt kolegija Multimedijski sustavi.

Kod u IgreVjesala.pde je podijeljen na 5 dijelova kako bi olakšali
čitatelju snalaženje, a to su globalne varijable, osnovne funkcije,
pomoćne funkcije, mrežne funkcije i funkcije obrada unosa. U ovoj
dokumentaciji opis projekta je podijeljen kronološki po dodanim
funkcionalnostima. Prvo smo postavili osnovnu verziju igre s njenim
izbornikom i glavnom logikom igre za singleplayer opciju, a zatim dodali
funkcionalnosti crtanja vješala kao vizualni prikaz gubljenja pokušaja u
igri te implementirali multiplayer. Finalno, igri smo dodali opciju
promjene postavki.

# Funkcionalnosti igre

## Singleplayer verzija igre

## Crtanje vješala

Vješalo je nacrtano na lijevom dijelu ekrana i sa svakom greškom igrača
se nacrta novi dio tijela. Igrač ima pravo 6 puta pogriješiti te kad se
nacrtaju glava, trup i udovi, igrač gubi igru.

Postojećem kodu koji ima brojač za pokušaje smo dodali varijablu
promašaji koja je brojač povezan sa crtanjem vješala. Ovisno koliko je
pokušaja potrošeno, ovisi koliko udova crtamo.

Glavna funkcija koja nam pomaže u crtanju vješala je
crtajVjesala(promasaji).

```java
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
```

Tu funkciju pozivamo u prikaziIgru().

## Multiplayer

Igrač u multiplayer modu može odabrati želi li biti onaj koji postavlja
riječ ili onaj koji ju pogađa. Ako onaj igrač koji pogađa riječ uspije
pogoditi, onda dobiva bod i nastavlja biti onaj koji pogađa sve dok ne
pogriješi. Kad igrač pogriješi, onaj koji je zadao riječ dobiva bod i
onda je njegov red da pogađa. Igra se dok netko ne skupi 5 bodova.
Multiplayer opcija je napravljena tako da se od ove verzije koda,
IgraVjesala.pde, napravi kopija i pokrenu se obje u Processing-u. Dakle,
igra je složena da se lokalno igra na jednom računalu. U jednom prozoru
igrač upiše riječ, a u drugom pogađa. Na oba prozora je vidljivo stanje
igre i trenutni bodovi oba igrača.

Za multiplayer opciju morali smo uključiti i import processing.net.\*;
koji nam omogućava mrežne igranje. Također, postavili smo port 50007 i
lokalnu ip adresu 127.0.0.1, a za logiku su nam potrebne i zastavice.

```java
Server srv;
Client cli;
final int PORT = 50007;
final String LOCAL_IP= "127.0.0.1";

boolean netHost = false;
boolean netJoin = false;
boolean netConnected = false;
boolean netIpInput = false;
boolean netEnterWord = false;

String wordBuffer = ""; //unos riječi od host-a

boolean setterIsHost = true; //host je uvijek postavljač riječi na početku

int scoreHost = 0;
int scoreClient = 0;
final int WIN_SCORE = 5; //igra se do 5
```

**Multiplayer opcija igre započinje** s time da igrač bira, na izbornom
meni-ju, hoće li postavljati riječ ili pogađati.

```java
String[] multiplayerOpcije = {"Postavi riječ", "Pogađaj", "Natrag"};
```

Ukoliko igrač odabere postavljanje, poziva se startHost koji pokreće
server i postavlja zastavice na stranu host-a, a ako odabere pogađanje
onda se poziva startJoinLocal() i time se spaja na server te postavlja
zastavice na stranu klijenta.

```java
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

  scoreHost = scoreClient = 0; //postavlja rezultate na početak
  setterIsHost = true;

  wordBuffer = ""; //isprazni riječ da bi mogli upisati novu
  netEnterWord = true;   // host odmah postavlja prvu riječ
}

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
```

Oblici **poruka** koji se pojavljuju u kodu su sljedeći:

1.  klijent -\>server

    GUESSSLOVO šalje klijent serveru kad je setter host

    SETRIJEČ šalje klijent kad je on setter

2.  server -\>klijent

    STATE\<MASK\>\<POKUSAJI\>\<SLOVA\>HOST-A\>\<SCORE KLIJENTA\>\<SETTER
    IS HOST \>

**Glavna mrežna petlja** se nalazi u netUpdate() koja se poziva sa
svakim pozivom funkcije draw().

Ta funkcija ima sljedeće radnje:

1.  Host prihvaća spajanje

    Host ili prihvaća spajanje klijenta ili ako je igra u tijeku, vraća
    stanje igre pozivom netSendState()

2.  Host čita klijentovu poruku

    Pozivom handleClientMsg() se obrađuje poruka koju je klijent poslao

3.  Klijent čita poruku od host-a

    Pozivom handleServerMsg() se obrađuje poruka koju je host poslao

4.  Prekid veze

Host **postavlja** riječ na ekranu koji je zadan funkcijom
prikaziNetUnosRijeci() i time se riječ sprema u wordBuffer. Zatim se u
funkciji keyPressed() provjerava zastavica za unesenu riječ te se poziva
serverNewRoundSetWord(). Kada klijent postavlja riječ, poziva se
handleClientMsg() u kojoj se također pozove serverNewRoundSetWord().

```java
void serverNewRoundSetWord(String zadana) {
  inicijalizirajRijecZadana(zadana);
  igraAktivna = true;
  netEnterWord = false;
  netSendState();
}
```

**Pogađa** onaj koji nije setter (guesserIsHost zastavica), a u
keyPressed() funkciji se poziva serverGuess() koja provjerava unos i
ukoliko su potrošeni svi pokušaji ili sva slova pogođena, poziva
funkciju za kraj serverEndRound() ili netSendState() za slanje poruke
koja sadržava sve info.

```java
//pogađanje
void serverGuess(char unos) {
  if (unesenaSlova.contains(unos)) return;
  unesenaSlova.add(unos);
  provjeriUnos(unos);

  boolean svePogodeno = true;
  for (char c : prikazano) if (c == '_') {svePogodeno = false; break;}

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

  boolean matchOver = (scoreHost >= WIN_SCORE) || 
  (scoreClient >= WIN_SCORE);

  // pošalji rezultat klijentu
  if (cli != null) {
    cli.write("RESULT|" + (guesserWon ? 1 : 0) + "|" + rijec + "|" +
              scoreHost + "|" + scoreClient + "|" + 
              (setterIsHost ? 1 : 0) + "|" +
              (matchOver ? 1 : 0) + "\n");
  }

  if (matchOver) {
    // prikaži rezultat lokalno
    igraAktivna = false;
    prikaziRezultat = true;
    pobjeda = (scoreHost >= WIN_SCORE);
    return;
  }

  // priprema za sljedeću rundu:tko postavlja neka upiše novu riječ
  igraAktivna = false;
  unesenaSlova.clear();
  pokusaji = 6;

  if (setterIsHost) {
    // host postavlja -> lokalni ekran za unos
    wordBuffer = "";
    netEnterWord = true;
  } else {
    // klijent postavlja
  }
}
```

Osim toga, važno je još napomenuti da u funkciji keyPressed() ovisno o
zastavicama netEnterWord i igraAktivna se događaju radnje unosa tajne
riječi te pogađanje tj. radnje koje smo prethodno objasnili.

## Promjena postavki
