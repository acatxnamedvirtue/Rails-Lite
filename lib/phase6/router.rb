module Phase6
  class Route
    attr_reader :pattern, :http_method, :controller_class, :action_name

    def initialize(pattern, http_method, controller_class, action_name)
      @pattern, @http_method, @controller_class, @action_name =
        pattern, http_method, controller_class, action_name
    end

    # checks if pattern matches path and method matches request method
    def matches?(req)
      req.request_method.downcase.to_sym == http_method && pattern =~ req.path
    end

    # use pattern to pull out route params (save for later?)
    # instantiate controller and call controller action
    def run(req, res)
      regex = Regexp.new pattern
      match_data = regex.match(req.path)
      keys = match_data.names
      values = match_data.captures
      route_params = {}

      keys.count.times { |x| route_params[keys[x]] = values[x] }

      controller_class.new(req, res, route_params).invoke_action(action_name)
    end
  end

  class Router
    attr_reader :routes

    def initialize
      @routes = []
    end

    # simply adds a new route to the list of routes
    def add_route(pattern, method, controller_class, action_name)
      routes << Route.new(pattern, method, controller_class, action_name)
    end

    # evaluate the proc in the context of the instance
    # for syntactic sugar :)
    def draw(&proc)
      instance_eval(&proc)
    end

    # make each of these methods that
    # when called add route
    [:get, :post, :put, :delete].each do |http_method|
      define_method(http_method) do |*args|
        args.insert(1,http_method)
        add_route(*args)
      end
    end

    # should return the route that matches this request
    def match(req)
      routes.find { |route| route.matches?(req) }
    end

    # either throw 404 or call run on a matched route
    def run(req, res)
      match(req) ? match(req).run(req, res) : res.status = 404
    end
  end
end
