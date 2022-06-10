seal:
	./ci/seal_secrets.sh
qa:
	./ci/charts_qa.sh . && ./ci/argo_qa.sh . "argocd"

.PHONY: seal qa