.PHONY: test validate

# Verify the consistency stamp is current.
# The stamp is written by Claude during /harden or /stage after validating
# that README, skills, and internal references are all consistent.
# If the stamp is stale or missing, the check fails and tells you to run /harden.
test:
	@bash scripts/check-stamp.sh

validate: test
