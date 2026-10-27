.PHONY: build run


build:
	$(MAKE) -C skynet linux

run:
	./skynet/skynet config