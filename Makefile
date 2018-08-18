all:
	mix deps.get
	mix format
	mix docs
	mix test
