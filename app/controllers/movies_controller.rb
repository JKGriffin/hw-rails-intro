class MoviesController < ApplicationController
  helper_method :sort_column
  
    def show
      id = params[:id] # retrieve movie ID from URI route
      @movie = Movie.find(id) # look up movie by unique ID
      # will render app/views/movies/show.<extension> by default
    end
  
    def index
      #update session parameters for filters ~ only if at least 1 is on
      if(params[:grating] == "on" || params[:pgrating] == "on" || params[:pg13rating] == "on" || params[:rrating] == "on")
        session[:grating] = params[:grating]
        session[:pgrating] = params[:pgrating]
        session[:pg13rating] = params[:pg13rating]
        session[:rrating] = params[:rrating]
      end
      #update session parameter for sorting
      if(Movie.column_names.include?(params[:sort]))
        session[:sort] = params[:sort]
      end
      #sorts movies
      list = Movie.all.order(sort_column)
      #updates list to include only desired filters ~ only if at least 1 is on
      if(session[:grating] == "on" || session[:pgrating] == "on" || session[:pg13rating] == "on" || session[:rrating] == "on")
        if session[:grating] != "on"
          list = list.reject { |m| m.rating == "G"}
        end
        if session[:pgrating] != "on"
          list = list.reject { |m| m.rating == "PG"}
        end
        if session[:pg13rating] != "on"
          list = list.reject { |m| m.rating == "PG-13"}
        end
        if session[:rrating] != "on"
          list = list.reject { |m| m.rating == "R"}
        end
      end
      @movies = list
    end
  
    def new
      # default: render 'new' template
    end
  
    def create
      @movie = Movie.create!(movie_params)
      flash[:notice] = "#{@movie.title} was successfully created."
      redirect_to movies_path
    end
  
    def edit
      @movie = Movie.find params[:id]
    end
  
    def update
      @movie = Movie.find params[:id]
      @movie.update_attributes!(movie_params)
      flash[:notice] = "#{@movie.title} was successfully updated."
      redirect_to movie_path(@movie)
    end
  
    def destroy
      @movie = Movie.find(params[:id])
      @movie.destroy
      flash[:notice] = "Movie '#{@movie.title}' deleted."
      redirect_to movies_path
    end
  
    private
    # Making "internal" methods private is not required, but is a common practice.
    # This helps make clear which methods respond to requests, and which ones do not.
    def sort_column
      Movie.column_names.include?(session[:sort]) ? session[:sort] : "id"
    end
    
    def movie_params
      params.require(:movie).permit(:title, :rating, :description, :release_date)
    end
  end