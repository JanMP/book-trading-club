Address = new SimpleSchema
  firstName :
    type : String
  lastName :
    type : String
  streetAddress :
    type : String
  postalCode :
    type : String
  city :
    type : String
  state :
    type : String
    optional : true
  country :
    type : String

UserProfile = new SimpleSchema
  address :
    type : Address
    optional : true

Meteor.users.schema = new SimpleSchema
  username :
    type : String
    optional : true
  emails :
    type : Array
    optional : true
  "emails.$" :
    type : Object
  "emails.$.address" :
    type : String
    regEx : SimpleSchema.RegEx.Email
  "emails.$.verified" :
    type : Boolean
  "createdAt" :
    type : Date
    optional : true
  profile :
    type : UserProfile
    optional : true
  services :
    type : Object
    optional : true
    blackbox : true
  heartbeat :
    type : Date
    optional : true
Meteor.users.attachSchema Meteor.users.schema

new ValidatedMethod
  name : "BTC.saveAddress"
  validate : Address.validator()
  run : (address) ->
    unless @userId
      throw new Meteor.Error "BTC.saveAddress unauthorized"
    Meteor.users.upsert @userId,
      $set :
        profile:
          address : address
