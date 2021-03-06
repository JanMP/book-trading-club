{ Mongo } = require "meteor/mongo"
{ check } = require "meteor/check"
{ HTTP } = require "meteor/http"

Books = new Mongo.Collection "books"
Books.schema = new SimpleSchema
  googleId :
    type : String
  title :
    type : String
  authors :
    type : [String]
    optional : true
  imageLink :
    type : String
    optional : true
Books.attachSchema Books.schema
exports.Books = Books

BookInstances = new Mongo.Collection "bookinstances"
BookInstances.schema = new SimpleSchema
  bookId :
    type : String
  ownerId :
    type : String
  requesterId :
    type : String
    optional : true
  status :
    type : String
    allowedValues : [
      "available"
      "requested"
      "accepted"
    ]
BookInstances.attachSchema BookInstances.schema
exports.BookInstances = BookInstances

if Meteor.isServer

  Meteor.publish "BTC.list", ->
    Books.find()

  Meteor.publish "BTC.instances", (bookId) ->
    new SimpleSchema
      bookId :
        type : String
    .validate { bookId }
    BookInstances.find bookId : bookId

  Meteor.publish "BTC.myBooks", ->
    BookInstances.find ownerId : @userId

  Meteor.publish "BTC.myRequests", ->
    bookInstances = BookInstances.find
      requesterId : @userId
      status :
        $in : [ "requested", "accepted" ]
    requestIds = bookInstances.fetch().map (e) -> e.bookId
    books = Books.find
      _id :
        $in : requestIds
    [bookInstances, books]

  Meteor.publish "BTC.book", (bookId) ->
    new SimpleSchema
      bookId :
        type : String
    .validate { bookId }
    Books.find bookId

  request = new ValidatedMethod
    name : "BTC.request"
    validate :
      new SimpleSchema
        bookId :
          type : String
      .validator()
    run : ({ bookId }) ->
      unless @userId
        throw new Meteor.Error "BTC.request unauthorized"
      bookInstance = BookInstances.findOne
        bookId : bookId
        status : "available"
      BookInstances.update bookInstance._id,
        $set :
          requesterId : @userId
          status : "requested"

  cancelRequest = new ValidatedMethod
    name : "BTC.cancelRequest"
    validate :
      new SimpleSchema
        bookId :
          type : String
      .validator()
    run : ({ bookId }) ->
      unless @userId
        throw new Meteor.Error "BTC.cancelRequest unauthorized"
      BookInstances.update
        bookId : bookId
        requesterId : @userId
        status :
          $in : ["requested", "accepted"]
      ,
        $set :
          status : "available"

  acceptRequest = new ValidatedMethod
    name : "BTC.acceptRequest"
    validate :
      new SimpleSchema
        id :
          type : String
      .validator()
    run : ({ id }) ->
      unless @userId
        throw new Meteor.Error "BTC.acceptRequest unauthorized"
      book = BookInstances.findOne id
      unless book.ownerId is @userId
        throw new Meteor.Error "BTC.acceptRequest not Owner"
      BookInstances.update id,
        $set :
          status : "accepted"

  rejectRequest = new ValidatedMethod
    name : "BTC.rejectRequest"
    validate :
      new SimpleSchema
        id :
          type : String
      .validator()
    run : ({ id }) ->
      unless @userId
        throw new Meteor.Error "BTC.rejectRequest unauthorized"
      book = BookInstances.findOne id
      unless book.ownerId is @userId
        throw new Meteor.Error "BTC.rejectRequest not Owner"
      BookInstances.update id,
        $set :
          status : "available"

  removeBook = new ValidatedMethod
    name : "BTC.removeBook"
    validate :
      new SimpleSchema
        id :
          type : String
      .validator()
    run : ({ id }) ->
      unless @userId
        throw new Meteor.Error "BTC.removeBook unauthorized"
      book = BookInstances.findOne id
      bookId = book.bookId
      unless book.ownerId is @userId
        throw new Meteor.Error "BTC.removeBook not Owner"
      BookInstances.remove id, (error) ->
        if error then throw error
        if bookId?
          bookInstance = BookInstances.findOne bookId : bookId
          unless bookInstance?
            Books.remove bookId


  addBook = new ValidatedMethod
    name : "BTC.addBook"
    validate :
      new SimpleSchema
        googleId :
          type : String
      .validator()
    run : ({ googleId }) ->
      unless @userId
        throw new Meteor.Error "BTC.addBook unauthorized",
          "user must be logged in to add a Book"
      url = "https://www.googleapis.com/books/v1/volumes/"
      console.log "addBook: #{googleId}"
      HTTP.get "#{url}#{googleId}", (error, result) =>
        if error
          console.log error
          throw new Meteor.Error "BTC.addBook HTTP.get error",
            "there was an error while getting data from Google Books"
        api = result?.data?.volumeInfo
        Books.upsert
          googleId : googleId
        ,
          $set :
            googleId : googleId
            title : api?.title
            authors : api?.authors
            imageLink : api?.imageLinks?.thumbnail
        ,
          (error, n) =>
            book = Books.findOne googleId : googleId
            unless book
              throw new Meteor.Error "BTC.addBook book not found",
              "no book with { googleId : #{googleId} } in the db"
            unless n.numberAffected is 1
              console.log "There are #{n.numberAffected} db eintries
              for: #{book.title}"
            BookInstances.insert
              bookId : book._id
              ownerId : @userId
              status : "available"
