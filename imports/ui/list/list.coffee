{ Books, BookInstances } = require "/imports/collections/books.coffee"

require "/imports/ui/bookDisplay/bookDisplay.coffee"
require "./list.jade"

#Meteor.subscribe "BTC.list"

Template.list.viewmodel
  books : -> Books.find()
  loading : -> not @templateInstance.subscriptionsReady()
  autorun : ->
    @templateInstance.subscribe "BTC.list"
