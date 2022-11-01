// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract List {
    address owner; 

    struct Todo {
        string title;
        string description;
        bool completed;
    }

    Todo[] todos;

    modifier onlyOwner {
        require(owner == msg.sender, "You are not an owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addTodo(string calldata _title, string calldata _description) public onlyOwner {
        todos.push(Todo({
            title: _title,
            description: _description,
            completed: false
        }));
    }

    function changeTodoTitle(string calldata _newTitle, uint index) public onlyOwner {
        todos[index].title = _newTitle;
    }

    function changeTodoStatus(uint index) public onlyOwner {
        todos[index].completed = !todos[index].completed;
    }

    function getTodo(uint index) public view onlyOwner returns(string memory, string memory, bool) {
        Todo storage myTodo = todos[index];
        
        return (
            myTodo.title,
            myTodo.description,
            myTodo.completed
        );
    }
}