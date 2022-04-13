# Covid-24
This project aimes in creating a fully metamorphic virus that will change its own code while replicating.

## Disclaimer

This project is purely pedagological and is not made for any illegal or irresponsible use. I cannot be held responsible for anyone misusing this project.

## Description

This project will be composed of two parts, the virus part and the mutation engine. Virus part will be based on what we saw on `Famine/Pestilence`. It will be an extension of the `.data` segment with the virus body encrypted while we also inject a decryptor in the `.text` segment that will decrypt the virus body and change the `.data` permissions to allow the virus execution.

The mutation engine will actualkly be the main part of this project, probably the huge majority of the code. I'm building it based on the work of The Mental Driller who wrote MetaPHOR, the first advanced metamorphic virus in 2002. Although its technique is still working really well, we are now in 2022 and 20 years later, computer security evolved a great deal. So we will have to adapt to new challenges: PIE execution. PIE execution is now present everywhere to allow programs to execute when ASLR is turned on so that they can work properly whereever they are mapped in memory.

## Mutation Engine

### Disassembler

The disassembler is the first part of the mutation engine, it is by disassembling itself that the code will be able to "understand" itself in order to rebuild itself with a different shape when propagating inside a system. It is being done by "translating" the code in a list of pseudo-assembly instruction containing:
- The instruction
- The size of the operands
- the Label Mark (instructions that are being pointed on by a label are not handled the same way by the engine so we need to keep trsck of those)
- The encoding of the instruction (so that we can know how to interpret the following members of the structure)
- The operands (they can be a register, a memory place or an immeditate)

If you want to learn more in depth how the disassembler works, the way it works is very similar to The Mental Driller's one. You can go check its own article on the subject. Only the structures are different, mine are being described in `./srcs/disassembler.s`.

## Ressources

- https://vxug.fakedoma.in/archive/VxHeaven/lib/vmd01.html
- https://vxug.fakedoma.in/archive/VxHeaven/lib/apb01.html