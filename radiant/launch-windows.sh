#!/bin/bash

## script to start Radiant and Rstudio
clear
has_docker=$(which docker)
if [ "${has_docker}" == "" ]; then
  echo "--------------------------------------------------------------------"
  echo "Docker is not installed. Download and install Docker from"
  echo "https://store.docker.com/editions/community/docker-ce-desktop-windows"
  echo "--------------------------------------------------------------------"
  read
else

  ## kill running containers
  running=$(docker ps -q)
  if [ "${running}" != "" ]; then
    echo "--------------------------------------------------------------------"
    echo "Stopping running containers"
    echo "--------------------------------------------------------------------"
    docker kill ${running}
  fi

  available=$(docker images -q vnijs/radiant)
  if [ "${available}" == "" ]; then
    echo "--------------------------------------------------------------------"
    echo "Downloading the radiant computing container"
    echo "--------------------------------------------------------------------"
    docker pull vnijs/radiant
  fi

  echo "--------------------------------------------------------------------"
  echo "Starting radiant computing container"
  echo "--------------------------------------------------------------------"

  docker run -d -p 80:80 -p 8787:8787 -v c:/Users/$USERNAME:/home/rstudio vnijs/radiant

  echo "--------------------------------------------------------------------"
  echo "Press (1) to show Radiant, followed by [ENTER]:"
  echo "Press (2) to show Rstudio, followed by [ENTER]:"
  echo "Press (3) to update the radiant container, followed by [ENTER]:"
  echo "--------------------------------------------------------------------"
  read startup

  if [ "${startup}" == "3" ]; then
    running=$(docker ps -q)
    echo "--------------------------------------------------------------------"
    echo "Updating the radiant computing container"
    docker kill ${running}
    docker pull vnijs/radiant
    echo "--------------------------------------------------------------------"
    docker run -d -p 80:80 -p 8787:8787 -v c:/Users/$USERNAME:/home/rstudio vnijs/radiant
    echo "--------------------------------------------------------------------"
    echo "Press (1) to show Radiant, followed by [ENTER]:"
    echo "Press (2) to show Rstudio, followed by [ENTER]:"
    echo "--------------------------------------------------------------------"
    read startup
  fi

  echo "--------------------------------------------------------------------"
  if [ "${startup}" == "1" ]; then
    touch c:/Users/$USERNAME/.Rprofile
    if ! grep -q 'radiant.maxRequestSize' c:/Users/$USERNAME/.Rprofile; then
      echo "Your setup does not allow report generation in Report > Rmd"
      echo "or Report > R. Would you like to add relevant code to .Rprofile?"
      echo "Press y or n, followed by [ENTER]:"
      echo
      read allow_report

      if [ "${allow_report}" == "y" ]; then
        printf '\noptions(radiant.maxRequestSize = -1)\noptions(radiant.report = TRUE)' >> c:/Users/$USERNAME/.Rprofile
      fi
    fi
    echo "Starting Radiant in the default browser"
    start http://localhost
  elif [ "${startup}" == "2" ]; then
    echo "Starting Rstudio in the default browser"
    start http://localhost:8787
  fi
  echo "--------------------------------------------------------------------"

  echo "--------------------------------------------------------------------"
  echo "Press q to stop the docker process, followed by [ENTER]:"
  echo "--------------------------------------------------------------------"
  read quit

  running=$(docker ps -q)
  if [ "${quit}" == "q" ]; then
    docker kill ${running}
  else
    echo "--------------------------------------------------------------------"
    echo "The radiant computing container is still running"
    echo "Use the command below to stop the service"
    echo "docker kill $(docker ps -q)"
    echo "--------------------------------------------------------------------"
    read
  fi
fi