class PubSubsController < ApplicationController
  # GET /pub_subs
  # GET /pub_subs.json
  def index
    @pub_subs = PubSub.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @pub_subs }
    end
  end

  # GET /pub_subs/1
  # GET /pub_subs/1.json
  def show
    @pub_sub = PubSub.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @pub_sub }
    end
  end

  # GET /pub_subs/new
  # GET /pub_subs/new.json
  def new
    @pub_sub = PubSub.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @pub_sub }
    end
  end

  # GET /pub_subs/1/edit
  def edit
    @pub_sub = PubSub.find(params[:id])
  end

  # POST /pub_subs
  # POST /pub_subs.json
  def create
    @pub_sub = PubSub.new(params[:pub_sub])

    respond_to do |format|
      if @pub_sub.save
        format.html { redirect_to @pub_sub, notice: 'Pub sub was successfully created.' }
        format.json { render json: @pub_sub, status: :created, location: @pub_sub }
      else
        format.html { render action: "new" }
        format.json { render json: @pub_sub.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /pub_subs/1
  # PUT /pub_subs/1.json
  def update
    @pub_sub = PubSub.find(params[:id])

    respond_to do |format|
      if @pub_sub.update_attributes(params[:pub_sub])
        format.html { redirect_to @pub_sub, notice: 'Pub sub was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @pub_sub.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pub_subs/1
  # DELETE /pub_subs/1.json
  def destroy
    @pub_sub = PubSub.find(params[:id])
    @pub_sub.destroy

    respond_to do |format|
      format.html { redirect_to pub_subs_url }
      format.json { head :no_content }
    end
  end
  
  # Handles responses from Hub servers
  def callback
    @pub_sub = PubSub.find(params[:id])
    
    # GET: hub is trying to verify a new subscription
    if request.method == "GET"
      if challenge = params['hub.challenge']
        if timeout = params['hub.lease_seconds']
          # Hub will generally ask us if we want to refresh the subscription
          # before this expiry time occurs
          @pub_sub.expires_at = Time.at(timeout.to_i + Time.now.to_i).to_datetime
        end
        # ensure this is the topic we requested before subscribing
        if @pub_sub.topic == params['hub.topic'] and
           @pub_sub.verify_token == params['hub.verify_token']
          @pub_sub.status = 'subscribed'
          @pub_sub.save
          respond_to { |format| format.html { render text: challenge } }
        else
          @pub_sub.status = 'subscription failed: hub returned bad topic and/or verify_token'
          @pub_sub.save

          respond_to { |format|
            format.html {
              render text: "error: you responded with invalid hub topic and/or 
                verify token", status: 404
            }
          }
        end
      else
        respond_to {|format| format.html { render text: "No challenge provided.", status: 404 }}
      end
      
    # POST: hub is notifying us of a new subscription
    elsif request.method == "POST"
      logger.info params
      logger.info request.inspect
      respond_to {|format| format.html{ render text: "OK" }}
    # Unsupported request from Hub or other server
    else
      respond_to {|format| format.html{ render text: "Unsupported Request", status: 405 }}
    end
  end
  
  def subscribe
    @pub_sub = PubSub.find(params[:id])    
    
    respond_to do |format|
      if @pub_sub.subscribe
        format.html { redirect_to pub_subs_url, notice: "PubSub #{@pub_sub.blog_url} successfully subscribed" }
      else
        format.html { render action: 'edit' }
      end
    end
  end
  
  def unsubscribe
    @pub_sub = PubSub.find(params[:id])
    
    respond_to do |format|
      if @pub_sub.unsubscribe
        format.html { redirect_to pub_subs_url, notice: "PubSub #{@pub_sub.blog_url} successfully unsubscribed" }
      else
        format.html { render action: 'edit' }
      end
    end
  end
end
