require "/imports/ui/addressForm/addressForm.coffee"
require "./settings.jade"

Template.settings.viewmodel
  address : ->
    Meteor.user()?.profile?.address or
      firstName : ""
      lastName : ""
      streetAddress : ""
      postalCode : ""
      city : ""
      state : ""
      country : ""
