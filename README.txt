This project contains:

Godot (4) 2D game (client)

Spring Boot (Java 21) backend API

PostgreSQL database (16)

Docker Compose for backend + database

This file explains what you need to install, how to configure the project, and how to run everything locally or with Docker.

Requirements

IntelliJ IDEA (Community)
Used for editing and running the Spring Boot backend.

Java 21 (JDK 21)
Required to build and run the Spring Boot backend locally.

Git
Required to clone the repository and manage version control.

Godot Engine
Used to open and build the 2D game.

Docker Desktop
Required to run the Spring Boot backend and PostgreSQL database without the need of installing them locally.

Database Configuration

Spring Boot local development

File: backend/src/main/resources/application.properties

spring:

  flyway:
    enabled: true
    validate-on-migrate: true
    
  datasource:
    url: jdbc:postgresql://localhost:5432/datbasename
    username: username
    password: password

    jpa:
      hibernate:
        ddl-auto: update
      show-sql: true
      

  application:
    name: farm-game-server

Docker PostgreSQL (docker-compose.yml)

version: "3.8"

services:
  db:
    image: postgres:16
    container_name: game-database
    environment:
      POSTGRES_DB: databasename
      POSTGRES_USER: username
      POSTGRES_PASSWORD: password
    ports:
      - "5432:5432"
    volumes:
      - db-data:/var/lib/postgresql/data

  server:
    build: .
    container_name: game-server
    ports:
      - "8080:8080"
    depends_on:
      - db
    environment:
      SPRING_DATASOURCE_URL: jdbc:postgresql://db:5432/databasename
      SPRING_DATASOURCE_USERNAME: username
      SPRING_DATASOURCE_PASSWORD: password

volumes:
  db-data:
Notes:

If you change credentials or DB name, update both application.properties and docker-compose.yml

db-data volume keeps DB data persistent on each developer’s machine

Running the Project
Option 1 – Run Backend + DB with Docker

Build and start containers:

docker compose up --build -d

Verify containers:

docker ps

You should see spring-app and postgres-db.

Stop containers:

docker compose down

Option 2 – Run Backend Locally (without Docker)

Start PostgreSQL (Docker only):

docker compose up -d db

Run backend from IntelliJ or terminal:

mvn spring-boot:run

or run from IntelliJ “Run” button.

Running the Godot Game

Open Godot Editor

Click “Import”

Select the project.godot file

Press Play to run the game

The game communicates with the backend at:

http://localhost:8080

Update scripts if the backend hostname or port changes.

Building Docker Image Manually (optional)

docker build -t spring-app .

Clean and Rebuild Everything

docker compose down -v
docker compose up --build -d

(Note: this deletes all database data)

Project Structure 

Farm/
│
├── server/farm-game-server/ – Spring Boot (Java 21)
│ ├── src/
│ ├── target/
│ └── Dockerfile
│
├── godot/farm-game/ – Godot 2D game
│ └── project.godot
│
├── docker-compose.yml
└── README.txt