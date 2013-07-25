class MessagesController < ApplicationController

 def message_list
   @messages = Message.includes(:sender).where(:receiver_id => current_user.id).inject([]){|arr, msg| arr << [msg.sender.user_name, msg.text]}
   @mymessages = Message.includes(:sender).where(:sender_id => current_user.id).inject([]){|arr, msg| arr << [msg.receiver.user_name, msg.text]}
 end

  def create_message
    user = current_user.friends.find(params[:message][:receiver_id] )
    if user
      params[:message][:sender_id] = current_user.id
      @message = Message.new(params[:message])
      if @message.save
       redirect_to messages_message_list_path
      else
        flash[:error] = "Text can't be blank"
        redirect_to messages_message_list_path
      end
    else
      flash[:error] = "not found #{params[:message][:receiver_id]} in your friends"
      redirect_to messages_message_list_path
    end
  end

end
