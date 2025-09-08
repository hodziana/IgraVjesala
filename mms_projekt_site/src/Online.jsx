import stickman from "./assets/stickman.svg?raw";
import { useState } from "react";

export default function Online() {
  const [rijec, setRijec] = useState("");
  const [pogodjeno, setPogodjeno] = useState([]);
  const [greske, setGreske] = useState(0);
  const maxGreske = 6;
  const [pokusaj, setPokusaj] = useState("");
  const [promasaji, setPromasaji] = useState([]);
  const [cestitka, setCestitka] = useState(false);

  const rijeci = [
    "topologija",
    "operator",
    "derivacija",
    "integral",
    "homeomorfan",
    "aproksimacija",
    "vjerojatnost",
    "matrica",
    "determinanta",
    "izomorfizam",
    "funkcional",
    "diferencijal",
    "granica",
    "tenzor",
    "polinom",
    "grupa",
    "prsten",
    "tijelo",
    "mjera",
    "vektor",

    "kompajler",
    "interpretator",
    "algoritam",
    "rekurzija",
    "iterator",
    "podatak",
    "niz",
    "struktura",
    "datoteka",
    "biblioteka",
    "razred",
    "objekt",
    "funkcija",
    "varijabla",
    "apstrakcija",
    "optimizacija",
    "paralelizam",
    "mreža",
    "poslužitelj",
    "baza",

    "stol",
    "stolica",
    "računalo",
    "mobitel",
    "knjiga",
    "olovka",
    "torba",
    "bicikl",
    "naočale",
    "sat",
  ];
  
  const resetGame = () => {
    const novaRijec = rijeci[Math.floor(Math.random() * rijeci.length)];
    setRijec(novaRijec);
    setPogodjeno([]);
    setGreske(0);
    setPokusaj("");
    setPromasaji([]);
    setCestitka(false);
  };

  const classnames = [
    "vjesala",
    greske >= 1 ? "g-1" : "",
    greske >= 2 ? "g-2" : "",
    greske >= 3 ? "g-3" : "",
    greske >= 4 ? "g-4" : "",
    greske >= 5 ? "g-5" : "",
    greske >= 6 ? "g-6" : "",
  ].join(" ");

  return (
    <div className="w-full p-0 m-0" id="online">
      <div className="w-full flex flex-col items-center gap-6 py-8">
        <h2 className="text-2xl font-bold text-indigo-500 mb-2">
          Online verzija igre Vješala
        </h2>
        <div className="w-32 h-32 flex items-center justify-center mb-4">
          <div
            className={classnames}
            dangerouslySetInnerHTML={{ __html: stickman }}
          />
        </div>
        <p className="text-3xl font-mono tracking-widest mb-4 flex justify-center gap-4">
          {rijec
            ? rijec.split("").map((slovo, idx) => (
                <span
                  key={slovo + idx}
                  className={
                    pogodjeno.includes(slovo)
                      ? "text-indigo-700 font-bold px-2"
                      : "text-gray-400 px-2"
                  }
                  style={{
                    minWidth: "2rem",
                    display: "inline-block",
                    textAlign: "center",
                  }}
                >
                  {pogodjeno.includes(slovo) ? slovo : "_"}
                </span>
              ))
            : ""}
        </p>
        <div className="w-full mt-2 mb-2 flex flex-col items-center">
          <p className="text-sm text-gray-500 mb-1 text-center">
            Promašaji:{" "}
            <span className="text-red-500 font-semibold">
              {promasaji.join(", ")}
            </span>
          </p>
          {cestitka ? null : greske < maxGreske ? (
            <p className="text-sm text-indigo-700 text-center">
              Pokušajte pogoditi riječ!
            </p>
          ) : null}
        </div>
        <p className="text-sm text-gray-600">
          Pogodili ste:{" "}
          <span className="font-semibold text-green-700">
            {pogodjeno.join(", ")}
          </span>
        </p>
        <p className="text-sm text-gray-600">
          Broj grešaka:{" "}
          <span className="font-semibold text-red-600">{greske}</span> /{" "}
          {maxGreske}
        </p>
        <button
          onClick={resetGame}
          className="mt-2 px-4 py-2 bg-indigo-600 text-white rounded hover:bg-indigo-700 transition"
        >
          Nova riječ
        </button>
        <form onSubmit={(e) => e.preventDefault()} className="flex gap-2 mt-4">
          <input
            type="text"
            value={pokusaj}
            onChange={(e) => {
              const val = e.target.value;
              if (/^[a-zA-ZčćžšđČĆŽŠĐ]?$/.test(val)) {
                if (!rijec || greske >= maxGreske || cestitka) return;
                setPokusaj(val);
                if (val.length === 1) {
                  const slovo = val.toLowerCase();
                  if (rijec.includes(slovo)) {
                    if (!pogodjeno.includes(slovo)) {
                      const novaPogodjena = [...pogodjeno, slovo];
                      setPogodjeno(novaPogodjena);
                      const uniqueLetters = Array.from(
                        new Set(rijec.split(""))
                      );
                      if (
                        uniqueLetters.every((l) => novaPogodjena.includes(l))
                      ) {
                        setCestitka(true);
                        setTimeout(resetGame, 2000);
                      }
                    }
                  } else {
                    if (!promasaji.includes(slovo)) {
                      setGreske(greske + 1);
                      setPromasaji([...promasaji, slovo]);
                    }
                  }
                  setPokusaj("");
                }
              }
            }}
            maxLength={1}
            disabled={!rijec || greske >= maxGreske || cestitka}
            placeholder="Slovo"
            autoFocus
            className="border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-400 text-lg w-20 text-center"
          />
          <button
            type="submit"
            disabled={!rijec || greske >= maxGreske || cestitka}
            className="px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600 transition"
          >
            Pogodi
          </button>
        </form>
        <div className="w-full mt-4">
          {cestitka ? (
            <p className="text-lg text-green-600 font-bold text-center">
              Čestitamo! Pogodili ste riječ:{" "}
              <span className="underline">{rijec}</span>
            </p>
          ) : greske >= maxGreske ? (
            <p className="text-lg text-red-600 font-bold text-center">
              Izgubili ste! Riječ je bila:{" "}
              <span className="underline">{rijec}</span>
            </p>
          ) : null}
        </div>
      </div>
    </div>
  );
}
