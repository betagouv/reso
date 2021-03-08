(function () {
  addEventListener('turbo:load', function() {
    let feedbackLinks = document.getElementsByClassName( 'show-feedbacks-form' )
    for ( let i = 0; i < feedbackLinks.length; i++ ) {
      const feedbackLink = feedbackLinks[i];
      feedbackLink.onclick = function() {
        const feedbackableId = feedbackLink.dataset.feedbackable
        const form = document.getElementById("feedback-form-" + feedbackableId)
        form.style.display = 'block'
      }
    }
  })
})()
