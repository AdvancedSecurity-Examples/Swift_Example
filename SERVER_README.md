## Overview
* The server files can be found on the gitHub for the android app. (Located here: https://github.com/TAMU-CSE/sttr-android.git)
* Once you download that, navigate to sttr-android/server
* There are two docker containers, node_backend and postgres
* node_backend is what handles the API calls to the server
* postgres is what holds the database on the server

## Starting the server
* Navigate to sttr-android/server/node_backend
* In order to start the server, run the command 'sudo docker-compose up --build -d'
* If you want to view the logs as the server is running, run the same command without '-d' at the end. When doing this, type 'Ctrl+C' to end and then run the command above to put the server up in detatched mode
  * Running the server in detatched mode makes it so that the server independently from the console. This means that when you close the console the server will still run, however if the server is not running in detatched mode then closing the console will shut down the server.

## node_backend
* node_backend is a node.js server
* This is where we have all of the commands related to getting information from the server, as well as interacting with the database
* The primary file for editing node_backend is located at sttr-android/server/node_backend/index.js

## postgres
* Navigate to sttr-android/server
* Run the command 'sudo docker exec -it postgres psql -U postgres'
  * 'docker exec -it postgres' will open a terminal in the specified container (in this case the postgres container)
  * '-it' will then run psql in that terminal (this is the postgres command line tool)
  * '-U' postgres tells psql to use the user “postgres”
* Once you are connected run the command '\c sttr' to attach the the sttr database
* Once connected, you can run SQL commands and interact with the database
