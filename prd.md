In this project called A&S 104 we want to create a hype plug-in. The height framework is found at T Wilson 63.@hub.com/hype.

hype: https://twilson63.github.io/hype

OK, so the idea is if we use a go library to sign ANS 104 data items as a height plug-in if you look at the hype plug-in API, we should be able to create a go module and wrap it into a Lua API so that we canessentially use a new script to sign and bundle and A&S 104 data item the other reference file that we need to think about.
Is the go module that does the NNS104 heavy lifting

It is called

goar - https://github.com/everFinance/goar

OK, so the idea is that we want to use a key generated or key file generated from HP wallet and then we want to create a data item. A data item will consist of either a string or a binary value called data and then it will have types that will be named value key pairs, and they all get bundled togetherinto a data item with a target and anchor and I think that's it

Lets go
