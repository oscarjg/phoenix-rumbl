import Player from "./player"

let Video = {

  init(socket, element){
    if(!element){
      return
    }

    let playerId = element.getAttribute("data-player-id")
    let videoId  = element.getAttribute("data-id")

    socket.connect()

    Player.init(element.id, playerId, () => {
      this.onReady(videoId, socket)
    })
  },

  onReady(videoId, socket){
    let msgContainer = document.getElementById("msg-container")
    let msgInput     = document.getElementById("msg-input")
    let postButton   = document.getElementById("msg-submit")
    let vidChannel   = socket.channel("videos:" + videoId)

    postButton.addEventListener("click", event => {
      let payload = {
        body: msgInput.value,
        at: Player.getCurrentTime()
      }

      vidChannel.push("new_annotation", payload)
        .receive("error", reason => console.log("new_annotation error", reason))

      msgInput.value = "";
    })

    msgContainer.addEventListener("click", event => {
      let seconds = event.target.getAttribute("data-seek") ||
                    event.target.parentNode.getAttribute("data-seek")

      if (!seconds) {
        return
      }

      Player.seekTo(seconds)
    })

    vidChannel.on("new_annotation", resp => {
      this.renderAnnotation(msgContainer, resp)
    })

    vidChannel.join()
      .receive("ok", resp => {
        console.log("joined!", resp)

        this.scheduleAnnotations(msgContainer, resp.annotations)
      })
      .receive("error", reason => console.log("error!", reason))
  },

  esc(str){
    let div = document.createElement("div")
    div.appendChild(document.createTextNode(str))
    return div.innerHTML
  },

  renderAnnotation(msgContainer, {user, body, at}){
    let template = document.createElement("div")

    template.innerHTML = `
    <a href="#" data-seek="${this.esc(at)}">
      [${this.formatTime(at)}]
      <b>${this.esc(user.username)}</b>: ${this.esc(body)}
    </a>
    `
    msgContainer.appendChild(template)
    msgContainer.scrollTop = msgContainer.scrollHeight
  },

  scheduleAnnotations(msgContainer, annotations) {
    clearTimeout(this.scheduleTimeout)
    this.scheduleTimeout = setTimeout(() => {
      let remaining = this.renderAtTime(annotations, Player.getCurrentTime(), msgContainer)
      this.scheduleAnnotations(msgContainer, remaining)
    } , 1000)
  },

  renderAtTime(annotations, seconds, msgContainer) {
    return annotations.filter((ann) => {
      if (ann.at > seconds) {
        return true
      } else {
        this.renderAnnotation(msgContainer, ann)
        return false
      }
    })
  },

  formatTime(at){
    let date = new Date(null)
    date.setSeconds(at / 1000)
    return date.toISOString().substr(14, 5)
  },
}

export default Video