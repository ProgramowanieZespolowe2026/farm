# Pre production instruction for developers:
### Main folder
To work with project please open ```./godot/farm-game``` in godot.  

### While develop project please use test scene
```bash
./godot/farm-game/scenes/map/test_level.tsc
```
  
### Configuration  
You should already have set input map and globals script automatically. If something with player movement or timing functions doesn't works please check input map or globals.
```bash
Project->Project Settings -> Input Map # In here you must have 4 variables for moving
Project->Project Settings -> Globals # In here you must have script TestGameTimeCycleManager.gd
```   
  
### Assets  
- In folder ```./godot/farm-game/assets``` please put **ONLY** assets who are currently using in project  
- Database for all asset packs is in ```./godot/All asset packs```

### Warning
- Don't put file ```project.godot``` in .gitignore. This file have project input map and globals scripts.

### Tools
- Hoe - to **create** new field, **destroy** regrowing plants ( tomato, corn ) and **collect** not regrowing plants: wheat, beet, potato
- Shovel - **only to destroy**
- None ( empty hand ): to **collect regrowing plants**: tomato, corn

---


# This project contains:

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

File: backend/src/main/resources/application-local.yaml
set in this file your local credentials (this will allow you to run serwer in intellij localy) 
this file will be deleted from repository and extention added to git ignore

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

Docker PostgreSQL (.env)
set in this file your local credentials (this will allow you to run database container) 
this file will be deleted from repository and extention added to git ignore

DB_USER=username
DB_PASSWORD=password
DB_NAME=databasename

Running the Project
Option 1 – Run Backend + DB with Docker

Build and start containers:

docker compose up --build -d

Verify containers:

docker ps

You should see myproject-app and myproject-db.

Stop containers:

docker compose down

Option 2 – Run Backend Locally (without Docker)

Start PostgreSQL (Docker only):

docker compose up -d db

Run backend from IntelliJ


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
├── .env
└── README.txt

gmail do gita: login: programowanie.zespolowe2026@gmail.com hasło do gmaila i gita: 2026Programowanie!

