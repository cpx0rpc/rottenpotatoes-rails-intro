class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date, :sort)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @movies = Movie.all
		@all_ratings = Movie.pluck(:rating).uniq
		@selected_ratings = @all_ratings
		
		if session[:ratings] != nil
			@selected_ratings = session[:ratings].keys
		end

		if session[:sort] != nil
			@sort = session[:sort]
		end

		if params[:ratings] != nil
			@selected_ratings = params[:ratings].keys
			session[:ratings] = params[:ratings]
		end
	
		if params[:sort] != nil
			@sort = params[:sort]
			session[:sort] = params[:sort]
		end
		
		if @sort != nil
			begin
				@movies = Movie.where(rating: @selected_ratings).order("#{@sort} ASC")
				test = @movies.first
				rescue ActiveRecord::StatementInvalid
					flash[:warning] = "Invalid statement"
					@movies = Movie.all
					redirect_to movies_path
					session.clear
			end
		else
			begin
				@movies = Movie.where(rating: @selected_ratings)
				test = @movies.first
				rescue ActiveRecord::StatementInvalid
					flash[:warning] = "Invalid statement"
					@movies = Movie.all
					redirect_to movies_path
					session.clear
			end
		end
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

end
