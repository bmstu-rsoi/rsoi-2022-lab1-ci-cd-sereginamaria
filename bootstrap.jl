(pwd() != @__DIR__) && cd(@__DIR__) # allow starting app from bin/ dir

using Lab1
const UserApp = Lab1
Lab1.main()
