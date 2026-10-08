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

## Slik endrer du oppgaver

1. Åpne `oppgaver.js` i en teksteditor, for eksempel VS Code eller Notisblokk.
2. Endre, legg til eller slett linjer. Følg samme mønster og husk komma på slutten av hver linje.
3. Lag en commit i GitHub Desktop og trykk **Push origin**. Siden oppdateres etter et minutt eller to.

Du kan også redigere fila direkte på github.com: åpne fila, klikk blyanten og velg **Commit changes**.

## Greit å vite

- Siden er offentlig. Ikke legg inn pasientopplysninger, navn eller annet internt.
- Siden er bare til visning. Alle endringer gjøres i `oppgaver.js`.
- Du kan åpne `index.html` direkte fra mappa for å se endringer før du pusher.
