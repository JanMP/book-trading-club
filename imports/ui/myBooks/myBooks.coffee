{ HTTP } = require "meteor/http"
{ Books, BookInstances } = require "/imports/collections/books.coffee"

require "./myBooks.jade"
require "/imports/ui/list/list.coffee"

url = "https://www.googleapis.com/books/v1/volumes?q="

Template.myBooks.viewmodel
  books : -> BookInstances.find ownerId : Meteor.userId()

Template.addBook.viewmodel
  query : ""
  results : []
  search : ->
    if @query() is ""
      @results []
    else
      HTTP.get "#{url}#{@query()}", (error, result) =>
        unless error
          console.log result
          @results result.data.items

Template.bookPreview.viewmodel
  addBook : ->
    Meteor.call "BTC.addBook", googleId : @id()

Template.myBookDisplay.viewmodel
  book : -> Books.findOne @bookId()
  available : -> @status() is "available"
  requested : -> @status() is "requested"
  accepted : -> @status() is "accepted"
  reject : ->
    Meteor.call "BTC.rejectRequest", id : @_id()
  accept : ->
    Meteor.call "BTC.acceptRequest", id : @_id()
  remove : ->
    Meteor.call "BTC.removeBook", id : @_id()
  onRendered : ->
    @imageRef.popup
      inline : true
      hoverable : true
      position : "bottom center"
      distanceAway : -80
      on : "click"

Template.myRequests.viewmodel
  requests : ->
    requestIds =
      BookInstances.find
        requesterId : Meteor.userId()
        status :
          $in : [ "requested", "accepted" ]
      .fetch()
      .map (e) -> e.bookId
    Books.find
      _id :
        $in : requestIds
  gotRequests : ->
    @requests().count() > 0
