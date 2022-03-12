// для удаления в google photos

document.addEventListener("keyup", function (e) {
  // if (e.altKey && e.code !== "KeyD") {
  if (e.code !== "KeyD") {
    return;
  }
  let sel = 'div [role="menubar"] span div [aria-label="Delete"]'
  let nodes = document.querySelectorAll(sel)

  if (nodes.length !== 1) {
    console.warn("найдено больше одной ноды ", nodes)
    return
  }
  let node = nodes[0]
  node.click()

  let fn = function () {
    let txt = 'Move to trash'
    let node = null

    nodes = document.querySelectorAll('span')
    nodes.forEach(el => {
      if (el.innerHTML !== txt) {
        return;
      }

      let rect = el.getBoundingClientRect()
      if (rect.width === 0 || rect.height === 0) {
        return;
      }

      if (node !== null) {
        console.warn(`Найдено больше одной кнопки '${txt}'`, el)
        return;
      }

      // console.log(`Найдена первая кнопка '${txt}'`, el)
      node = el
    })

    if (node == null) {
      console.warn(`Не найдена кнопка '${txt}'`)
      return;
    }

    // console.log("end")
    node.click()
  }

  setTimeout(fn, 100)
})
