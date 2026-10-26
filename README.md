# Ort årshjul

Interaktivt årshjul som nettside, publisert med GitHub Pages.

- `index.html` er selve nettsiden. Den trenger du ikke røre.
- `oppgaver.js` er oppgavelista. Rediger denne for å endre innholdet.

## Slik publiserer du med GitHub Desktop

1. Pakk ut mappa `arshjul` et sted på maskinen.
2. I GitHub Desktop velger du **File → Add local repository** og velger mappa. Svar ja når den spør om å lage et repository (**create a repository**).
3. Lag første commit med meldingen «Første versjon av årshjulet», og trykk **Publish repository**. Fjern haken for **Keep this code private**, siden gratis GitHub Pages krever et offentlig repo.
4. På github.com går du til repoet, så **Settings → Pages**. Under **Branch** velger du `main` og `/ (root)`, og trykker **Save**.
5. Etter 1–2 minutter ligger siden på `https://<brukernavn>.github.io/arshjul/`.

## Redigering på siden (Supabase)

1. Lag gratis konto på supabase.com og opprett et prosjekt (velg region i EU, f.eks. Frankfurt eller Stockholm).
2. Åpn `supabase-oppsett.sql`, bytt `BYTT-MEG-TIL-EN-LANG-KODE` med seksjonens kode, og kjør hele fila i **SQL Editor**.
3. Hent **Project URL** og **Publishable key** (Project Settings → API) og lim dem inn i `config.js`.
4. Last opp `config.js` til GitHub. Nå får siden en **Rediger**-knapp.

Bytte kode senere: kjør linja nederst i `supabase-oppsett.sql` i SQL Editor.
Gratisprosjekter settes på pause etter en uke uten bruk. Da trykker du **Restore** i Supabase.

## Filene

- `index.html` – selve årshjulet
- `config.js` – kobling til databasen
- `supabase-oppsett.sql` – oppsett av databasen (kjøres én gang i Supabase)
- `oppgaver.js` – reserveinnhold som vises hvis databasen ikke er koblet til
- `manifest.json`, `sw.js` og ikonene – gjør at siden kan installeres som app og virker uten nett

## Som app på mobilen

- **iPhone:** åpne siden i Safari → del-knappen → **Legg til på Hjem-skjerm**
- **Android:** åpne siden i Chrome → menyen (⋮) → **Installer app** / **Legg til på startskjermen**

Appen henter nyeste versjon hver gang den åpnes med nett. Uten nett vises sist lagrede versjon.

## I Teams og SharePoint

- **Teams:** i kanalen trykker du **+** ved fanene → **Nettsted** → lim inn adressen.
- **SharePoint/intranett, lenke:** bruk webdelen **Hurtigkoblinger** eller **Knapp** og lim inn adressen.
- **SharePoint, vist direkte på siden:** bruk webdelen **Innebygging**. Det krever at nettstedsadministrator har tillatt `drakir-dev.github.io` under *HTML-feltsikkerhet*.

## Slik endrer du oppgaver

1. Åpne `oppgaver.js` i en teksteditor, for eksempel VS Code eller Notisblokk.
2. Endre, legg til eller slett linjer. Følg samme mønster og husk komma på slutten av hver linje.
3. Lag en commit i GitHub Desktop og trykk **Push origin**. Siden oppdateres etter et minutt eller to.

Du kan også redigere fila direkte på github.com: åpne fila, klikk blyanten og velg **Commit changes**.

## Greit å vite

- Siden er offentlig. Ikke legg inn pasientopplysninger, navn eller annet internt.
- Når databasen er koblet til, gjøres alle endringer på selve siden med **Rediger**.
- Bruk aldri «secret»- eller «service_role»-nøkkelen i `config.js`.
- Du kan åpne `index.html` direkte fra mappa for å se endringer før du pusher.
