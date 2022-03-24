<script>
  export let title = "no title given"
  title = addTypo(title)
  let chars = []

  function next(i) {
    chars = [...chars, title[i]]

    if (i<title.length-1) {
      let ms = (title[i] == " " ? 1000 : 200) * (0.5 + Math.random())
      setTimeout(() => next(i+1), ms)
    } else {
      setTimeout(() => prev(i), 3000)
    }
  }

  function prev(i) {
    chars.pop()
    chars = chars

    if (i>0) {
      let ms = 125 + 50 * -Math.random()
      setTimeout(() => prev(i-1), ms)
    } else {
      title = addTypo(title)
      setTimeout(() => next(i), 1500)
    }
  }

  function addTypo(txt) {
    if (Math.random() > 0) {
      let randIdx = (len) => Math.floor(Math.random() * len)
      let i = randIdx(txt.length-1)

      txt = txt.slice(0, i) + txt[i+1] 
            + txt[i] + txt.slice(i+2)
      
      txt = txt.split(" ")
        .map((wd) => wd.toLowerCase())
        .map((wd) => wd.charAt(0).toUpperCase() + wd.slice(1))
        .join(" ")
    }

    return txt
  }

  next(0)
</script>

<h1>{chars.join("")}</h1>

<style>
  /* From https://css-tricks.com/snippets/css/typewriter-effect/ */

  h1 {
    font-family: monospace;
    border-right: .15em solid orange; /* The typwriter cursor */
    white-space: nowrap; /* Keeps the content on a single line */
    width: min-content;
    animation: 
      blink-caret 1s step-end infinite;
  }

  h1::before {
    content: ' ';
    display: inline-block;
    width: 0em;
  }

  /* The typewriter cursor effect */
  @keyframes blink-caret {
    from, to { border-color: transparent }
    50% { border-color: orange; }
  }

</style>