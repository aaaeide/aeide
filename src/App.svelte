<script lang="ts">
  import TypoHeader from "./lib/TypoHeader.svelte";
</script>

<main>
  <TypoHeader title="Andreas Aaberge Eide" />

  <p>
    Hei og velkommen til min (Andreas) sin hjemmeside. Her kommer du sikkert til
    å kunne finne mer info om meg en gang i fremtiden, men inntil videre er
    denne siden under konstruksjon.
  </p>

  <p>
    Men altså herregud, enn så lenge er det jo såklart bare å sjekke ut meg og
    noen av prosjektene mine på
  </p>

  <!-- prettier-ignore -->
  <ul>
    <li><a href="https://github.com/aaaeide/">Github</a></li>
    <li><a href="https://www.linkedin.com/in/andreas-aaberge-eide-513078151/">Linkedin</a></li>
    <li><a href="https://radio.nrk.no/serie/jon-og-andreas-show">NRK P3</a></li>
    <li><a href="https://open.spotify.com/show/0q8VmcK5Zy76bqJVbbSda8?si=c4be9101f7ff48b3">Radio Revolt</a></li>
  </ul>
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
</style>
