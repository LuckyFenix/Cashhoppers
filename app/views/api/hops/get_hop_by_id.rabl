object :@hop
attributes :id,
           :name,
           :time_start,
           :time_end,
           :code,
           :price,
           :jackpot,
           :daily,
           :close,
           :event,
           :created_at,
           :updated_at

node :assigned do |hop|
   (hop.hoppers.include? @current_user) ? true : false
end

node :score do |hop|
   hop.score @current_user
end

node :logo do |hop|
   hop.logo.url if hop.logo.present?
end

node :purchased do |hop|
    if hop.free?
        nil
    else
        hop.assigned? @current_user
    end
end
