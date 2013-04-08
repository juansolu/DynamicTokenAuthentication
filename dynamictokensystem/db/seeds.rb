# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create!([
    {
    username: "validuser",
    email: "validuser@test.com",
    password: "testtest",
    valid_token: "bgcdadjoofmejkpnjdcicpfmfoeohjam",
    token_rotation_count: 0
    },
    {
    username: "juan",
    email: "jaun@juan.com",
    password: "testtest",
    valid_token: "hnghipgflalgjjjnkngcjlecfjkedllg",
    token_rotation_count: 0
    },
    {
    username: "mike",
    email: "mike@mike.com",
    password: "testtest",
    valid_token: "nocnnghnodbfjjdpkpliapmadgckpofh",
    token_rotation_count: 0
    }
  ])
