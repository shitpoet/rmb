var log = console.log.bind(console)

if (chrome.management) {
  // background script
  //log('bg script')

  chrome.extension.onMessage.addListener(
    function(request, sender, sendResponse) {
      let tab = sender.tab
      if request.url
        chrome.tabs.create({
          index:    tab.index + 1,
          url:      request.url,
          selected: true, // fg / bg
          opener-tab-id: tab.id
        });
      else
        chrome.tabs.remove(tab.id)
    }
  )

} else {
  // content script
  //log('content script')

  const long-time = 130
  let press-time = 0
  let showing-menu = false
  let target-url

  fun open-link(url)
    chrome.runtime.sendMessage({url})

  fun show-context-menu()
    //log('show-context-menu ')
    showing-menu = true
    fetch('http://127.0.0.1:64727').then(function(r) {})

  fun close-tab()
    chrome.runtime.sendMessage({})

  fun mouseup(e)
    //log('mouseup',e)
    //window.removeEventListener('mouseup', mouseup, true)
    if !(e.altKey || e.ctrlKey || e.shiftKey)
      if e.button == 2 && target-url
        if showing-menu
          showing-menu = false
        else
          let delta = e.time-stamp - press-time
          //log('delta',delta)
          if delta < long-time
            open-link(target-url)
          else
            show-context-menu()
      elif e.button == 1
        close-tab()
    press-time = 0

  window.addEventListener('mouseup', mouseup, true)

  window.addEventListener('contextmenu', function(e) {
    //log('context-menu',e, showing-menu)
    if showing-menu
      return;
    press-time = e.time-stamp
    target-url = ''
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
            //log('link '+url)
            e.preventDefault();
            e.stopPropagation();
            target-url = url
            //window.addEventListener('mouseup', mouseup, true)
        return;
  }, true);

}


