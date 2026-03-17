class SupportTicketsController < ApplicationController
  before_action :authenticate_user!

  def index
    @tickets = current_user.support_tickets.order(created_at: :desc)
  end

  def show
    @ticket = current_user.support_tickets.find(params[:id])
    @messages = @ticket.ticket_messages.includes(:user).order(:created_at)
  end

  def new
    @ticket = SupportTicket.new
    @pickup = current_user.household&.pickups&.find_by(id: params[:pickup_id])
    @pickups = current_user.household&.pickups&.order(created_at: :desc)&.limit(20) || []
  end

  def create
    @ticket = current_user.support_tickets.build(ticket_params)
    if @ticket.save
      @ticket.ticket_messages.create(user: current_user, body: @ticket.description)
      redirect_to support_ticket_path(@ticket), notice: "Your ticket has been submitted. We'll get back to you shortly."
    else
      @pickups = current_user.household&.pickups&.order(created_at: :desc)&.limit(20) || []
      render :new, status: :unprocessable_entity
    end
  end

  def add_message
    @ticket = current_user.support_tickets.find(params[:id])
    @message = @ticket.ticket_messages.build(user: current_user, body: params[:message][:body])
    if @message.save
      redirect_to support_ticket_path(@ticket), notice: "Message sent."
    else
      redirect_to support_ticket_path(@ticket), alert: "Message could not be sent."
    end
  end

  private

  def ticket_params
    params.require(:support_ticket).permit(:category, :description, :pickup_id)
  end
end
