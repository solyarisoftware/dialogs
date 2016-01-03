# (( dialogs ))
Conversational machines for chatbot services.

## Elemental dialog as a Finite State Machine

The basic idea is to model natural language dialogs, between a person and a chatbot as *state machines-based* conversations elements that can be composed to achive some more complex workflow goal (=service). Each *elemental dialog* must be pre-programmed as a finite state machine, that follow prefixed states, triggered by user statements during conversation.

## App dialogs as compositions of elementals 

A successive trivial idea is to think a complex dialog as a composition of elemental-subdialogs (each of these modeled as a state-machine) and part of a library of *subjects*.

### Conversational E-commerce Example
Lets consider by example a conversational ecommerce as real application. Suppose that we want to realize a text based ecommerce, ; we want purchase chatting through an instant messenger chatbot (a Telegram.org bot), where the workflow is in this case 'send an order': add items to our cart, specify delivery address, and finally send our text order to a seller. That's a pretty standard pattern (or workflow): we can consider this simplified ecommerce orderi submission as composed by three almost sequential steps (= dialogs): add items to a list, specify the time and delivery address, send order. So we can decompose the order dialog in some sub-dialogs: fill a cart, get user address data, get required delivery time.


# Todo

- realize a socket/tcp server
- add a suitable session persistence (REDIS ?)
- make up the dialog template generator
- make a gem


# Warning

Project is in a very draft release, just a proof of concept


# Contact
e-mail: giorgio.robino@gmail.com

