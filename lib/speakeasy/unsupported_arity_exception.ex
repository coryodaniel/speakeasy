defmodule Speakeasy.UnsupportedArityError do
  defexception [:message]

  @doc false
  def msg(mod, fun) do
    fun_name_without_arity = "#{mod}.#{fun}"

    "Speakeasy expects a function with an arity of 0-2. Implement one of: #{
      fun_name_without_arity
    }/2, #{fun_name_without_arity}/1, #{fun_name_without_arity}/0"
  end
end
