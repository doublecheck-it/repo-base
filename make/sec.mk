## Security scanning tasks

.PHONY: sec.scan-image sec.scan-deps

sec.scan-image: ## Scan Docker image with Trivy (set IMAGE_NAME env var)
	@if [ -z "$$IMAGE_NAME" ]; then \
		echo "IMAGE_NAME environment variable not set."; \
		echo "Usage: IMAGE_NAME=myimage:tag make sec.scan-image"; \
		exit 1; \
	fi
	@echo "Scanning image: $$IMAGE_NAME"
	docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
		aquasec/trivy image \
		--scanners vuln \
		--exit-on-eol 1 \
		--detection-priority comprehensive \
		--severity HIGH,CRITICAL \
		"$$IMAGE_NAME"

sec.scan-deps: ## Scan dependencies for vulnerabilities (placeholder)
	@echo "sec.scan-deps: No dependency scanner configured (generic base)."
	@echo "Override this target in stack-specific repos (e.g., for npm audit, pip-audit, etc.)"