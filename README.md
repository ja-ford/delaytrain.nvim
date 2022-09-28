<div align="center">
# DelayTrain
_Train yourself to stop repeating keys... gently_

[How does it work?](#how-does-it-work) • [Installation](#installation) 
• [Configuration](#configuration) • [Commands](#commands) 
• [Contributing](#contributing) 

TODO: quick demo gif ~/Videos/delaytrain.gif
</div>

## "Stop using arrow keys!" "Stop using hjkl!"

If you're familiar with the (neo)vim community you've probably heard this a 
million times. The whole point of vim is to seamlessly navigate where you
need to go without constantly repeating keypresses. Why press `j` ten times 
when you can press `10j`, or `}`, or search.

But if you've been using vim for a while this may be a harder habit to break.
You try to stop relying on this type of navigation but you only catch 
yourself after the fact. You might chastize yourself and move on but the 
habit stays there.

Most recommendations involve disabling these keys altogether, but this only
increases frustration. Sometimes your next position is directly above and
the quickest option is to press `k`. This might help in the long run but 
it's incredibly annoying and hard to stick with.

That's where DelayTrain comes in.

DelayTrain will still let you use these keybindings, but it only punishes
you when you _keep_ hitting them. If you need to navigate directly below,
you can still do that. But if you need to navigate 5 lines below using
repeated keypresses, DelayTrain will gently remind you that there might
be a better way by stopping the keypress from working for a certain 
amount of time.

And DelayTrain doesn't just work for hjkl. Mappings are included to 
prevent repeated arrow key presses and you can configure delaytrain to 
prevent anything else like `w` or `b`.

## How does it work?

DelayTrain takes two configurable values, `delay_ms` and `grace_period`.

When you first hit a configured keypress (like `j`), the `delay_ms` timer
starts. You are given a `grace_period` of repeated keypresses within the
`delay_ms` timer before the key stops working. Once the `delay_ms` timer
ends, everything is reset.

### Examples

We'll use a few tables to show how this works. Assume the follwing:

* `delay_ms = 1000`
* `grace_period = 2`

By default the `grace_period` is 1, but setting it to 2 allows you to
press the key twice before it stops working.

| Keypress   | Time        | Grace Period | Does it work? |
| ---------- | ----------- | ------------ | ------------- |
| `j`        | 0ms         | 1            | Yes           |
| `j`        | 200ms       | 2            | Yes           |
| `j`        | 500ms       | 3            | No            |
| `j`        | 1000ms      | 1            | Yes           |

Each keypress starts a dedicated `delay_ms` timer and has a dedicated 
`grace_period`. So if you're trying to navigate down and to the left,
this still works.

| Keypress   | Time        | Grace Period | Does it work? |
| ---------- | ----------- | ------------ | ------------- |
| `j'        | 0ms         | 1            | Yes           |
| `j'        | 200ms       | 2            | Yes           |
| `h'        | 500ms       | 1            | Yes           |
| `j'        | 700ms       | 3            | No            |
| `h'        | 1000ms      | 2            | Yes           |
| `j'        | 1200ms      | 1            | Yes           |
| `h'        | 1400ms      | 3            | No            |
| `h'        | 1500ms      | 1            | Yes           |


## Installation

Install with [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug '[TODO GITHUB NAME]/delaytrain.nvim'
```

or with [packer](https://github.com/wbthomason/packer.nvim):

```lua
  -- Delay repeat execution of certain keys
  use '[TODO GITHUB NAME]/delaytrain.nvim'
```

For the default setup (see defaults below), you can simply place the following
into your `init.lua`:

```lua
require('delaytrain').setup()
```

## Configuration

You can configure all DelayTrain settings through the `setup()` function. The
default DelayTrain mappings are included below:

```lua
    require('delaytrain').setup {
        delay_ms = 1000,  -- How long repeated usage of a key should be prevented
        grace_period = 1, -- How many repeated keypresses are allowed
        keys = {          -- Which keys (in which modes) should be delayed
            ['nv'] = {'h', 'j', 'k', 'l'},
            ['nvi'] = {'<Left>', '<Down>', '<Up>', '<Right>'},
        },
    }
```

### Mappings

The keys option allows you to delay different keypresses in different modes.
This takes the following KV pair:

```lua
    ['list_of_applicable_modes'] = {'keys', 'you', 'want', 'delayed'},
```

Modes can be added based on their short-names (ex: normal is 'n', insert is 
'i') and multiple modes can be added to a single keymap.

This option ties into a call to `vim.keymap.set()`, so mode short-names and
key names should match what is possible in that function.

### Options

Global options can be modified to change delay/grace period settings on the
fly:

* `g:delaytrain_delay_ms`
* `g:delaytrain_grace_period`

## Commands

The following commands allow you to turn DelayTrain on and off without
calling `setup()` again:

* `:DelayTrainEnable`
* `:DelayTrainDisable`
* `:DelayTrainToggle`

By default, DelayTrain is turned on when the `setup()` function is called.

## Contributing

This has been tested on my personal and work machines using nvim-nightly and
[Neovide](https://github.com/neovide/neovide). This is a REALLY SMALL plugin
so while there shouldn't be a lot of issues it's entirely possible I missed
something. I'm also brand new to plugin development so if you notice anything
off please feel free to open up an issue or send me a PR!
