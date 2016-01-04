# (( dialogs ))
Conversational machines for chatbot services.

## Introduction/Motivation
I'm very ignorant in NLP (natural language processing) topics, I confess, but I'm kinned to find a pratical solution to this specific goal: find a simple solution to allow people use instant messengers to conversate with a chatbots (I'm a sort of Telegram.org bot API evamgelist) to get services, by example in e-commerce/e-payment realms. This project consider the online-shopping with a chatbot (someone call this: *conversational commerce*) as a real application example of what i mean with term 'service'. 

## Elemental dialog as a Finite State Machine

The basic gist is to model natural language dialogs, between a person and a chatbot, as *state machines-based*  *elementals* (= atomic) dialogs that can be composed to achive some more complex workflow goal (= service). 


### Simplest dialog: Request/Reply 

Let's consider an atomic dialog as a black-box that have to manage two basic message events:
* request: a message coming from a user
* reply: a message back to the user

Also the black-box realize some elaborations on some input data, producing output data:
* input data: some data that initialize the dialog
* output data: some data produced after the elaboration of user request/interaction

```
                         +----< input data
                         |
                 +-------+-----------+
       request   |                   |
user ----------> | ----> interaction |
     <---------- | <---- processing  |
       reply     |                   |
                 +-------+-----------+
                         |
                         +-----> output data
                                        
```  


### DSL for a state machine based dialog
Each *elemental dialog* must be pre-programmed as a finite state machine, that follow prefixed states, triggered by user statements during conversation. 

Let's consider by example a `Dialog::List` elemental dialog to add/remove items from an abstract list of items. This dialog can be modeled as a finite state machine with three basic states: `:add_item`, `:del_item`, `:confirm_list`:

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
* `request` the user text
* `reply` the machine feedback to user
* `go` trigger next state of the same machine
* `back` close the dialog, returning to the caller dialog
* `call` call an external dialog or a sequence of dialogs

The Ruby code chunk here below show the machine for state add_item: 

```Ruby
# file: list.rb
module Dialogs 
  class List < Dialog

    #
    # state: add
    #
    def add(item)
      case item
      when yes_i 
        go :add, add_more_o

      when no_i || exit_i 
        if data.empty?
          reply aborted_o 
          return back :finish
        end  

        # list items
        reply_list
        go :confirm, confirm_o 

      when help_i  
        help_add
      
      when list_i 
        reply_list
        go :add, add_more_o

      else
        #
        # NLP understanding
        #
        interpret item

        # add line to data text
        data.push item

        # back to the same state
        go :add, add_more_o 
      end  
    end    
```

### Split the machinery from (natural) language literals!
As you note there is no anyi language text hard-coded here. All input texts (`no_i`, `help_i`, etc.) and output texts (`add_more_o`, `conform_o`, etc.) are contained in private methods, in a separate file, dependent on language. here below a chunk example for a List dialog talking in Italian language (BTW, yes, I'm Italian):


```Ruby
# file: list_lang_it.rb
module Dialogs 
  class List < Dialog
    private
    #
    # input
    #
    def yes_i
      /\bsi\b|\bok\b|\bprocedi\b|\bvai\b/i
    end  

    def del_i
      /\bdel\b|\btogli\b|\brimuovi\b/i
    end  

    #
    # output
    #
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

My choice now is to made each dialog *language agnostic*, moving internationalization/natural language transaltions in separate files (one for each language: by example: `list_lang_it.rb` for Italian language, `list_lang_en.rb` for English, etc.). 

> Implementation Note: I feel that incapsulate literals inside methods is a compromise, interms od readibility and performance, between a spaghetti-code (hard-code texts inside the state machine logic code), and using some template engine (at first my aim was to use Michel Mertens' mote gem, but I now prefer the text-inside-methods approach). Also the choice to use regex to process user choice is opinable, I admit. A temporary decision

### Language-agnostic dialogs ?
I thinked `((dialogs))` project as a man-machine text (or speech) based interface among people and chatbots. So when we refer to 'languages', we mean *natural languages*! That's pretty correct, but please note `((dialogs))` fully separate the state machine logic from any specific language, that coud be neither a natural language, neither a 'text-based' stream! In facts you could imagine language requests/replies in any sort of *binary-format*! By example we could imagine [MessagePack](http://msgpack.org/), as a possible language; in this case we can consider `((dialogs))` as a machine-to-machine communication meta-language.

## Sessions and data storage ?
Another basic concept under the woods, is to separate the dialogs state-machine logic from conversational sessions. 
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

# Todo

- implement `((dialogs))` as a socket/tcp server [How unicorn talks to nginx - an introduction to unix sockets in Ruby](http://blog.honeybadger.io/how-unicorn-talks-to-nginx-an-introduction-to-unix-sockets-in-ruby/)
- add a suitable session persistence (REDIS ?)
- make up the dialog template generator
- make a gem


# Warning

> Project is now in a __very draft release__, just a proof of concept! 
> Ruby implementation is bad now and really incomplete. I apologize and any contribution/help on coding is very welcome.


# Contact
mail: giorgio.robino@gmail.com
blog: [@solyarisoftware](http://www.twitter.com/solyarisoftware)

