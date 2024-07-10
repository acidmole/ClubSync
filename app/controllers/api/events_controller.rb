# frozen_string_literal: true
module Api
  class EventsController < ApplicationController
    def index
      @events = Event.all
      render json: @events
    end

    def show
      @event = Event.find(params[:id])
      render json: @event
    end
  end
end