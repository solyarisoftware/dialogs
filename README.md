# (( dialogs ))
Conversational machines for chatbot services.


## Introduction / Motivation

I'm NLP (natural language processing) expert, I confess in advance, but I'm obsessioned to find a pratical solution to this specific goal: 

> find a simple solution to allow people use instant messengers to conversate with a chatbots (I'm a sort of Telegram.org bot API evamgelist) to get services, by example in e-commerce/e-payment realms. 

This project consider the online-shopping with a chatbot (someone call this: *conversational commerce*) as a real application example of what i mean with term *service*. 

So, because I'm not an AI expert (even if my bachelor thesis was about some incremental learning of ARTMAP neural networks), my approach here is very naif bottom-up. I'm not proposing here some artificial intelligence 'top-down' approach, but instead a simple chatbot dialog system able to conversate with a human to achive a spefic 'deterministic' simple workflow: as examples as *conversational services*: to guide a buyer of an ecommerce to submit an online shopping order, to guide user to do some financial or payment transactions, to book some service conversting with a chatbot, all in all almost anything you now do now interacting with a visual website, Last but not least supplying a 'text adventure' in games realms or on a gamification of boring process (banking)! So lets's start with the state-machine approach. Happy reading! 

### Instant gratification
Here a [terminal dialog interaction](http://showterm.io/e9d405f7af8d8c9902f69#fast) (thanks http://showterm.io ), testing List dialog.

![](https://github.com/solyaris/dialogs/blob/master/wiki/img/terminal_example.jpg)

## Elemental dialog as a Finite State Machine

My basic gist have been:

> to model natural language dialogs, between a person and a chatbot, as *state machines-based* *elementals* (= atomic) dialogs that can be composed togheter to achive some more complex workflow goal (= service). 


### The simplest dialog: Request/Reply 

Let's consider an elemental dialog as a black-box that have to manage two basic message events:
* request: a message coming from a user
* reply: a message back to the user

The black-box realize some elaborations on some input data, producing output data:
* input data: some data that initialize the dialog
* output data: some data produced after the elaboration of user request/interaction

```
                   input data
                   |
                   v                          
                 +------------------------------------+
       request   | chatbot                            |  reply
user ----------> | elaboration =                      | -------> user
                 | user interaction + data processing |     
                 +------------------------------------+     
                                                    |
                                                    v
                                          output data
                                        
```  


### DSL for a state machine based dialog

**Each *elemental dialog* must be programmed as a [finite state machine](https://en.wikipedia.org/wiki/Finite-state_machine), that follow prefixed states, triggered by user statements, (text) message requests, during conversation.** 

Let's consider by example a `Dialog::List` elemental dialog to add/remove items from an abstract list of items. This dialog can be modeled as a finite state machine with three internal  states: `:add_item`, `:del_item`, `:confirm_list`(in addition to `:start` and `:finish` states) :

```
 Dialog::List
 +-----------------------------------------------+
 |         :start                                |
 |          |       go :add_item                 |
 |   +----+ |       +---+                        |
 |   |    | |       |   |                        |
 |   |    v v       v   |                        |
 |   |   +-----------+  |                        |
 |   |   | :add_item |--+                        | call Item::iterpret  
 |   |   |           |---------------------------|---->
 |   |   +-----------+                           | 
 |   |      |            go :confirm_list        |
 |   |      |            +------------------+    |
 |   |      |            |                  |    |
 |   |      v            v                  |    |
 |   |   +---------------+   +-----------+  |    |
 |   +---| :confirm_list |-->| :del_item |--+    |
 |       +---------------+   +-----------+       |
 |          |                                    |
 |          |                                    |
 |          v                                    |
 |         :finish                               |
 +-----------------------------------------------+
```

The Ruby class `Dialog` realize a small DSL (*Domain Specific Language*) to implement a dialog as a state machine, supplying few methods:
* `request` the user text message request
* `reply` the message feedback to user
* `go` trigger next state into the same machine
* `back` close the dialog, returning to the caller dialog
* `call` call an external dialog or a sequence of dialogs

The Ruby code chunk here below show the machine for state add_item: 

```Ruby
# file: list.rb
module Dialogs 
  class List < Dialog

    # state: add
    def add(item)
      case item
      when yes_i 
        go :add, add_more_o

      when no_i || exit_i 
        if data.empty?
          reply aborted_o 
          return back :finish
        end  

        reply_list
        go :confirm, confirm_o 

      when help_i  
        help_add
      
      when list_i 
        reply_list
        go :add, add_more_o

      else
        # NLP understanding
        interpret item

        # add line to data text
        data.push item

        # back to the same state
        go :add, add_more_o 
      end  
    end    
```

### What about dialog data ?

In the above sketched request/reply dialog, I mentioned input and output data. Let's see in the list dialog example here what I mean:
the list abstract dialog manage a list data structure, so an array, in Ruby language. This array could be initialized as a void array (e.g `[]`)
nd at the end of the dialog, output data could be a not void array. By example, if the list is a shopping cart to order some food to a pizza-maker, data culd be somthing like:

```
  [
    "1 pizza Margherita, aggiunta: molti capperi", 
    "2 pizze Capricciose",
    "1 lattina di birra Moretti",
    "2 mezze minerali"
   ]
```

Generally speaking, I see data as a specific attribute of the dalog class, so data are conceptually distinct by dialog, in a way, data are the result of a conversation, to be eventually processed by some external (to dialog) service.



### Separate the state-machine from language literals

As you note there is no any language text hard-coded in the Ruby code above; all input texts (`no_i`, `help_i`, etc.) and output texts (`add_more_o`, `conform_o`, etc.) are contained in private methods, in a separate file, dependent on language. Here below a chunk example for a List dialog talking in Italian language (BTW, I'm Italian):


```Ruby
# file: list_lang_it.rb
module Dialogs 
  class List < Dialog
    private
    
    # input methods
    
    def yes_i
      /\bsi\b|\bok\b|\bprocedi\b|\bvai\b/i
    end  

    def del_i
      /\bdel\b|\btogli\b|\brimuovi\b/i
    end  

    # output methods

    def confirm_o
      "confermi lista ?"
    end

    def confirmed_o
      "lista confermata!"
    end

    def del_o(max_num)
      [
        "quale item vuoi cancellare (1-#{max_num}) ?", 
        "cosa vuoi togliere (1-#{max_num}) ?"
      ].sample
    end
```

My choice have been to made each dialog *language agnostic*, moving internationalization/natural language transaltions in separate files (one for each language: by example: `list_lang_it.rb` for Italian language, `list_lang_en.rb` for English, etc.).

> Implementation Note: I feel that incapsulate literals inside methods is a compromise, interms od readibility and performance, between a spaghetti-code (hard-code texts inside the state machine logic code), and using some template engine (at first my aim was to use Michel Mertens' mote gem, but I now prefer the text-inside-methods approach). Also the choice to use regex to process user choice is opinable, I admit. A temporary decision

### Language-agnostic dialogs ?

I thinked **((dialogs))** project as a man-machine text (or speech) based interface among people and chatbots. So when we refer to 'languages', we mean *natural languages*! That's pretty correct, but please note **((dialogs))** fully separate the state machine logic from any specific language, that coud be neither a natural language, neither a 'text-based' stream! In facts you could imagine language requests/replies in any sort of *binary-format*! By example we could imagine [MessagePack](http://msgpack.org/), as a possible language; in this case we can consider `((dialogs))` as a machine-to-machine communication meta-language.

## Sessions and data storage ?
Another basic concept under the woods, is to separate the dialogs state-machine logic from conversational sessionsi data. 
Ruby class `Session` is in charge to store/retrieve a storage (in-memory or persistent):
* dialog *path*: a stack containing conversation history of nested dialogs
* dialog *state*: the inners state of the state-machine 
* dialog *data*: for a certain user session.


## Application dialogs as compositions of elementals 

A complex dialog in some *real application* could be see as a composition of elemental-subdialogs (each of these modeled as a state-machine) and part of a library of *subjects*. In this Ruby language implementation, each sub-dialog is represented as a subclass of abstract `Dialog`.

### Conversational E-commerce Example
Lets consider by example a conversational ecommerce as real application of complex dialog. 
Suppose that we want to realize a text based ecommerce; we want purchase chatting through an instant messenger chatbot (a Telegram.org bot), where the workflow is in this case 'send an online shopping order'.
Online shopping is a pretty standard pattern (or workflow): we can consider this simplified ecommerce order submission as composed by three almost sequential dialogs: add items to a cart list, specify the time and delivery address, send order.  `DialogOrder` is a nesting of some subdialogs:
* `CartList`, to add items to our cart 
* `DeliveryAddress`, to specify delivery address 
* `DeliveryTime`, to specify required delivery time 
The final action of dialog is to send our text order to a seller: 

```
            OrderDialog
          +------------------------------------------------------------------+
          |     sub-dialog       sub-dialog              sub-dialog          |
order     |     +----------+     +-----------------+     +--------------+    |   +---------------------+
--------> | --> | CartList | --> | DeliveryAddress | --> | DeliveryTime | -----> | collect dialog data |
          |     +----------+     +-----------------+     +--------------+    |   | send order to shop  |
          |        | ^                     |^              |^                |   +---------------------+
          |        v |                     ||              ||                |
          |     +--------------------+     ||              ||                |
          |     | ItemsUnderstanding |     ||              ||                |
          |     +--------------------+     ||              ||                |
          |     sub-dialog    |^           ||              ||                |
          +-------------------||-----------||--------------||----------------+
                              v|           v|              v|
                      +---------------+  +--------------------+     
                      | shop          |  | user profiling     |
                      | catalog items |  | database           |
                      | database      |  |                    |
                      +---------------+  +--------------------+
```  


## There is a Natural Language Processing here ?

Nope. The state-machine implementation of a dialog is real a dump / imperative / robotic way to conceive a dialog with a human, and there is not a real 'deep' understanding or learning. In the dialog analyzed here as example, the understaning/interpretation is 'delgated' inside the `Item::interpret` method inside the add_item state mathod. The understaning of a product item, inserted by user, is delegated to this interpret method. 


### User interaction means Supervisioned Learning for free

Let's imagine what could have to do this `Item::interpret` method, considering by example that user added this product:

```
    "1 pizza Margherita, aggiunta: molti capperi", 
```

BTW, "Margherita" isa very basic kind of pizza and "aggiunta: nolti capperi" means: "add-on: many capers". A possible smart NLP domain expert system could recognize that user want nr.1 of prduct type: pizza Margherita, with add-on: "many capers". Maybe the expert system chatbot 'backend' could access a product catalog database o verify if the shop is really able to delivery this kind of product. Finally the expert could ask to user a confirmation double check. Ehn the user finaly say "yes! I want it!", in this case we can say that the expert can realy learn in a supervised, production-ready way!
Again, this understanding/learning process is out of scope from the state-machine architecture. But this satte-machine dialog-driven system is a framewrk to focus some domain specific "intelligent" backend expert, just to a very specific domain (in the case of the example: to recognize an item an learn/take decision about it). So **(dialog))** could be considered as a driven dialog framework that incapsulate an external "expert system".

# Todo
- defne and fix data structures, a bit confuseda dn incomplete now.
- add a suitable session persistence to disk (a key/value like REDIS or relational DB), maybe using Moneta gem.
- implement **((dialogs))** as a socket/tcp server, implementing something like [Ruby TCP Chat](http://www.sitepoint.com/ruby-tcp-chat/).
- make up the dialog template generator (like Rails generate, to generate boilerplate code for a new dialog).
- make a gem.


> **WARNING**: Project is now in a __very draft release__, just a proof of concept! 
> Ruby implementation is bad now and really incomplete. I apologize and any contribution/help on coding is very welcome.

# Contact

mail: giorgio.robino@gmail.com

blog: [@solyarisoftware](http://www.twitter.com/solyarisoftware)

