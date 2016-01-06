# (( dialogs ))
Conversational machines for chatbot services.


## Introduction / Motivation

I'm not a NLP (natural language processing) expert, I confess in advance, but I'm obsessioned to find a smart software implementation for this specific goal:

> To find a simple solution to allow people use instant messengers to conversate with a chatbots to get someapplication/business services, by example in e-commerce/e-payment realms. 

As a proof of concept, I consider hre an hypotetical online-shopping chatbot service (someone call this: *conversational commerce*) as a real application example of what I mean with term *service*. 

### Conversational chatbot services ?
My conversational machine approach is very naif. I call it a  *bottom-up* way, in opposition to fashioned artificial intelligence *top-down* approach tring to emulate a vast colloquial intelligence. Instead my goal is to realize simple, **specialized** chatbot *dialog systems* able to conversate with a human to achive a specific 'deterministic' simple workflow on some specific business context: as example of these *conversationalb chatbot services*, imagine a dialog system that guide a buyer of an ecommerce shop chatbot to submit an online shopping order, or that guide user to do some financial or payment transactions, or to book some service conversating with a chatbot, all in all almost anything you now do interacting with a visual website, Last but not least supplying a 'text adventure' in games realms or on a gamification of some  'boring' banking processes. 

## Elemental dialog as a Finite State Machine

My basic gist have been:

> **To model natural language dialogs, between a person and a chatbot, as *state machines-based* *elementals* (atomic) dialogs that can be composed togheter to achive some more complex workflow goal (service).** 


### The simplest dialog: Request/Reply 

Let's consider an elemental dialog as a black-box that have to manage two basic message events:

* request: a message coming from a user
* reply: a message back to the user

The black-box realize some elaborations on input data, producing output data:

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

#### State triggering
How states are triggered ? The 'engine' of a dialog is just a standard read-evaluate-print-loop ([REPL](https://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop)) done by the `request` method of abstract class `Dialog`:

```Ruby
  loop do
    # istantiate dialog loading last session
    dialog = self.load 
        
    text = self.adapter.read unless (dialog.state == :start) 

    dialog.request text
  end
```

The `request` method of abstract class `Dialog` do the dynamic method dispatch, calling the method with the name of the state:

```Ruby
  # call the method corresponding to the actual state
  def request(user_data)
    self.method(state).call(user_data)
  end
```

#### What about dialog data ?

In the above sketched request/reply dialog, I mentioned input and output data. Let's see in the list dialog example here what I mean:
the list abstract dialog manage a list data structure, so an Array, in Ruby language. This array could be initialized as a void array: 

```
  # initial data for a (void) list
  [] 
```
At the end of the dialog, output data could be an array containing some items (text strings). By example, if the list is a shopping cart to order some food to a pizza-maker, data culd be something like this:

```
  # final data for a ShoppingCartList, after a dialog interaction
  [
    "1 pizza Margherita, aggiunta: molti capperi", 
    "2 pizze Capricciose",
    "1 lattina di birra Moretti",
    "2 mezze minerali"
   ]
```

Generally speaking, I see data as a specific attribute of the elemental dialog type, so data are conceptually different for each dialog type. Data are the result of a conversation, to be eventually processed by some external (to dialog) service that *consume* data.

> TODO: data management and processing concept is still incomplete and code to be refined.


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

> Implementation code Note: I feel that incapsulate literals inside methods is a compromise, interms od readibility and performance, between a spaghetti-code (hard-code texts inside the state machine logic code), and using some template engine (at first my aim was to use Michel Mertens' mote gem, but I now prefer the text-inside-methods approach). Also the choice to use regex to process user choice is opinable, I admit. A temporary decision

#### Language-agnostic dialogs ?

I thinked **((dialogs))** project as a man-machine text (or speech) based interface among people and chatbots. So when we refer to 'languages', we mean *natural languages*! That's pretty correct, but please note **((dialogs))** fully separate the state machine logic from any specific language, that coud be neither a natural language, neither a 'text-based' stream! In facts you could imagine language requests/replies in any sort of *binary-format*! By example we could imagine [MessagePack](http://msgpack.org/), as a possible language; in this case we can consider the dialog system as a machine-to-machine communication meta-language.


## Introspection and helpers
Each dialog state is associated to a relative `help` method (pseudo-state) that reply to user the possible choices/action on the relative state. In this way user alway know 'how to do' in a dialog conversation, asking 'help' about what to do. I call thisi *state introspection*. 

>TODO: At a higher level each dialog elemental must be instrospected asking a description of the dialog. This could be done just with a description text file associated to the dialog. 


## Sessions and data storage ?

Another basic concept under the woods, is to separate the dialogs state-machine logic from conversational sessions data. 
Ruby class `Session` is in charge to store/retrieve a storage (in-memory or persistent):
* dialog *path*: a stack containing conversation history of nested dialogs
* dialog *state*: the inners state of the state-machine 
* dialog *data*: for a certain user session.

>TODO
>- define and fix data structures, a bit confused and incomplete now.
>- add a suitable session persistence to disk (a key/value like REDIS or relational DB), maybe using Moneta gem.


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

### Dialogs Taxonomy

> TODO: think about it.


## Performance vs Intelligence trade-off

There is some Natural Language Understanding in this scenario ? The state-machine implementation of a dialog is a dump / imperative / 'robotic' way to conceive a dialog with a human, and there is not a real 'deep' understanding or learning. Pretty true, I admit. In the dialog analyzed here as example, the semantic understanding/interpretation is 'delgated' inside the `Item::interpret` method on the `add_item `state method. The understanding of a product item, inserted by user, is delegated to this interpret method. 

>**There is no any (artificial) intelligence in this dialog system framework, I admit, but the trade-off is simplicity (short simple fast interactions are very important for a business service supplyed by a chatbot upon an instant messagimg app. Speed performance and focus on target goal (to supply a specific domain service with a deterministic dialog)!**


### User interaction means Supervisioned Learning for free

Let's imagine what could have to do this `Item::interpret` method, considering by example that user added this product:

```
    "1 pizza Margherita, aggiunta: molti capperi", 
```

BTW,i in Italy "Pizza Margherita" is the basic kind of pizza and "aggiunta: nolti capperi" means: "add-on: many capers". 

A possible smart NLP domain expert system could recognize that user want nr.1 of product type: pizza Margherita, with add-on: "many capers". Maybe the *semantic backend processor* could access a product catalog database o verify if the shop is really able to delivery this kind of product. Finally the processor could ask the user a doublecheck confirmation on inserted item. If the user finally say "yes! I want it!", in this case we can say that the system can really learn in a supervised, production-ready way!

Again, this understanding/learning process is out of scope from the state-machine architecture. But this state-machine dialog-driven system is a framewrk to focus some domain specific "intelligent" backend expert, just to a very specific domain (in the case of the example: to recognize an item an learn/take decision about it). 

> **(dialog))** could be considered as a driven dialog framework that incapsulate an external "expert system".


## Instant Messaging Plug-in Architecture

I conceived ((dialog)) having in mind amazing Telegram.org Bot Platform, but my aim is to realize the dialog system as a server (in a client-server architecture) indipendent from any specific instant messaging platform / APIs. For this reason I started to code interchargeable *client adapters*

> TODO: implement **((dialogs))** as a socket/tcp server, implementing something like [Ruby TCP Chat](http://www.sitepoint.com/ruby-tcp-chat/).


### Testing dialogs on a terminal
The first *client adapter* is the terminal.  Here a [terminal dialog interaction](http://showterm.io/e9d405f7af8d8c9902f69#fast) (thanks http://showterm.io ), testing List dialog.

<p align="center">
<img src="https://github.com/solyaris/dialogs/blob/master/wiki/img/terminal_example.jpg">
</p>

> TODO: complete the client adapter code for the Telegram Bot Platform.

# Todo
- make up the dialog template generator (like Rails generate, to generate boilerplate code for a new dialog).
- make a gem.


> **WARNING**: Project is now in a __very draft release__, just a proof of concept! 
> Ruby implementation is bad now and really incomplete. I apologize and any contribution/help on coding is very welcome.

# References 
- my bachelor thesis was about some [incremental learning of ARTMAP neural networks](http://giorgiorobino.altervista.org)).


# Contact

- mail: giorgio.robino@gmail.com
- blog: [@solyarisoftware](http://www.twitter.com/solyarisoftware)

