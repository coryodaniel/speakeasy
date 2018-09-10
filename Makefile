all:
	mix do clean, deps.get, compile
	mix test
	mix do format, docs
