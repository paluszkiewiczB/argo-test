Secrets from this directory should **never** contain credentials/sensitive values in **plain text or base64 encoding**.

Those secrets **are templates**, which must be filled with actual sensitive values and **sealed with kubeseal tool**.

Public key should be stored in

```
test-project/infra/sealed-secrets/cert/<name>.key
```