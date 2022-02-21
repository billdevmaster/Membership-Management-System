class Admin::ClientsController < Admin::BaseController
  # skip_before_action :admin_account, only: [:show]
  skip_before_action :admin_account, only: %i[ show index new edit create update clear_filters filter ]
  before_action :junioradmin_account, only: %i[ index new edit create update ]
  before_action :correct_account_or_admin, only: [:show]
  # before_action :layout_set, only: [:show]
  before_action :set_client, only: %i[ show edit update destroy ]

  def index
    @clients = Client.includes(:account).order_by_name
    handle_search_name unless session[:search_client_name].blank?
    handle_search
    @clients = @clients.page params[:page]
    respond_to do |format|
      format.html {}
      format.js {render 'index.js.erb'}
    end
  end

  def show
    # without clearing the session, the following sequence will show the attendances of the purchase of the preiously viewed client:
    # show clientA, select one of clientA's purchases, return to client index, show client B
    clear_session(:purchaseid)
    session[:purchaseid] = params[:purchaseid] || session[:purchaseid] || 'All'
      if session[:purchaseid] == 'All'
      @purchases = @client.purchases.order_by_dop
      else
      @purchases = [Purchase.find(session[:purchaseid])]
    end if
    @client_hash = {
      attendances: @client.attendances.size,
      spend: @client.total_spend,
      last_class: @client.last_class
    }

    @products_purchased = ['All'] + @client.purchases.order_by_dop.map { |p| [p.name_with_dop, p.id]  }
  end

  def new
    @client = Client.new
  end

  def edit
  end

  def create
    @client = Client.new(client_params)
      if @client.save
        redirect_to admin_clients_path
        flash[:success] = "#{@client.name} was successfully added"
      else
        render :new, status: :unprocessable_entity
      end
  end

  def update
      if @client.update(client_params)
        redirect_to admin_clients_path
        flash[:success] = "#{@client.name} was successfully updated"
      else
        render :edit, status: :unprocessable_entity
      end
  end

  def destroy
    @client.destroy
      redirect_to admin_clients_path
      flash[:success] = "#{@client.name} was successfully deleted"
  end

  def clear_filters
    clear_session(:filter_packagee, :search_client_name)
    redirect_to admin_clients_path
  end

  def filter
    clear_session(:filter_packagee, :search_client_name)
    session[:search_client_name] = params[:search_client_name] || session[:search_client_name]
    session[:filter_packagee] = params[:packagee] || session[:filter_packagee]
    redirect_to admin_clients_path
  end

  private
    def set_client
      @client = Client.find(params[:id])
    end

    def client_params
      params.require(:client).permit(:first_name, :last_name, :email, :phone, :instagram, :whatsapp, :note)
    end

    def correct_account
      redirect_to referrer unless Client.find(params[:id]).account == current_account
    end

    def correct_account_or_admin
      redirect_to(root_url) unless Client.find(params[:id]).account == current_account || logged_in_as?('admin', 'superadmin')
    end

    def handle_search_name
      @clients = @clients.name_like(session[:search_client_name])
    end

    def handle_search
      @clients = @clients.joins(:purchases).merge(Purchase.with_package).distinct if session[:filter_packagee].present?
    end

    # def layout_set
    #   if logged_in_as?('admin')
    #     self.class.layout 'admin'
    #   else
    #     # fails without self.class. Solution given here but reason not known.
    #     # https://stackoverflow.com/questions/33276915/undefined-method-layout-for
    #     self.class.layout 'application'
    #   end
    # end
end
