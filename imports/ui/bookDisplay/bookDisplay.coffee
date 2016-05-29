{ Books, BookInstances } = require "/imports/collections/books.coffee"

require "./bookDisplay.jade"

Template.bookDisplay.viewmodel
  myOwn : ->
    myOwn = BookInstances.findOne
      bookId : @_id()
      ownerId : Meteor.userId()
    myOwn?
  availableCount : ->
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
  available : ->
    @availableCount() > 0 and not @requesting() and
      not @accepted() and not @myOwn()
  mayRequest : -> @available() and Meteor.userId()?
  mayCancelRequest : -> Meteor.userId()? and
    ( @requesting() or @accepted() )
  request : ->
    Meteor.call "BTC.request", bookId : @_id()
  cancelRequest : ->
    Meteor.call "BTC.cancelRequest", bookId : @_id()
  info : ->
    #Done:0 add usefull functionality to info button
    window.open("https://books.google.com/books?id=#{@googleId()}")
  onCreated : ->
    @templateInstance.subscribe "BTC.instances", @_id()
  onRendered : ->
    @imageRef.popup
      inline : true
      hoverable : true
      position : "bottom center"
      distanceAway : -80
      on : "click"
