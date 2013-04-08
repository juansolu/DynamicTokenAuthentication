class UsersController < ApplicationController
  include UsersHelper
  skip_before_filter :verify_authenticity_token, :only => [:authenticateUser, :endAuthenticateUser]

  #******************************
  #Vigenere methods
  BASE = 'A'.ord
  SIZE = 'Z'.ord - BASE + 1
 
  def setKey(key)
    @key = key.upcase.gsub(/[^A-Z]/, '')
    puts "Key set to: "+@key
  end
 
  def encrypt(text)
    crypt(text, :+)
  end
 
  def decrypt(text)
    crypt(text, :-)
  end
 
  def crypt(text, dir)
    plaintext = text.upcase.gsub(/[^A-Z]/, '')
    key_iterator = @key.chars.cycle
    ciphertext = ''
    plaintext.each_char do |plain_char|
      offset = key_iterator.next.ord - BASE
      ciphertext +=
        ((plain_char.ord - BASE).send(dir, offset) % SIZE + BASE).chr
    end
    return ciphertext
  end
  
  def to_caesar (word, shift)
    shift = (shift % 26).abs
    word.each_byte.map { |b| ((b + shift - 97) % 26 + 97).chr }.join
  end

  #******************************

  def resetUserToSeed
    @INITIAL_TOKEN = "bgcdadjoofmejkpnjdcicpfmfoeohjam"
    @user_model = User.where("username = ?", params[:user]).first
    setKey(@user_model.valid_token)
    @msgReceivedDecrypted = decrypt(params[:msgContent])
    puts "Decrypted: " + @msgReceivedDecrypted
    @user_model.valid_token = @INITIAL_TOKEN
    @user_model.token_rotation_count = 0
    
    if @user_model.save
      response = {
        user: params[:user],
        msg: "TOKEN_RESET_SUCCESFULLY"
      }
      render json: params[:callback] + '(' + response.to_json + ');'
    else
      render json: params[:callback] + '(' + @user_model.errors.to_json + ');'
    end
  end

  def authenticateUser
    @user_model = User.where("username = ?", params[:user]).first
    puts "user found: "+@user_model.inspect
    setKey(@user_model.valid_token)
    @msgReceivedDecrypted = decrypt(params[:msgContent])
    puts "MsgsReceivedDecrypted: "+@msgReceivedDecrypted
    
    s_response = {
      msg: "AUTHENTICATED_SUCCESFULLY",
      expires: Time.now + 1.hour
    }
  
    f_response = {
        msg: "NOT_AUTHORIZED"
    }

    if @msgReceivedDecrypted == "CONNECT"
      response = s_response
    else
      response = f_response
    end

    puts "Response: "+ response.inspect
    render json: params[:callback] + '(' + response.to_json + ');'
  end

  def endAuthenticateUser
    @user_model = User.where("username = ?", params[:user]).first
    puts "user found: "+@user_model.inspect
    setKey(@user_model.valid_token)
    @msgReceivedDecrypted = decrypt(params[:msgContent])
    puts "MsgsReceivedDecrypted: "+@msgReceivedDecrypted

    s_response = {
      msg: "ENDED_SESSION_SUCCESFULLY",
      expires: Time.now + 1.hour
    }
  
    f_response = {
        msg: "NOT_AUTHORIZED"
    }

    if @msgReceivedDecrypted == "DISCONNECT"
      @user_model.valid_token = @user_model.valid_token.split.map { |w| to_caesar(w, @user_model.token_rotation_count) }.join(' ')
      @user_model.token_rotation_count = @user_model.token_rotation_count + 1

      if @user_model.save!
        puts "SAved successfully"
        response = s_response
      else
        puts "Error saving"
        response = f_response
      end

    else
      puts "Invalid msg received"
      response = f_response
    end

    render json: params[:callback] + '(' + response.to_json + ');'
  end

  def listOfUsers(users)
    
    results = []

    users.each do |user|
      results << { 
                  :id           => user.id,
                  :username     => user.username,
                  :email        => user.email,
                  :created_at   => user.created_at
                }
    end
    return results
  end

  # GET /users
  # GET /users.to_jsonon
  def index
    @user_model = User.where("username = ?", params[:user]).first
    puts "user found: "+@user_model.inspect
    setKey(@user_model.valid_token)
    @msgReceivedDecrypted = decrypt(params[:msgContent])
    puts "MsgsReceivedDecrypted: "+@msgReceivedDecrypted
    

    if @msgReceivedDecrypted == "REQUESTCONFIDENTIALLISTOFUSERS" 
      @users = User.all
    else
      response = {
        error: "Not authorized to access resource"
      }
      render json: params[:callback] + '(' + response.to_json + ');'
      return 
    end
    respond_to do |format|
      format.html # index.html.erb
      response = {
        msg: listOfUsers(@users)
      }
      format.json { render json: params[:callback] + '(' + response.to_json + ');' }
    end

  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end
end
