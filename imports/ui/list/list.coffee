{ Books, BookInstances } = require "/imports/collections/books.coffee"

require "/imports/ui/bookDisplay/bookDisplay.coffee"
require "./list.jade"

Template.list.viewmodel
  books : -> Books.find()
  loading : -> not @templateInstance.subscriptionsReady()
  onCreated : ->
    @templateInstance.subscribe "BTC.list"
