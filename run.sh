# on confundo
docker build -t "jzthree:shiny" .
docker run -d -p 3939:3838 -v /Genomics/ogtr04/jzthree/flyexpress/find/network/:/srv/shiny-server/ -e USER=$USER -e USERID=$UID jzthree:shiny
