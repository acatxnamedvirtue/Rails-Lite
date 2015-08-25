require 'uri'

module Phase5
  class Params
    # use your initialize to merge params from
    # 1. query string
    # 2. post body
    # 3. route params
    #
    # You haven't done routing yet; but assume route params will be
    # passed in as a hash to `Params.new` as below:
    def initialize(req, route_params = {})
      @params = route_params
      parse_www_encoded_form(req.query_string)
      parse_www_encoded_form(req.body)
    end

    def [](key)
      @params[key.to_sym] || @params[key.to_s]
    end

    # this will be useful if we want to `puts params` in the server log
    def to_s
      @params.to_s
    end

    class AttributeNotFoundError < ArgumentError; end;

    private
    # this should return deeply nested hash
    # argument format
    # user[address][street]=main&user[address][zip]=89436
    # should return
    # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
    def parse_www_encoded_form(www_encoded_form)
      return nil if www_encoded_form.nil?
      decoded = URI::decode_www_form(www_encoded_form)

      decoded.each do |top_key, value|
        keys = parse_key(top_key)
        level = @params

        keys.each_with_index do |key, idx|
          level[key] ||= {} if idx < keys.size - 1
          level[key] = value if idx == keys.size - 1
          level = level[key]
        end
      end
    end

    # this should return an array
    # user[address][street] should return ['user', 'address', 'street']
    def parse_key(key)
      parsed = key.split(/\]\[|\[|\]/)
    end
  end
end
