.PHONY: e2e
e2e:
	for i in {1..5}; do \
		rspec spec; \
	done