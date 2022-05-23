# Covid-24
This project aims in creating a fully metamorphic virus that will change its own code while replicating.

## Disclaimer

This project is purely pedagogical and is not made for any illegal or irresponsible use. I cannot be held responsible for anyone misusing this project.

## Description

This project will be composed of two parts, the virus part and the mutation engine. Virus part will be based on what we saw on `Famine/Pestilence`. It will be an extension of the `.data` segment with the virus body encrypted while we also inject a decryptor in the `.text` segment that will decrypt the virus body and change the `.data` permissions to allow the virus execution.

The mutation engine will actually be the main part of this project, probably the huge majority of the code. I'm building it based on the work of The Mental Driller who wrote MetaPHOR, the first advanced metamorphic virus in 2002. Although its technique is still working really well, we are now in 2022 and 20 years later, computer security evolved a great deal. So we will have to adapt to new challenges: PIE execution. PIE execution is now present everywhere to allow programs to execute when ASLR is turned on so that they can work properly wherever they are mapped in memory.

## Mutation Engine

### Disassembler

The disassembler is the first part of the mutation engine, it is by disassembling itself that the code will be able to "understand" itself in order to rebuild itself with a different shape when propagating inside a system. It is being done by "translating" the code in a list of pseudo-assembly instruction containing:
- The instruction
- The size of the operands
- the Label Mark (instructions that are being pointed on by a label are not handled the same way by the engine so we need to keep track of those)
- The encoding of the instruction (so that we can know how to interpret the following members of the structure)
- The operands (they can be a register, a memory place or an immediate)

If you want to learn more in depth how the disassembler works, the way it works is very similar to The Mental Driller's one. You can go check its own article on the subject. Only the structures are different, mine are being described in `./srcs/disassembler.s`.

### PRNG

For the shrinker, the expander and the reassembler, we will need a lot of randomness. Even though we could just read `/dev/random`, some modern systems are considering suspicious softwares using too much of the system randomness so we will code our own pseudo-random number generator.<br/>
The problem with it is that we can't use the `div/mod` instructions because they are register based and they will break after register swapping. Even though we could try to reassign the registers like we do with syscalls, it would not be optimal and a bit tricky so instead, we will find the closest greater power of two from the maximum number that we want to generate and we will generate a random bit sequence with right amount of byte. If the number is in the right range, we are good to go other wise we start the operation again until the number is in the range that we asked.
To generate this sequence, we will use a Fibonacci LFSR with taps 2, 3 and 5 and initialized with a seed being the last byte of the address of the seed-generator function. With PIE + ASLR + the fact that its position will move at each generation, we can consider it random enough. Though, it will always be the same as lopng as we don't modify the code placed before during debugging (gdb always run the child code at the same place) which is gonna be very practical to debug.

## Ressources

- https://vxug.fakedoma.in/archive/VxHeaven/lib/vmd01.html
- https://vxug.fakedoma.in/archive/VxHeaven/lib/apb01.html