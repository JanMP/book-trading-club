require "./layout.jade"
require "/imports/navbar/navbar.jade"
require "/imports/list/list.coffee"
require "/imports/myBooks/myBooks.coffee"

FlowRouter.route "/",
  name : "home"
  action : ->
    BlazeLayout.render "layout",
      main : "list"

FlowRouter.route "/my-books",
  name : "myBooks"
  action : ->
    BlazeLayout.render "layout",
      main : "myBooks"

FlowRouter.route "/add-book",
  name : "addBook"
  action : ->
    BlazeLayout.render "layout",
      main : "addBook"

FlowRouter.route "/info",
  name : "info"
  action : ->
    BlazeLayout.render "layout",
      main : "info"

FlowRouter.route "/settings",
  name : "settings"
  action : ->
    BlazeLayout.render "layout",
      main : "settings"

FlowRouter.route "/help",
  name : "help"
  action : ->
    BlazeLayout.render "layout",
      main : "help"
