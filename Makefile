.PHONY: e2e
e2e:
	rails db:prepare
	for i in {1..3}; do \
		rspec spec; \
	done