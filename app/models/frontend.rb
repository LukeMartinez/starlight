require 'rest_client'
require 'json'


class Frontend

  def getfrontdata(userid)
    url = "http://10.42.80.12:8111/v1" #the Frontend url is provided by Ops on the Wiki for DB read access
    return JSON.parse(RestClient.get "#{url}/users/#{userid}/stats/isps?startdate=#{(Time.now - (86400*30)).strftime("%Y-%m-%d")}&metric=all&aggregatedby=day")
  end
       
  def hashformatter(state,passed,isparray,hash)  #formatts the returned content from grab
    eventarray = ["request", "delivered", "bounce", "blocked", "open", "click", "spamreport"]

    if state == 0        #This huge chunk of if elses formats and sums the returned json correctly
      eventarray.each do |event|
        isparray.each do |isp|
          if isp == isparray[0]
            if passed[event].nil?
              hash[event.to_s] = {isp => 0}
            elsif passed[event][isp].nil?
              hash[event.to_s] = {isp => 0}
            else
              hash[event.to_s] = {isp => passed[event][isp]}
            end
          else
            if passed[event].nil? or passed[event][isp].nil? 
              hash[event].merge!(isp => 0)
            else
              hash[event].merge!(isp => passed[event][isp])
            end
          end
        end
      end
    else #The second else step is here to add the datapoints from the multiple days pulled from the hash
      eventarray.each do |event|
        isparray.each do |isp|
          if passed[event] == nil
            next
          elsif passed[event][isp] == nil
            next
          else
            hash[event][isp] += passed[event][isp]
          end
        end
      end
    end
    return hash
  end

  def percent(hasheddata, isp) #This percent method formates the hash into the correct output for the report pdf
    returnedarray = []

    if hasheddata["request"][isp] == 0
      returnedarray << "-"
    else 
      returnedarray << (((hasheddata["delivered"][isp].to_f / hasheddata["request"][isp])*100).round).to_s + "%"
    end

    if hasheddata["delivered"][isp] == 0
      returnedarray << "-"
      returnedarray << "-"
      returnedarray << hasheddata["open"][isp].to_s
      returnedarray << hasheddata["click"][isp].to_s
      returnedarray << hasheddata["spamreport"][isp].to_s
    else    
      returnedarray << (((hasheddata["bounce"][isp].to_f / hasheddata["delivered"][isp])*100).round).to_s + "%"
      returnedarray << (((hasheddata["blocked"][isp].to_f / hasheddata["delivered"][isp])*100).round).to_s + "%"
      returnedarray << (((hasheddata["open"][isp].to_f / hasheddata["delivered"][isp])*100).round).to_s + "%"
      returnedarray << (((hasheddata["click"][isp].to_f / hasheddata["delivered"][isp])*100).round).to_s + "%"
      returnedarray << (((hasheddata["spamreport"][isp].to_f / hasheddata["delivered"][isp])*100).round(2)).to_s + "%"
    end

    return returnedarray
  end

  def hey
    "heyyy"
  end 

  def grab(userid)
    data = getfrontdata(userid)

    count = 0 #this calls the huge chunk of if else code from hashformatter 
    isps = ["Hotmail", "Yahoo", "Gmail", "AOL", "Other"]
    returnedhash = {} 

    if data == []
      return nil
    else
      data.each do |x|
        if count == 0
          returnedhash = hashformatter(0,x,isps,returnedhash)
          count = 1
        else
          returnedhash = hashformatter(1,x,isps,returnedhash)
        end
      end

      output = []
      isps.each do |x| #this takes each of the ISP arrays and places them into another array to pass to the reportcard.rb
        output << percent(returnedhash, x)
      end

      return output
    end
  end
end

# a = Frontend.new()
# p a.grab(898596)