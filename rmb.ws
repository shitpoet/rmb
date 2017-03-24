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
  const min-delta = 32
  let active = false
  let press-time = 0
  let down = [false,false,false]
  let eat-rmb = false
  let rocket = false
  let showing-menu = false
  let target-url
  let timer
  let start-x, delta-x
  let start-y, delta-y

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

  fun is_rmb_down(e)
    ret e.buttons & 4 != 0

  fun mousedown(e)
    log('mousedown', e, e.button, {down})
    clear-timeout(timer)
    if !(e.altKey || e.ctrlKey || e.shiftKey)
      if e.button == lmb && down[rmb]
        stop-event(e)
        eat-rmb = true
        rocket = true
    down[e.button] = true

  fun mouseup(e)
    //clear-timeout(timer)
    clear-timeout(timer)
    log('mouseup', e.button, {active, target-url, showing-menu})
    //window.removeEventListener('mouseup', mouseup, true)
    if !(e.altKey || e.ctrlKey || e.shiftKey)

      if e.button == rmb
        if eat-rmb
          if rocket
            rocket = false
            if active
              duplicate-tab()
          eat-rmb = false
        elif !down[lmb]
          stop-timer()
          let delta = e.time-stamp - press-time
          log('delta',delta,{delta-x,delta-y})
          let adx = Math.abs(delta-x), ady = Math.abs(delta-y)
          if adx > min-delta || ady > min-delta
            if adx > ady
              if delta-x < 0
                go-back()
              else
                goto-right-tab()
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
      /*elif e.button == 1
        close-tab()*/
    down[e.button] = false
    press-time = 0

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
    if active
      delta-x = e.x - start-x
      delta-y = e.y - start-y
      log({delta-x,delta-y,start-x,start-y})

  fun stop-timer()
    //active = false
    //window.removeEventListener('mousewheel', mousewheel, true)
    window.removeEventListener('mousemove', mousemove, true)
    clear-timeout(timer)

  fun start-timer(e)
    clear-timeout(timer)
    active = true
    timer = set-timeout(timeout, wait-time)
    start-x = e.x
    start-y = e.y
    delta-x = 0
    delta-y = 0
    window.addEventListener('mousemove', mousemove, true)
    //window.addEventListener('mousewheel', mousewheel, true)

  fun timeout()
    log('timeout')
    stop-timer()
    active = false

  fun contextmenu(e)
    log('context-menu', showing-menu)
    stop-timer()

    // if have selection and cursor is over it just show menu
    let sel = window.getSelection()
    if sel.toString()
      log('have selection',sel,'node',sel.focusNode,'target',e.target)
      let sel-node = sel.focus-node
      let target = e.target
      if sel-node == target || sel-node.parent-element == target
        log('click on selection')
        showing-menu = true

    if showing-menu
      showing-menu = false
      eat-rmb = true
      active = false
      return;

    press-time = e.time-stamp
    target-url = ''
    active = true
    stop-event(e)

    for el of e.path
      if el instanceof HTMLAnchorElement
        if 'href' in el
          let url = (''+el.href).trim()
          if (
            url &&
            !url.startsWith('javascript:') &&
            !url.startsWith('tel:') &&
            !url.startsWith('mailto:')
          )
            log('link '+url)
            //stop-event(e)
            target-url = url

            //window.addEventListener('mouseup', mouseup, true)
        return;

    start-timer(e)

  window.addEventListener('mousedown', mousedown, true)
  window.addEventListener('mouseup', mouseup, true)
  window.addEventListener('contextmenu', contextmenu, true);

}


