//var log = console.log.bind(console)

fun log()
  let args = Array.prototype.slice.call(arguments)
  args.unshift('rmb')
  console.log.apply(null, args)

log('v0.2')

if (chrome.management) {
  // background script
  //log('bg script')

  chrome.extension.onMessage.addListener(
    function(request, sender, sendResponse) {
      let tab = sender.tab
      if request.open
        chrome.tabs.create({
          index:    tab.index + 1,
          url:      request.url,
          selected: true, // fg / bg
          opener-tab-id: tab.id
        });
      elif request.duplicate
        chrome.tabs.duplicate(tab.id)
      elif request.close
        chrome.tabs.remove(tab.id)
      elif request.goto-left-tab || request.goto-right-tab
        chrome.tabs.query({current-window: true}, fun(tabs) {
          let n = tabs.length
          let index = tab.index + (request.goto-left-tab ? -1 : 1);
          if index < 0 index = n - 1
          elif index >= n index = 0
          chrome.tabs.update(tabs[index].id, {active: true});
        })
      else
        log('unknown request',request)
    }
  )

} else {
  // content script

  const lmb = 0, mmb = 1, rmb = 2 // mouse buttons
  const open-time = 140
  const wait-time = 300
  const min-delta = 16
  let active = false
  let press-time = 0
  let down = [false,false,false]
  //let eat-rmb = false
  let showing-menu = false
  let target-url
  let timer
  /*let start-x, sum-x, delta-x
  let start-y, sum-y, delta-y*/
  let start-x, last-x, sum-x, delta-x
  let start-y, last-y, sum-y, delta-y

  fun stop-event(e)
    e.preventDefault()
    e.stopPropagation()

  fun execute(opts)
    chrome.runtime.sendMessage(opts)

  fun open-link(url)
    execute({open: true, url})

  fun show-context-menu()
    log('show-context-menu ')
    showing-menu = true
    fetch('http://127.0.0.1:64727').then(function(r) {})

  fun close-tab()
    execute({close: true})

  fun duplicate-tab()
    execute({duplicate: true})

  fun go-back()
    log('go-back')
    history.back()

  fun goto-left-tab()
    log('goto-left-tab')
    execute({goto-left-tab: true})

  fun goto-right-tab()
    log('goto-right-tab')
    execute({goto-right-tab: true})

  fun refresh()
    location.reload()

  /*fun is_rmb_down(e)
    ret e.buttons & 4 != 0*/

  fun mousedown(e)
    log('mousedown', e, e.button, {down})
    down[e.button] = true

  /*fun mousewheel(e)
    if down[rmb]
      log('mousewheel',e)
      let delta = e.delta-y
      stop-timer()
      active = false
      eat-rmb = true
      stop-event(e)
      if delta < 0 // up
        goto-left-tab()
      else
        goto-right-tab()*/

  fun mousemove(e)
    log('mousemove')
    if active
      let x = e.x, y = e.y
      delta-x = x - start-x
      delta-y = y - start-y
      /*sum-x += Math.abs(e.movement-x)
      sum-y += Math.abs(e.movement-y)*/
      sum-x += Math.abs(x - last-x)
      sum-y += Math.abs(y - last-y)
      last-x = x
      last-y = y
      log({delta-x,delta-y,start-x,start-y})

  fun mouseup(e)
    log('mouseup', e.button, {active, target-url, showing-menu})
    if active && e.button==rmb && !(e.altKey || e.ctrlKey || e.shiftKey)
      stop()
      let delta = e.time-stamp - press-time
      log('delta',delta,{delta-x,delta-y,sum-x,sum-y})
      let adx = Math.abs(delta-x), ady = Math.abs(delta-y)
      if /*adx > 0 && ady > 0 &&*/ (sum-x > min-delta || sum-y > min-delta || adx > min-delta || ady > min-delta)
        let k = .75
        if sum-x > sum-y //adx > ady
          log('kx',sum-x / adx, adx, sum-x)
          if sum-x > 0 && adx / sum-x < k
            go-back()
          else
            if delta-x < 0
              goto-left-tab()
            else
              goto-right-tab()
        else
          log('ky',sum-y / ady, ady, sum-y)
          if sum-y > 0 && ady / sum-y < k
            refresh()
          else
            if delta-y < 0
              duplicate-tab()
            else
              close-tab()
      else
        if delta < open-time && target-url
          open-link(target-url)
        else
          show-context-menu()
      stop-event(e)
    down[e.button] = false

  fun stop()
    if active
      active = false
      //window.removeEventListener('mousewheel', mousewheel, true)
      window.removeEventListener('mousemove', mousemove, true)

  fun start(e, capture)
    active = true
    press-time = e.time-stamp
    start-x = e.x
    start-y = e.y
    last-x = start-x
    last-y = start-y
    delta-x = 0
    delta-y = 0
    sum-x = 0
    sum-y = 0
    if capture
      window.addEventListener('mousemove', mousemove, true)
    //window.addEventListener('mousewheel', mousewheel, true)

  /*fun timeout()
    log('timeout')
    active = false*/

  fun cursor-at-selection(e)
    let sel = window.getSelection()
    if sel.toString()
      log('have selection',sel,'node',sel.focusNode,'target',e.target)
      let sel-node = sel.focus-node
      let target = e.target
      if sel-node == target || sel-node.parent-element == target
        log('click on selection')
        ret true

  fun get-link-under-cursor(e)
    for el of e.path
      if el instanceof HTMLAnchorElement
        if 'href' in el
          let url = (''+el.href).trim()
          if (url &&
            !url.startsWith('javascript:') &&
            !url.startsWith('tel:') &&
            !url.startsWith('mailto:')
          ) ret url

  fun contextmenu(e)
    log('context-menu', showing-menu)
    stop()

    if showing-menu || cursor-at-selection(e)
      showing-menu = false
      //eat-rmb = true
      active = false
      ret; // show menu through default handler

    stop-event(e)
    target-url = ''

    let url = get-link-under-cursor(e)
    if url
      log('link '+url)
      target-url = url
      start(e, false)
      ret;

    start(e, true)

  window.addEventListener('mousedown', mousedown, true)
  window.addEventListener('mouseup', mouseup, true)
  window.addEventListener('contextmenu', contextmenu, true);

}


