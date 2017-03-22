//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIm1haW4ud3MiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IjtJQUFJLEFBQUksTUFBRSxBQUFPLEFBQUksQUFBSyxRQUFSLElBQUksS0FBSztJQUV2QixBQUFNLE9BQUM7RUFJVCxBQUFNLEFBQVUsQUFBVSxBQUFZLEtBQS9CLFVBQVUsVUFBVSxZQUN6QixVQUFTLEFBQU8sQUFBUSxTQUFOLFFBQVE7SUFDcEIsQUFBSSxNQUFFLEFBQU0sT0FBQztJQUNkLEFBQU8sUUFBQztNQUNULEFBQU0sQUFBSyxBQUFPLENBQVgsS0FBSztPQUNBLEFBQUcsQUFBTyxDQUFwQixBQUFLLEFBQWtCLEFBQ0YsQUFDUCxHQUZBLFFBQVE7S0FDWixBQUFPLEdBQWpCLEFBQUcsS0FBZTtRQUNsQixBQUFRLEVBQUUsTUFDVixBQUFhLGFBQUUsQUFBRyxJQUFDOzs7TUFHckIsQUFBTSxBQUFLLEFBQU8sQ0FBWCxLQUFLLE9BQU8sQUFBRyxJQUFDOzs7O01BUXZCLEFBQVUsV0FBRTtJQUNkLEFBQVcsWUFBRTtJQUNiLEFBQWEsY0FBRTtJQUNmO0VBRUosZ0JBQWM7SUFDWixBQUFNLEFBQVEsQUFBWSxHQUFuQixRQUFRO01BQWE7OztFQUU5QjtJQUVFLEFBQWEsVUFBRTtJQUNmLEFBQUssQUFBMEIsQUFBSyxFQUE5QiwwQkFBMEIsS0FBSyxVQUFTOzs7RUFFaEQ7SUFDRSxBQUFNLEFBQVEsQUFBWSxHQUFuQixRQUFROzs7RUFFakIsZUFBWTtJQUdQLENBQXdCLENBQXRCLEFBQUMsQUFBUSxFQUFQLFVBQVUsQUFBQyxFQUFDLFdBQVcsQUFBQyxFQUFDO0lBQzNCLEFBQUMsQUFBUSxBQUFLLEVBQVosVUFBVSxLQUFLO0lBQ2Y7VUFDRCxBQUFhLElBQUU7O0lBRVgsQUFBTSxRQUFFLEFBQUMsQUFBWSxFQUFYLFlBQWE7SUFFeEIsQUFBTSxRQUFFO1NBQ0MsR0FBVixBQUFTOztZQUVULEFBQWlCOzs7V0FDbEIsQUFBQyxBQUFRLEVBQVAsVUFBVTtRQUNmLEFBQVM7OztJQUNiLEFBQVcsUUFBRTs7RUFFZixBQUFNLEFBQWlCLEtBQWhCLGlCQUFpQixBQUFTLEFBQVMsV0FBUCxTQUFTO0VBRTVDLEFBQU0sQUFBaUIsS0FBaEIsaUJBQWlCLEFBQWEsQUFzQnBDLGVBdEJzQyxVQUFTO0lBRTNDOzs7SUFFSCxBQUFXLFFBQUUsQUFBQyxFQUFDO0lBQ2YsQUFBVyxRQUFFO1NBQ1QsQUFBRyxNQUFHLEFBQUMsRUFBQztJQUNQLEFBQUcsY0FBVztJQUNaLEFBQU8sVUFBRztJQUNQLEFBQUksTUFBSyxBQUFTLEFBQUssQ0FBaEIsS0FBRyxBQUFFLEdBQUMsTUFBTTtJQUVyQixBQUFJLEFBQzJCLEFBQ1A7Q0FEdkIsQUFBRyxBQUFXLElBQVYsS0FBTCxNQUFnQjtDQUNmLEFBQUcsQUFBVyxJQUFWLEtBQUwsTUFBZ0I7Q0FDZixBQUFHLEFBQVcsSUFBVixLQUFMLE1BQWdCO0VBR2QsVUFBRixBQUFDLEFBQWU7RUFDZCxVQUFGLEFBQUMsQUFBZ0I7WUFDakIsQUFBVyxBQUFFOzs7Ozs7R0FHcEIiLCJmaWxlIjoibWFpbi5qcyJ9
var log = console.log.bind(console)
if (chrome.management) {  
  chrome.extension.onMessage.addListener(function (request, sender, sendResponse) {  
    let tab = sender.tab
    if (request.url) {  
      chrome.tabs.create({  
        index: tab.index + 1, 
        url: request.url, 
        selected: true, openerTabId: tab.id
      })
    } else {  
      chrome.tabs.remove(tab.id)
    }
  })
} else {  
  const longTime = 130
  let pressTime = 0
  let showingMenu = false
  let targetUrl
  function openLink(url) {  
    chrome.runtime.sendMessage({  
      url
    })
  }
  function showContextMenu() {  
    showingMenu = true
    fetch('http://127.0.0.1:64727').then(function (r) {
    })
  }
  function closeTab() {  
    chrome.runtime.sendMessage({
    })
  }
  function mouseup(e) {  
    if (!(e.altKey || e.ctrlKey || e.shiftKey)) {  
      if (e.button == 2 && targetUrl) {  
        if (showingMenu) {  
          showingMenu = false
        } else {  
          let delta = e.timeStamp - pressTime
          if (delta < longTime) {  
            openLink(targetUrl)
          } else {  
            showContextMenu()
          }
        }
      } else if (e.button == 1) {  
        closeTab()
      }
    }
    pressTime = 0
  }
  window.addEventListener('mouseup', mouseup, true)
  window.addEventListener('contextmenu', function (e) {  
    if (showingMenu) {  
      return 
    }
    pressTime = e.timeStamp
    targetUrl = ''
    for (let el of e.path) {  
      if (el instanceof HTMLAnchorElement) {  
        if ('href' in el) {  
          let url = ('' + el.href).trim()
          if (url && 
          !url.startsWith('javascript:') && 
          !url.startsWith('tel:') && 
          !url.startsWith('mailto:')) {  
            e.preventDefault()
            e.stopPropagation()
            targetUrl = url
          }
        }
        return 
      }
    }
  }, true)
}