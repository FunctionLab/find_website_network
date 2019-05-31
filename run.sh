# on confundo
docker build -t "jzthree:shiny" .
docker run -d -p 3939:3838 -e USER=$USER -e USERID=$UID jzthree:shiny
