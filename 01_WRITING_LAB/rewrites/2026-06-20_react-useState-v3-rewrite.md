# UseState in React (v.3)

Your password bar goes from "weak" to "strong" when you add characters. Have you ever wondered how React 'remembers' your inputs? 'State' is your answer. A state remembers what input you added. Assume you are typing your name "John", initial state is the blank slate (starting value, like empty input, counter at zero, or an empty whiteboard) in the input bar, whenever you add a new letter, a function named 'setState' is called to change the state from "" (empty input bar) to "J", then again to "Jo", again to "Joh", etc... And following the setState, React automatically re-renders the UI.

Think of re-rendering as erasing everything and re-writing the UI with the new state. Initial state was "", then setState updates it from "" to "J". Following that, React automatically erases the first UI and then it will build a new UI with the new state.

## Why not just use a variable?
You might be thinking, "Why don't just use variables and change them whenever you want it?", and you might do that, but the value only changes in your codebase, but the UI will still show the first value. (and that defeated the purpose)

## What is [state, setState] concept?
```const [state, setState] = useState('placeholder')``` is the basic syntax. useState provides an array of ['current-state', 'function to change state']. It is destructured to the two values (state = 'current-state' and setState = 'function to change state'). When you enter an input, the function is called and the 'current-state' will be updated to the 'new-state'.

## How to use it
To use ```useState``` follow these two simple steps:
1. Import useState from 'react'

> ``` import { useState } from 'react'; ```

2. Declare it (for example to input age):

> ``` const [age, setAge] = useState(20); ```

where,
- 'age' is current state.
- 'setAge' is the function that will create the new state.
- 20 is the placeholder.

Now try it yourself! Open your React project and add a counter using useState. Watch the UI update every time you click.