# UseState in React (v.2)

Whenever you create an account, you enter a password, and the input bar goes from "weak password" gradually to "strong password". That means that the page is automatically changing with the input it took whenever a new one enters. In react, a state is what remembers what your input was. Your password is "1234" and you enter "12"; when you press "3", react re-renders the UI when the state changes from current state (12) to new state (123). That is the basic workflow of useState.

It is a component in react which saves the current state and then re-renders the UI to the new state whenever a new input is added. This can't be done by simple variable, since a variable doesn't automatically re-render the UI. 

To use useState follow these two simple steps:
1. Import useState from react

> ``` import { useState } from 'react'; ```

2. Declare it (for example to input age):

> ``` const [age, setAge] = useState(20); ```

where,
- 'age' is current state.
- 'setAge' is the new state.
- 20 is the placeholder.