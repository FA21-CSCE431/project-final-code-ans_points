# frozen_string_literal: true

class ContactsController < ApplicationController
  # fetch the event immediately on these actions
  before_action :set_contact, only: %i[show edit delete]

  ###########################
  ###### user endpoints #####
  ###########################

  # view all events
  def index
    @contacts = Contact.all
    redirect_to controller: 'contacts', action: 'search'
  end

  def search
    input = params[:input]
    return @contacts = Contact.all if input.nil?

    return @contacts = Contact.all if input == ''

    logger.info(input)
    @contacts = Contact.all.where('"contacts"."lastname" = ?', input)
    return if @contacts.nil?
  end

  ###########################
  ##### admin endpoints #####
  ###########################

  def new
    @contact = Contact.new
  end

  def edit; end

  def create
    @contact = Contact.new(contact_params)
  end

  def delete
    @contact.destroy
  end

  def show
    redirect_to controller: 'contacts', action: 'index'
  end

  #########################
  #### private methods ####
  #########################

  private

  def set_contact
    @contact = Contact.find(params[:id])
  end

  def contact_params
    params.require(:contact).permit(:firstname, :lastname, :title, :bio, :affiliation, :email)
  end
end
