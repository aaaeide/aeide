# aeide.no

Gratulerer du har rotet deg inn i kildekoden til nettsida mi, aeide.no. Nettsida er en enkel `index.html` med innholdet spredt utover markdown-filer (`om.md`, `naa.md`, `prosjekter.md`, `radio.md`) — hver fil rendres i sin egen oransje boks nedover siden, med en liten, dependency-fri script. Ingen build-steg, ingen dependencies. Hostet gratis på GitHub Pages.

## Oppdatere innholdet

Skriv tekst i den aktuelle `.md`-filen og push — siden oppdateres automatisk. Hver fil vises som en egen boks. Nye bokser = nye filer: legg filen til i `files`-lista i `index.html`. Støttet markdown: paragrafer, `#`/`##`/`###` overskrifter, `---` horisontal linje, `**fet**`, `*kursiv*`, `` `kode` `` og `[link](url)`.

## Sette opp GitHub Pages

1. Repo → Settings → Pages → Source: **Deploy from a branch** → `master` / root.
2. Custom domain: `aeide.no`.
3. Hos DNS-leverandøren din, pek `aeide.no` til GitHub Pages:

   ```
   A     185.199.108.153
   A     185.199.109.153
   A     185.199.110.153
   A     185.199.111.153
   ```

   (eller ALIAS/CNAME om leverandøren støtter det).
