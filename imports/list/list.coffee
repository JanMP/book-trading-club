{ Books, BookInstances } = require "/imports/collections/books.coffee"

require "./list.jade"

Template.list.viewmodel
  books : -> Books.find()

Template.bookDisplay.viewmodel
  myOwn : ->
    myOwn = BookInstances.findOne
      bookId : @_id()
      ownerId : Meteor.userId()
    myOwn?
  available : ->
    count = BookInstances
      .find
        bookId : @_id()
        status : "available"
      .count()
  requesting : ->
    request = BookInstances.findOne
      bookId : @_id()
      requesterId : Meteor.userId()
      status : "requested"
    request?
  accepted : ->
    accepted = BookInstances.findOne
      bookId : @_id()
      requesterId : Meteor.userId()
      status : "accepted"
    accepted?
  isAvailable : ->
    @available() > 0 and not @requesting() and not @accepted() and not @myOwn()
  request : ->
    Meteor.call "BTC.request", bookId : @_id()
  info : ->
    alert "I want to know more about this book."
  onRendered : ->
    @imageRef.popup
      inline : true
      hoverable : true
      position : "bottom center"
      distanceAway : -80
      on : "click"
