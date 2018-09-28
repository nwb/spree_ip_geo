Spree::BaseHelper.module_eval do
    def country_id
      country_from_ip(request.remote_ip).id rescue 214
    end

    def country_code
      country_code_from_ip(request.remote_ip) rescue 'US'
    end

    def state_code
      state_code_from_ip(request.remote_ip) rescue ''
    end

    def country_from_ip(ip)
      Spree::Country.find_by_iso(country_code_from_ip(ip))
    end

    def country_code_from_ip(ip)
      g=geo_from_ip(ip)
      if !!g
        g.iso
      else
        'US'
      end
    end

    def state_code_from_ip(ip)
      g=geo_from_ip(ip)
      if !!g
        g.state
      else
        ''
      end
    end

    def city_from_ip(ip)
      g=geo_from_ip(ip)
      if !!g
        g.city
      else
        ''
      end
    end

    def geo_from_ip(ip)             # return ip_mapping object in hash
      ip=ip.gsub(/.\d*\z/,'.1')     # the last ip segment does not make sense to know the country code
      mapping = Spree::IpMapping.find_by_ip_address(ip)

      begin
        if mapping.nil?

          res = lookup(ip)

          if res.length > 200
            r=JSON.parse(res)
            city=r.has_key?("city")? r["city"]["names"]["en"] : ''
            country=r.has_key?("country")? r["country"]["iso_code"] : 'US'
            state=r.has_key?("subdivisions")? r["subdivisions"].first["iso_code"] : ''

            Spree::IpMapping.create(:ip_address => ip, :iso => country, :state => state, :city => city)
            return Spree::IpMapping.find_by_ip_address(ip)
          else
            Spree::IpMapping.create(:ip_address => ip, :iso => "US")
            return Spree::IpMapping.find_by_ip_address(ip)
          end
        else
          if mapping.updated_at > 1.years.ago
            return mapping
          else
            res = lookup(ip)

            if res.length > 200
              r=JSON.parse(res)
              city=r.has_key?("city")? r["city"]["names"]["en"] : ''
              country=r.has_key?("country")? r["country"]["iso_code"] : 'US'
              state=r.has_key?("subdivisions")? r["subdivisions"].first["iso_code"] : ''

              mapping.update_attributes({:ip_address => ip, :iso => country, :state => state, :city => city})

              return mapping
            else
              mapping.update_attributes({:ip_address => ip, :iso => "US"})
              return mapping
            end
          end
        end
      rescue => e
        Rails.logger.error "Exception try to Geo locate IP address"
        Rails.logger.error e.message
        return nil
      rescue Timeout::Error => e
        Rails.logger.error "Timeout trying to connect to Maxmind service."
        return nil
      end
    end

    def lookup(ip)   # use 2014 gemip web service at city level query, now it return json string

      geo_ip_account_id= Spree::MaxmindConfiguration.account["default"]["geo_ip_account_id"]
      geo_ip_key= Spree::MaxmindConfiguration.account["default"]["geo_ip_key"]

      url = URI.parse("https://geoip.maxmind.com/geoip/v2.1/city/#{ip}")

      path = (!url.query) ? url.path : "#{url.path}?#{url.query}"
      req = Net::HTTP.new(url.host, url.port)
      req.use_ssl=true
      req.verify_mode = OpenSSL::SSL::VERIFY_NONE
      req.start do |http|
        the_request= Net::HTTP::Get.new(path)
        http.open_timeout = 3
        http.read_timeout = 3
        the_request.basic_auth  geo_ip_account_id, geo_ip_key

        http.request(the_request).body
      end

    end
 
end

