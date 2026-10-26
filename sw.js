// Gjør at årshjulet virker uten nett.
// Henter alltid nyeste versjon når det er nett, og bruker lagret kopi ellers.
const CACHE = "arshjul-v2";
const FILES = ["./", "index.html", "config.js", "oppgaver.js", "manifest.json", "icon-192.png", "icon-512.png", "apple-touch-icon.png"];

self.addEventListener("install", e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(FILES)).then(() => self.skipWaiting()));
});

self.addEventListener("activate", e => {
  e.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", e => {
  if (e.request.method !== "GET") return;
  // Databasen (Supabase) og skrifter håndteres av nettleseren som vanlig.
  if (new URL(e.request.url).origin !== self.location.origin) return;
  const sameOrigin = true;
  e.respondWith(
    fetch(e.request)
      .then(res => {
        if (sameOrigin && res.ok) {
          const copy = res.clone();
          caches.open(CACHE).then(c => c.put(e.request, copy));
        }
        return res;
      })
      .catch(() => caches.match(e.request).then(r => r || caches.match("index.html")))
  );
});
