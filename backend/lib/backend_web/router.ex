defmodule BackendWeb.Router do
  use BackendWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticate do
    plug BackendWeb.Plugs.AuthPlug
  end

  # Public routes (no auth required)
  scope "/api", BackendWeb do
    pipe_through :api

    post "/users", UserController, :create
    post "/sessions", SessionController, :create
  end

  # Protected routes
  scope "/api", BackendWeb do
    pipe_through [:api, :authenticate]

    resources "/users", UserController, only: [:index, :show, :update, :delete]
    resources "/contacts", ContactController, except: [:new, :edit]

    resources "/conversations", ConversationController, except: [:new, :edit] do
      get "/messages", MessageController, :by_conversation
      get "/members", ConversationController, :members
      post "/members", ConversationController, :add_member
    end

    resources "/groups", GroupController, except: [:new, :edit]
    resources "/messages", MessageController, except: [:new, :edit]
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:backend, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: BackendWeb.Telemetry
    end
  end
end
