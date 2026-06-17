# UseState in React

Think of your google account for a second. You enter your name and it automatically adds the letters into the input area while you are writing. If your name is "John", the page remembers that wrote already entered "Jo", at the moment you are clicking "h". When a page is built using react, this task of remembering the imput of user is reserved for the UseState Component.

A state is what remembers the imput you included so far. Your state now in the above example is "Jo", and it changes to "Joh" when you enter "h". This is the basic understanding of what UseState does. It is a hook (method allowing you to use a built-in component of React) that contains an array of two things [current-state, next-state-you-want]. Whenever you press on the letters in your keyboard, react re-renders the UI to set the new state. That makes it impossible for state to be a variable. A single variable can't be re-rendered automatically whenever a new input arrives creating a new state.

The syntax is simple:
> const [state, setState] = useState('placeholder');

As an example, when you want a useState to imput age, you could say:
> const [age, setAge] = useState('20');

- 'age' is the current state (the age currently in the input bar)
- 'setAge' is the new state when a new input is added (new age when you add some number to the input bar)
- '20' is a placeholder (when you open the page, this number is the first to appear in the input bar and will disappear when you enter your own age)