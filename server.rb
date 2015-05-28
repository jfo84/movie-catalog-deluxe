require 'pg'
require 'sinatra'
require 'pry'

def db_connection
  begin
    connection = PG.connect(dbname: "movies")
    yield(connection)
  ensure
    connection.close
  end
end

get "/" do
  redirect "/actors"
end

get "/actors" do

  actors = db_connection { |conn| conn.exec("SELECT name FROM actors") }
  actors = actors.to_a

  erb :actors, locals: { actors: actors}
end

get "/actors/:id" do

  actor_details = "SELECT movies.title AS movie_title, cast_members.character
                    FROM actors
                    JOIN cast_members ON actors.id = cast_members.actor_id
                    JOIN movies ON cast_members.movie_id = movies.id
                    JOIN genres ON movies.genre_id = genres.id
                    WHERE actors.name = '#{params[:id]}'
                    ORDER BY actors.name"

          actor_details = db_connection { |conn| conn.exec(actor_details) }
          erb :actor_details, locals: { actor_details: actor_details, actor: params[:id]}


end

get "/movies" do

  movies = db_connection { |conn| conn.exec("SELECT title FROM movies") }
  movies = movies.to_a

  erb :movies, locals: { movies: movies}
end

get "/movies/:id" do

  genre_and_studio = "SELECT genres.name AS genre_name, studios.name AS studio_name
                      FROM movies
                      JOIN genres ON movies.genre_id = genres.id
                      JOIN studios ON movies.studio_id = studios.id
                      WHERE movies.title = '#{params[:id]}'"

  movie_details = "SELECT actors.name, cast_members.character
                    FROM actors
                    JOIN cast_members ON actors.id = cast_members.actor_id
                    JOIN movies ON cast_members.movie_id = movies.id
                    WHERE movies.title = '#{params[:id]}'"

          genre_and_studio = db_connection { |conn| conn.exec(genre_and_studio) }
          movie_details = db_connection { |conn| conn.exec(movie_details) }
          erb :movie_details, locals: { movie_details: movie_details,
                                        genre_and_studio: genre_and_studio,
                                        movie: params[:id]}


end
