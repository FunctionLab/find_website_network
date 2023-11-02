# build the image
docker build -t "find-network" .

#run it
docker run --rm -p 3838:3838 find-network
#docker run -d -p 3939:3838 -e USER=$USER -e USERID=$UID jzthree:shiny