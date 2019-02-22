class UsersController < ApplicationController
  before_action :load_user, except: %i(index new create)
  before_action :logged_in_user, except: %i(new create show)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def index
    @users = User.activated.paginate page: params[:page],
      per_page: Settings.user.per_page
  end

  def show
    @microposts = @user.microposts.paginate page: params[:page],
      per_page: Settings.micropost.per_page
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = t "check"
      redirect_to root_path
    else
      render :new
    end
  end

  def edit; end

  def update
    if @user.update_attributes user_params
      flash[:success] = t "profile_updated"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t "delete_user"
      redirect_to users_path
    else
      flash[:danger] = t "unsuccessfully_user"
      redirect_to root_path
    end
  end

  def following
    @title = t "micropost.following"
    @user = User.find_by params[:id]
    if @user
      @users = @user.following.paginate page: params[:page],
      per_page: Settings.micropost.per_page
  end
      render "show_follow"
    else
      flash[:danger] = t "controllers.concerns.an_error"
      redirect_to root_path
    end
  end

  def followers
    @title = t "micropost.followers"
    @user = User.find_by params[:id]
    if @user
      @users = @user.followers.paginate page: params[:page],
      per_page: Settings.micropost.per_page
  end
      render "show_follow"
    else
      flash[:danger] = t "controllers.concerns.an_error"
      redirect_to root_path
    end
  end

  private

  def load_user
    @user = User.find_by id: params[:id]
    return if @user
    flash[:danger] = t "no_data"
    redirect_to root_path
  end

  def user_params
    params.require(:user).permit :name, :email, :password,
      :password_confirmation
  end

  def logged_in_user
    return if logged_in?
    store_location
    flash[:danger] = t "login_plz"
    redirect_to login_path
  end

  def correct_user
    redirect_to root_path unless current_user?(@user)
  end

  def admin_user
    redirect_to root_path unless current_user.admin?
  end
end
