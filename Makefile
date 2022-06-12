seal:
	./ci/seal_secrets.sh
qa:
	./ci/charts_qa.sh . && ./ci/argo_qa.sh . "argocd"
local:
	./local/cluster.sh argo && ./local/argo.sh "local/secrets/repo.txt"
.PHONY: seal qa local