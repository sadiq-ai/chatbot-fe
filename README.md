# Shopping Assistant - Frontend

## About

Your personal assistant. Ask me for any product recommendations or help you need. This is the frontend repository which has a chatting app UI with voicenotes support.

## Backend

You can use this chat app with our backend.

`https://github.com/sadiq-ai/chatbot-be`

## Project Stucture

### main.dart

This is the root of the project and the entry point of our chat app.

### network.dart

All the api calls to backend would be defined here with proper routes and implementations.

### models/

All the models related to the project to be defined here.

- Chat Model
- Product Model

### chatapp.dart

The chat app UI with chat history and voice note button is designed here.

### helpers

- utils.dart: any utility functions or computes to be defined here.
- text_formatter.dart: any necessary text formatting functions to be defined here.
- constants.dart: Any constants or variables that would be static and used throught app can be defined here.

## How to run

`git clone https://github.com/sadiq-ai/chatbot-fe`

`cd chatbot-fe`

`flutter build`

`flutter run`
