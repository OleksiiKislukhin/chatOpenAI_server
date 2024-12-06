# Chat Server (Vapor)

This is the server-side application for a chat system, built with **Swift** and **Vapor**. The server handles messaging with Open AI.

## Technologies Used

- **Vapor**: A Swift web framework for building scalable and high-performance applications.
- **Swift**: The programming language used to build the backend.
- **PostgreSQL**: Database for storing users, messages, and chat rooms.
- **SSE**: For real-time, bidirectional communication between the client and server.

### Prerequisites

You need to have installed on your system:
- **Swift**
- **Vapor**
- **PostgreSQL**

## Installation

1. Clone the repository:

  ```bash
  git clone https://github.com/OleksiiKislukhin/chatOpenAI_server.git
  ```

2. Clone the repository:

  ```bash
  cd chat-server-vapor
  ```

3. Install dependencies:

  ```bash
  swift package update
  ```
  
4. Set up the database:

-Ensure PostgreSQL is running and create a database for the chat app (e.g., chat_db).
-Update the database connection settings and OpenAI key in the .env file.

.env file:
DATABASE_HOST=localhost
DATABASE_NAME=your_db_name
DATABASE_USERNAME=your_db_user_name
DATABASE_PASSWORD=your_db_password
OPENAI_API_KEY=your_key

5. Run database migrations:

  ```bash
  vapor migrate
  # or
  swift run App
  ```

This will create the necessary tables for chats and messages in the database.

6. Start the server:

  ```bash
  swift run
  # or
  vapor run serve
  ```

The server will be available at [http://localhost:8080](http://localhost:8080).

## API Endpoints

URL: [http://localhost:8080](http://localhost:8080)


**Chats**
  GET /chats: Retrieves a list of all available chat.
  POST /chats: Creates a new chat.
  DELETE /chats/[chatId]: Delete chat.

**Messages**
  GET /messages?chatId=[chatId]: Retrieves all messages from a specific chat.
  POST /messages: Create a new message in chat.

**OPEN AI**
  GET /ai_chat_test?question=[your_question]: Test OpenAI's response to a question without using a client.
  GET /ai_chat?question=[your_question]&&chatId=[chatId]: Get OpenAI's response to a question.