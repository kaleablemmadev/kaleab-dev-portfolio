# Notes on UseState
- A state is what remembers the imput given by the user. It is used in forms to remember the name you entered. It is used in counters to remember the number before you clicked it.
- It uses array destructing to put the input you given and the current state of the page in the current time in the form of [event, setEvent] (assume event is anything you want to add as an input, like age, name, etc...)
- It is a hook (a method which allows you to use a built-in react component in your code), so it must be imported from 'react'. Then it is declared using the array mentioned above and the useState constructor to provide the placeholder. It looks like this:
> import { useState } from React;
>
> const [age, setAge] = useState(20)

[Link to the Article](https://react.dev/reference/react/useState#avoiding-recreating-the-initial-state)