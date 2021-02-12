use Mix.Config

config :speakeasy,
  user_key: :current_user,
  authn_error_message: :unauthenticated,
  authz_error_message: :unauthenticated
