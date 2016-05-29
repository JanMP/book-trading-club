require "./addressForm.jade"
_ = require "/node_modules/lodash"
{ countries, states } = require "./countries.coffee"

Template.addressForm.viewmodel
  #our properties
  firstName :
    ViewModel.property.string.notBlank
      .validMessage "Looks good"
      .invalidMessage "can't be blank"
  lastName : ViewModel.property.string.notBlank
  streetAddress : ViewModel.property.string.notBlank
  postalCode : ViewModel.property.string.notBlank
  city : ViewModel.property.string.notBlank
  state : ViewModel.property.string.validate (value) ->
    @country() isnt "United States" or value
  country : ViewModel.property.string.notBlank
  # the options for the selects:
  countries : countries
  states : states
  stateEnabled : -> @country() is "United States"
  countryChanged : ->
    unless @country() is "United States"
      @state ""
  saveEnabled : ->
    @firstName.valid() and @lastName.valid() and
    @streetAddress.valid() and @postalCode.valid() and
    @city.valid() and @state.valid() and @country.valid()
  save : (event) -> #Done:30 handle validation errors
    event.preventDefault()
    console.log @firstName(), @firstName.invalid(), @firstName.message()
    address =
      firstName : @firstName()
      lastName : @lastName()
      streetAddress : @streetAddress()
      postalCode : @postalCode()
      city : @city()
      state : if @country() is "United States" then @state() else ""
      country : @country()
    Meteor.call "BTC.saveAddress", address, (error, result) ->
      if error
        alert "There was an error, while trying to save your address
        to the db: #{error.message}"
  autorun : # we are handling the custom semantic ui selects here
    [
      ->
        @stateSelect.dropdown "set selected", @state()
        @stateSelect.dropdown "set text",
          _.chain states
            .find abreviated : @state()
            .value().name
      ->
        @countrySelect.dropdown "set selected", @country()
        @countrySelect.dropdown "set text", @country()
    ]
