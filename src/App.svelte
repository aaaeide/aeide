<script lang="ts">
  import TypoHeader from "./lib/TypoHeader.svelte";
</script>

<main>
  <TypoHeader title="Andreas Aaberge Eide" />

  <p>
    Hei og velkommen til min (Andreas sin) hjemmeside. På denne sporadisk oppdaterte nettsiden kan du finne informasjon om hva jeg holder og har holdt på med. Hvis du vurderer å ansette meg til en jobb jeg har søkt på vil jeg gjerne også henvise til min <a href="https://github.com/aaaeide/">Github</a> og <a href="https://www.linkedin.com/in/andreas-aaberge-eide-513078151/">Linkedin</a> -- på sistnevnte har jeg referanser! Det liker dere.
  </p>

  <hr />

  <p>
    For øyeblikket (vår 2023) skriver jeg en masteroppgave i Datateknologi med tittelen "Matroids and Fair Allocation". Ekstremt spesielt interesserte folk kan sjekke den ut <a href="https://github.com/aaaeide/MASTER_2023/blob/main/article.pdf">HER</a>. I den anledning lager jeg et Julia-bibliotek for å tilfeldig generere og interagere med disse matroidene, det finnes <a href="https://github.com/aaaeide/Matroids.jl">HER</a>. Det hele er veldig WIP. Ikke se for nøye.
  </p>

  <p>
    Av tidligere prosjekter har jeg en startup under beltet ved navn Mestr. Den er delvis lagt på is for tiden, men er fortsatt et prosjekt jeg er veldig stolt av. Sjekk det ut <a href="https://mestr.no/">HER</a>! Ikke let for nøye etter bugs.
  </p>

  <p>
    Jeg har også laget en del radio og podkast opp igjennom. Utelukkende tull og fjas. For det meste studentradioprogrammet <a href="https://open.spotify.com/show/0q8VmcK5Zy76bqJVbbSda8?si=c4be9101f7ff48b3">Skrøneriet på Radio Revolt</a>, men en stakket stund fikk jeg også betalt for å lage <a href="https://radio.nrk.no/serie/jon-og-andreas-show">Jon og Andreas Show på NRK P3</a>.
  </p>
</main>

<style>
  :root {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen,
      Ubuntu, Cantarell, "Open Sans", "Helvetica Neue", sans-serif;
    background-color: black;
    color: white;
  }

  main {
    border: 1px solid orange;
    padding: 1em;
    max-width: 400px;
  }

  a {
    color: orange;
  }

  hr {
    border: none;
    border-top: 1px solid orange;
  }
</style>
